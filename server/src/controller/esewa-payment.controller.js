const CoinPackages = require("../model/coin_packages.model");
const Payments = require("../model/payments.model");
const {
  getEsewaPaymentHash,
  verifyEsewaPayment,
  getEsewaTransactionStatus,
  assertEsewaStatusMatchesExpected,
} = require("../services/esewa.service");
const { depositCoinService } = require("../services/wallet.service");
const { BACKEND_URI } = require("../config/env");

async function findPaymentWithCoinPackage(paymentId, { userId } = {}) {
  const where = { payment_id: paymentId };
  if (userId) {
    where.user_id = userId;
  }
  return Payments.findOne({
    where,
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
}

async function finalizeEsewaCoinPurchase(purchasedPayment, metadata) {
  if (purchasedPayment.status === "completed") {
    return {
      alreadyCompleted: true,
      data: {
        payment_id: purchasedPayment.payment_id,
        transaction_id: purchasedPayment.gateway_transaction_id,
        coins_credited: purchasedPayment.coins_credited,
        wallet: null,
      },
    };
  }

  const packageCoins = Number(purchasedPayment.coin_package?.coins || 0);
  const bonusCoins = Number(purchasedPayment.coin_package?.bonus_coins || 0);
  const totalCoinsToCredit = packageCoins + bonusCoins;

  const gatewayTransactionId =
    metadata.gatewayTransactionId != null
      ? metadata.gatewayTransactionId
      : null;

  await purchasedPayment.update({
    gateway_transaction_id: gatewayTransactionId,
    gateway_reference: "Esewa Payment Gateway",
    coins_credited: totalCoinsToCredit,
    status: "completed",
    paid_at: new Date(),
    failure_reason: null,
    metadata: metadata.storedMetadata,
  });

  const walletResult = await depositCoinService({
    user_id: purchasedPayment.user_id,
    coins: totalCoinsToCredit,
    payment_id: purchasedPayment.payment_id,
    source_type: "payment",
    source_id: purchasedPayment.coin_package_id || null,
    description: `Deposit from Esewa for purchasing ${purchasedPayment.coin_package?.title || "coin package"}`,
  });

  return {
    alreadyCompleted: false,
    data: {
      payment_id: purchasedPayment.payment_id,
      transaction_id: gatewayTransactionId,
      coins_credited: totalCoinsToCredit,
      wallet: walletResult?.data || null,
    },
  };
}

function getCallbackBaseUrl(req) {
  const forwardedHost = req.headers["x-forwarded-host"];
  const forwardedProto = req.headers["x-forwarded-proto"];
  const host = forwardedHost || req.get("host");
  const protocol = forwardedProto || req.protocol;

  if (host) {
    return `${protocol}://${host}`;
  }

  return BACKEND_URI;
}

exports.initializeEsewaPaymentController = async (req, res, next) => {
  try {
    const { packageId, price } = req.body;

    if (!packageId || price == null) {
      return res.status(400).json({
        success: false,
        message: "packageId and price are required",
      });
    }

    const packageData = await CoinPackages.findByPk(packageId);
    if (!packageData) {
      return res.status(404).json({
        message: "The package you are trying to purchase doesn't exist",
      });
    }

    const createPendingPurchase = await Payments.create({
      user_id: req._id,
      coin_package_id: packageId,
      gateway: "esewa",
      amount: price,
      status: "initiated",
    });

    const totalAmount = Number(price);
    if (!Number.isFinite(totalAmount) || totalAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid price",
      });
    }

    const totalAmountStr = totalAmount.toFixed(2);
    const paymentInitiate = await getEsewaPaymentHash({
      amount: totalAmountStr,
      transaction_uuid: createPendingPurchase.payment_id,
    });
    const gatewayUrl = process.env.ESEWA_GATEWAY_URL;
    const gatewayActionUrl = gatewayUrl
      ? `${gatewayUrl.replace(/\/$/, "")}/api/epay/main/v2/form`
      : null;
    const callbackBaseUrl = getCallbackBaseUrl(req);

    res.json({
      success: true,
      payment: {
        ...paymentInitiate,
        total_amount: totalAmountStr,
        transaction_uuid: createPendingPurchase.payment_id,
        product_code: process.env.ESEWA_PRODUCT_CODE,
        success_url: `${callbackBaseUrl}/api/esewa/complete-esewa-payment`,
        failure_url: `${callbackBaseUrl}/api/esewa/complete-esewa-payment`,
        gateway_url: gatewayUrl,
        gateway_action_url: gatewayActionUrl,
      },
      purchasedItemData: createPendingPurchase,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

exports.completeEsewaPaymentController = async (req, res, next) => {
  const { data } = req.query;

  try {
    if (!data) {
      return res.status(400).json({
        message: "Missing required query parameter: data",
      });
    }

    const paymentInfo = await verifyEsewaPayment(data);

    const paymentId = paymentInfo?.response?.transaction_uuid;
    if (!paymentId) {
      return res.status(400).json({
        message: "Invalid payment data",
      });
    }

    const purchasedPayment = await findPaymentWithCoinPackage(paymentId);

    if (!purchasedPayment) {
      return res.status(404).json({
        message: "Purchased payment not found",
      });
    }

    const gatewayTransactionId =
      paymentInfo?.decodedData?.transaction_code ||
      paymentInfo?.response?.transaction_code ||
      paymentInfo?.response?.ref_id ||
      null;

    const result = await finalizeEsewaCoinPurchase(purchasedPayment, {
      gatewayTransactionId,
      storedMetadata: {
        data,
        verification: paymentInfo,
      },
    });

    if (result.alreadyCompleted) {
      return res.status(200).json({
        message: "Payment already completed",
      });
    }

    return res.status(200).json({
      message: "Payment successful",
      data: result.data,
    });
  } catch (error) {
    console.log(error.message);

    return res.status(500).json({
      message: error,
    });
  }
};

exports.confirmEsewaSdkPaymentController = async (req, res) => {
  try {
    const { paymentId } = req.body;

    if (!paymentId) {
      return res.status(400).json({
        success: false,
        message: "paymentId is required",
      });
    }

    const purchasedPayment = await findPaymentWithCoinPackage(paymentId, {
      userId: req._id,
    });

    if (!purchasedPayment) {
      return res.status(404).json({
        success: false,
        message: "Payment not found",
      });
    }

    if (purchasedPayment.gateway !== "esewa") {
      return res.status(400).json({
        success: false,
        message: "Invalid payment gateway",
      });
    }

    if (purchasedPayment.status !== "initiated") {
      return res.status(400).json({
        success: false,
        message: "Payment cannot be confirmed in its current state",
      });
    }

    const totalAmountStr = Number(purchasedPayment.amount).toFixed(2);
    const statusBody = await getEsewaTransactionStatus({
      transaction_uuid: purchasedPayment.payment_id,
      total_amount: totalAmountStr,
    });

    assertEsewaStatusMatchesExpected(statusBody, {
      transaction_uuid: purchasedPayment.payment_id,
      total_amount: totalAmountStr,
    });

    const gatewayTransactionId =
      statusBody.transaction_code || statusBody.ref_id || null;

    const result = await finalizeEsewaCoinPurchase(purchasedPayment, {
      gatewayTransactionId,
      storedMetadata: {
        sdk_confirm: true,
        status_response: statusBody,
      },
    });

    if (result.alreadyCompleted) {
      return res.status(200).json({
        success: true,
        message: "Payment already completed",
        data: result.data,
      });
    }

    return res.status(200).json({
      success: true,
      message: "Payment successful",
      data: result.data,
    });
  } catch (error) {
    const msg =
      error && typeof error === "object" && error.message
        ? error.message
        : String(error);
    return res.status(500).json({
      success: false,
      message: msg,
    });
  }
};
