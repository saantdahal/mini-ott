const axios = require("axios");
const { KHALTI_SECRET_KEY, KHALTI_GATEWAY_URL } = require("../config/env");

function assertKhaltiEnv() {
  if (!KHALTI_SECRET_KEY || String(KHALTI_SECRET_KEY).trim() === "") {
    throw new Error("KHALTI_SECRET_KEY is not set in environment");
  }
  if (!KHALTI_GATEWAY_URL || String(KHALTI_GATEWAY_URL).trim() === "") {
    throw new Error("KHALTI_GATEWAY_URL is not set in environment");
  }
}

function formatAxiosKhaltiError(error, label) {
  const base = error?.message || String(error);
  const data = error?.response?.data;
  if (data == null) {
    return new Error(`${label}: ${base}`);
  }
  if (typeof data === "string") {
    return new Error(`${label}: ${data}`);
  }
  if (typeof data === "object") {
    const detail = data.detail || data.error_key || data.message;
    if (detail) {
      return new Error(`${label}: ${detail}`);
    }
    return new Error(`${label}: ${JSON.stringify(data)}`);
  }
  return new Error(`${label}: ${base}`);
}

exports.verifyKhaltiPayment = async (pidx) => {
  assertKhaltiEnv();
  const headerList = {
    Authorization: `Key ${KHALTI_SECRET_KEY}`,
    "Content-Type": "application/json",
  };

  const bodyContent = JSON.stringify({ pidx });

  const reqOptions = {
    url: `${KHALTI_GATEWAY_URL}/epayment/lookup/`,
    method: "POST",
    headers: headerList,
    data: bodyContent,
  };

  try {
    const response = await axios.request(reqOptions);
    return response.data;
  } catch (error) {
    console.error("Error verifying Khalti payment:", error?.message);
    throw formatAxiosKhaltiError(error, "Khalti lookup failed");
  }
};

exports.initializeKhaltiPayment = async (details) => {
  assertKhaltiEnv();
  const headersList = {
    Authorization: `Key ${KHALTI_SECRET_KEY}`,
    "Content-Type": "application/json",
  };

  const bodyContent = JSON.stringify(details);

  const reqOptions = {
    url: `${KHALTI_GATEWAY_URL}/epayment/initiate/`,
    method: "POST",
    headers: headersList,
    data: bodyContent,
  };
  try {
    const response = await axios.request(reqOptions);
    return response.data;
  } catch (error) {
    console.error("Error initializing Khalti payment:", error?.message);
    if (error?.response?.data != null) {
      console.error(error.response.data);
    }
    throw formatAxiosKhaltiError(error, "Khalti initiate failed");
  }
};
