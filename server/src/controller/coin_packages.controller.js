const {
  createCoinPackagesService,
  getAllCoinPackagesService,
} = require("../services/coin_packages.service");

const createCoinPackages = async (req, res) => {
  try {
    const data = req.body;
    const result = await createCoinPackagesService(data);
    return res.status(201).json({
      success: true,
      message: "Coin Package Created Successfully",
      result,
    });
  } catch (error) {
    const msg = String(error?.message || "Internal Server Error");
    const statusCode =
      error?.statusCode ||
      error?.status ||
      (msg.includes("Invalid coin package data") ||
      msg.includes("Invalid sort_order")
        ? 400
        : msg.includes("Sort order") && msg.includes("already")
          ? 409
          : 500);

    return res.status(statusCode).json({
      success: false,
      message: msg,
      code: error?.code,
      details: error?.details,
    });
  }
};

const getAllCoinPackages = async (req, res) => {
  try {
    const result = await getAllCoinPackagesService();
    return res.status(200).json({
      success: true,
      message: "Coin Packages fetched successfully",
      result,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
      error: error.message,
    });
  }
};

module.exports = {
  createCoinPackages,
  getAllCoinPackages,
};
