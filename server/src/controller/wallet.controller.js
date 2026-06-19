const {
  getUserCoinsService,
  getPaymentHistoryService,
} = require("../services/wallet.service");

exports.getUserCoinsController = async (req, res, next) => {
  const userId = req._id;
  try {
    const result = await getUserCoinsService(userId);
    res.status(200).json({
      success: true,
      message: "User coins fetched successfully",
      data: result.data,
    });
  } catch (error) {
    next(error);
  }
};

exports.getPaymentHistoryController = async (req, res, next) => {
  try {
    const { page, limit, from_date, to_date, status, gateway, user_id } = req.query;

    if (from_date && Number.isNaN(new Date(from_date).getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid from_date. Use ISO date format (YYYY-MM-DD)",
      });
    }

    if (to_date && Number.isNaN(new Date(to_date).getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid to_date. Use ISO date format (YYYY-MM-DD)",
      });
    }

    const result = await getPaymentHistoryService({
      requesterUserId: req._id,
      requesterRole: req.user?.role,
      page,
      limit,
      fromDate: from_date,
      toDate: to_date,
      status,
      gateway,
      userId: user_id,
    });

    return res.status(200).json(result);
  } catch (error) {
    return next(error);
  }
};
