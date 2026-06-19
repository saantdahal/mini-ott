const { BACKEND_URI } = require("../config/env");
const CoinPackages = require("../model/coin_packages.model");
const Payments = require("../model/payments.model");
const {
  initializeKhaltiPayment,
  verifyKhaltiPayment,
} = require("../services/khalti.service");
const { depositCoinService } = require("../services/wallet.service");

exports.initializeKhaltiPaymentController = async (req, res, next) => {
  try {
    const { packageId, price, packageName, website_url } = req.body;

    const packageData = await CoinPackages.findByPk(packageId);
    if (!packageData) {
      return res.status(404).json({
        message: "The package you are trying to purchase doesn't exist",
      });
    }

    const createPendingPurchase = await Payments.create({
      user_id: req._id,
      coin_package_id: packageId,
      gateway: "khalti",
      amount: price,
      status: "initiated",
    });

    const paymentInitiate = await initializeKhaltiPayment({
      purchase_order_id: createPendingPurchase.payment_id,
      purchase_order_name: packageName,
      amount: price * 100,
      return_url: `${BACKEND_URI}/api/khalti/complete-khalti-payment`,
      website_url,
    });

    res.status(200).json({
      message: "Purchase successful",
      paymentInitiate: paymentInitiate,
      createPendingPurchase,
    });
  } catch (error) {
    res.status(400).json({
      message: "Failed to initiate Khalti payment",
      error: error.message,
    });
  }
};

exports.completeKhaltiPaymentController = async (req, res, next) => {
  const { pidx, amount, purchase_order_id, transaction_id } = req.query;

  try {
    if (!pidx || !amount || !purchase_order_id || !transaction_id) {
      return res.status(400).json({
        message: "Missing required query parameters",
      });
    }

    const paymentInfo = await verifyKhaltiPayment(pidx);

    if (
      paymentInfo?.status !== "Completed" ||
      paymentInfo?.transaction_id !== transaction_id ||
      Number(paymentInfo?.total_amount) !== Number(amount)
    ) {
      await Payments.update(
        {
          status: "failed",
          failure_reason: "Khalti verification failed",
          metadata: {
            pidx,
            transaction_id,
            amount: Number(amount),
            paymentInfo,
            apiQueryFromUser: req.query,
          },
        },
        {
          where: { payment_id: purchase_order_id },
        },
      );

      return res.status(400).json({
        message: "Payment failed",
      });
    }

    const purchasedPayment = await Payments.findOne({
      where: { payment_id: purchase_order_id },
      include: [
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
    });

    if (!purchasedPayment) {
      return res.status(404).json({
        message: "Purchased payment not found",
      });
    }

    // duplicate callback / refresh case handle
    if (purchasedPayment.status === "completed") {
      return res.status(200).json({
        message: "Payment already completed",
      });
    }

    const packageCoins = Number(purchasedPayment.coin_package?.coins || 0);
    const bonusCoins = Number(purchasedPayment.coin_package?.bonus_coins || 0);
    const totalCoinsToCredit = packageCoins + bonusCoins;

    // payment update first
    await purchasedPayment.update({
      gateway_transaction_id: transaction_id,
      gateway_reference: "Khalti Payment Gateway",
      coins_credited: totalCoinsToCredit,
      status: "completed",
      paid_at: new Date(),
      failure_reason: null,
      metadata: {
        transactionId: transaction_id,
        pidx,
        productId: purchase_order_id,
        amount: Number(amount),
        dataFromVerificationReq: paymentInfo,
        apiQueryFromUser: req.query,
      },
    });

    const walletResult = await depositCoinService({
      user_id: purchasedPayment.user_id,
      coins: totalCoinsToCredit,
      payment_id: purchasedPayment.payment_id,
      source_type: "payment",
      source_id: purchasedPayment.coin_package_id || null,
      description: `Deposit from Khalti for purchasing ${purchasedPayment.coin_package?.title || "coin package"}`,
    });

    return res.status(200).json({
      message: "Payment successful",
      data: {
        payment_id: purchasedPayment.payment_id,
        transaction_id,
        coins_credited: totalCoinsToCredit,
        wallet: walletResult?.data || null,
      },
    });
  } catch (error) {
    return res.status(500).json({
      message: error.message,
    });
  }
};
