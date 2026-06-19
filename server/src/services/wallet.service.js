const { postgres } = require("../config/db/database");
const { Op } = require("sequelize");
const Wallets = require("../model/wallets.model");
const WalletTransactions = require("../model/wallet_transactions.model");
const Payments = require("../model/payments.model");
const Users = require("../model/users.model");
const CoinPackages = require("../model/coin_packages.model");

async function depositCoinService({
  user_id,
  coins,
  description = "Coin deposited",
  payment_id = null,
  source_type = "payment",
  source_id = null,
  created_by = null,
}) {
  const dbTransaction = await postgres.transaction();

  try {
    if (!user_id) {
      throw new Error("user_id is required");
    }

    if (coins === undefined || coins === null) {
      throw new Error("coins is required");
    }

    const depositCoins = Number(coins);

    if (Number.isNaN(depositCoins) || depositCoins <= 0) {
      throw new Error("coins must be a positive number");
    }

    let wallet = await Wallets.findOne({
      where: { user_id },
      transaction: dbTransaction,
      lock: dbTransaction.LOCK.UPDATE,
    });

    if (!wallet) {
      wallet = await Wallets.create(
        {
          user_id,
          balance_coins: 0,
          total_earned_coins: 0,
          total_spent_coins: 0,
          status: "active",
        },
        { transaction: dbTransaction },
      );
    }

    const balanceBefore = Number(wallet.balance_coins || 0);
    const totalEarnedBefore = Number(wallet.total_earned_coins || 0);
    const totalSpentBefore = Number(wallet.total_spent_coins || 0);

    const balanceAfter = balanceBefore + depositCoins;
    const totalEarnedAfter = totalEarnedBefore + depositCoins;

    await wallet.update(
      {
        balance_coins: balanceAfter,
        total_earned_coins: totalEarnedAfter,
      },
      { transaction: dbTransaction },
    );

    const walletTransaction = await WalletTransactions.create(
      {
        wallet_id: wallet.wallet_id,
        user_id,
        payment_id,
        transaction_type: "credit",
        source_type,
        source_id,
        coins: depositCoins,
        balance_before: balanceBefore,
        balance_after: balanceAfter,
        description,
        created_by,
      },
      { transaction: dbTransaction },
    );

    await dbTransaction.commit();

    return {
      success: true,
      message: "Coins deposited successfully",
      data: {
        wallet_id: wallet.wallet_id,
        user_id: wallet.user_id,
        balance_coins: balanceAfter,
        total_earned_coins: totalEarnedAfter,
        total_spent_coins: totalSpentBefore,
        wallet_transaction_id: walletTransaction.wallet_transaction_id,
      },
    };
  } catch (error) {
    await dbTransaction.rollback();
    throw new Error(error.message);
  }
}

async function getUserCoinsService(id) {
  try {
    const wallet = await Wallets.findOne({ where: { user_id: id } });
    if (!wallet) {
      return {
        success: true,
        message: "User has no wallet",
        data: {
          user_id: id,
          balance_coins: 0,
          total_earned_coins: 0,
          total_spent_coins: 0,
        },
      };
    }

    return {
      success: true,
      message: "User coins fetched successfully",
      data: {
        user_id: wallet.user_id,
        balance_coins: wallet.balance_coins,
        total_earned_coins: wallet.total_earned_coins,
        total_spent_coins: wallet.total_spent_coins,
      },
    };
  } catch (error) {
    throw new Error(error.message);
  }
}

async function getPaymentHistoryService({
  requesterUserId,
  requesterRole,
  page = 1,
  limit = 10,
  fromDate,
  toDate,
  status,
  gateway,
  userId,
}) {
  try {
    const safePage = Math.max(Number(page) || 1, 1);
    const safeLimit = Math.min(Math.max(Number(limit) || 10, 1), 100);
    const offset = (safePage - 1) * safeLimit;

    const where = {};

    if (requesterRole !== "admin") {
      where.user_id = requesterUserId;
    } else if (userId) {
      where.user_id = userId;
    }

    if (status) {
      where.status = String(status).trim().toLowerCase();
    }

    if (gateway) {
      where.gateway = String(gateway).trim().toLowerCase();
    }

    if (fromDate || toDate) {
      const createdAtFilter = {};

      if (fromDate) {
        createdAtFilter[Op.gte] = new Date(fromDate);
      }

      if (toDate) {
        const endDate = new Date(toDate);
        endDate.setHours(23, 59, 59, 999);
        createdAtFilter[Op.lte] = endDate;
      }

      where.created_at = createdAtFilter;
    }

    const { rows, count } = await Payments.findAndCountAll({
      where,
      include: [
        {
          model: Users,
          as: "user",
          attributes: ["user_id", "full_name", "email", "phone", "role"],
        },
        {
          model: CoinPackages,
          as: "coin_package",
          attributes: [
            "coin_package_id",
            "title",
            "coins",
            "bonus_coins",
            "price_amount",
          ],
        },
      ],
      order: [["created_at", "DESC"]],
      limit: safeLimit,
      offset,
      distinct: true,
    });

    return {
      success: true,
      message: "Payment history fetched successfully",
      data: {
        items: rows.map((payment) => ({
          payment_id: payment.payment_id,
          amount: payment.amount,
          currency: payment.currency,
          status: payment.status,
          gateway: payment.gateway,
          gateway_transaction_id: payment.gateway_transaction_id,
          gateway_reference: payment.gateway_reference,
          payment_for: payment.payment_for,
          coins_credited: payment.coins_credited,
          paid_at: payment.paid_at,
          created_at: payment.created_at,
          user: payment.user
            ? {
                user_id: payment.user.user_id,
                full_name: payment.user.full_name,
                email: payment.user.email,
                phone: payment.user.phone,
                role: payment.user.role,
              }
            : null,
          coin_package: payment.coin_package
            ? {
                coin_package_id: payment.coin_package.coin_package_id,
                title: payment.coin_package.title,
                coins: payment.coin_package.coins,
                bonus_coins: payment.coin_package.bonus_coins,
                price_amount: payment.coin_package.price_amount,
              }
            : null,
        })),
        pagination: {
          page: safePage,
          limit: safeLimit,
          total: count,
          total_pages: Math.ceil(count / safeLimit) || 0,
        },
        filters: {
          from_date: fromDate || null,
          to_date: toDate || null,
          status: status || null,
          gateway: gateway || null,
          user_id: requesterRole === "admin" ? userId || null : requesterUserId,
        },
      },
    };
  } catch (error) {
    throw new Error(error.message);
  }
}

module.exports = {
  depositCoinService,
  getUserCoinsService,
  getPaymentHistoryService,
};
