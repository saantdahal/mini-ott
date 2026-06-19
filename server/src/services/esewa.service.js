const axios = require("axios");
const crypto = require("crypto");

function requireEnv(name) {
  const value = process.env[name];
  if (!value || String(value).trim() === "") {
    throw new Error(`${name} is not set in environment (.env)`);
  }
  return value;
}

async function getEsewaPaymentHash({ amount, transaction_uuid }) {
  try {
    const productCode = requireEnv("ESEWA_PRODUCT_CODE");
    const secretKey = requireEnv("ESEWA_SECRET_KEY");

    const numericAmount = Number(amount);
    if (!Number.isFinite(numericAmount) || numericAmount <= 0) {
      throw new Error("Invalid amount");
    }

    if (!transaction_uuid) {
      throw new Error("transaction_uuid is required");
    }

    const totalAmount = numericAmount.toFixed(2);
    const data = `total_amount=${totalAmount},transaction_uuid=${transaction_uuid},product_code=${productCode}`;
    const hash = crypto
      .createHmac("sha256", secretKey)
      .update(data)
      .digest("base64");

    return {
      signature: hash,
      signed_field_names: "total_amount,transaction_uuid,product_code",
    };
  } catch (error) {
    throw error;
  }
}

async function verifyEsewaPayment(encodedData) {
  try {
    const productCode = requireEnv("ESEWA_PRODUCT_CODE");
    const secretKey = requireEnv("ESEWA_SECRET_KEY");
    const gatewayUrl = requireEnv("ESEWA_GATEWAY_URL");

    let decodedJson;
    try {
      decodedJson = Buffer.from(String(encodedData), "base64").toString("utf8");
    } catch (e) {
      throw { message: "Invalid base64 data" };
    }

    let decodedData;
    try {
      decodedData = JSON.parse(decodedJson);
    } catch (e) {
      throw { message: "Invalid data JSON" };
    }

    if (!decodedData?.transaction_uuid || !decodedData?.total_amount) {
      throw { message: "Missing required fields", decodedData };
    }

    let headersList = {
      Accept: "application/json",
      "Content-Type": "application/json",
    };

    const data = `transaction_code=${decodedData.transaction_code},status=${decodedData.status},total_amount=${decodedData.total_amount},transaction_uuid=${decodedData.transaction_uuid},product_code=${productCode},signed_field_names=${decodedData.signed_field_names}`;
    const hash = crypto
      .createHmac("sha256", secretKey)
      .update(data)
      .digest("base64");

    console.log(hash);
    console.log(decodedData.signature);
    let reqOptions = {
      url: `${gatewayUrl}/api/epay/transaction/status/?product_code=${productCode}&total_amount=${decodedData.total_amount}&transaction_uuid=${decodedData.transaction_uuid}`,
      method: "GET",
      headers: headersList,
    };
    if (hash !== decodedData.signature) {
      throw { message: "Invalid Info", decodedData };
    }
    let response = await axios.request(reqOptions);
    assertEsewaStatusMatchesExpected(response.data, {
      transaction_uuid: decodedData.transaction_uuid,
      total_amount: decodedData.total_amount,
    });
    return { response: response.data, decodedData };
  } catch (error) {
    throw error;
  }
}

function assertEsewaStatusMatchesExpected(statusBody, { transaction_uuid, total_amount }) {
  if (!statusBody || statusBody.status !== "COMPLETE") {
    throw { message: "eSewa transaction not complete", statusBody };
  }
  if (String(statusBody.transaction_uuid) !== String(transaction_uuid)) {
    throw { message: "eSewa transaction_uuid mismatch", statusBody };
  }
  if (Number(statusBody.total_amount) !== Number(total_amount)) {
    throw { message: "eSewa total_amount mismatch", statusBody };
  }
}

async function getEsewaTransactionStatus({ transaction_uuid, total_amount }) {
  const productCode = requireEnv("ESEWA_PRODUCT_CODE");
  const gatewayUrl = requireEnv("ESEWA_GATEWAY_URL");

  if (!transaction_uuid) {
    throw new Error("transaction_uuid is required");
  }
  const totalStr =
    typeof total_amount === "number"
      ? total_amount.toFixed(2)
      : String(total_amount);

  const url = `${gatewayUrl}/api/epay/transaction/status/?product_code=${encodeURIComponent(
    productCode
  )}&total_amount=${encodeURIComponent(totalStr)}&transaction_uuid=${encodeURIComponent(
    String(transaction_uuid)
  )}`;

  const response = await axios.request({
    url,
    method: "GET",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });
  return response.data;
}

module.exports = {
  getEsewaPaymentHash,
  verifyEsewaPayment,
  getEsewaTransactionStatus,
  assertEsewaStatusMatchesExpected,
};
