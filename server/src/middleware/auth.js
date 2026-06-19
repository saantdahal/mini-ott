const { verifyAccessToken } = require("../utils/token");
const DeviceSessions = require("../model/device_sessions.model");
const crypto = require("crypto");

const hashToken = (token) =>
  crypto.createHash("sha256").update(token).digest("hex");

const auth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || "";
    const token = authHeader.startsWith("Bearer ")
      ? authHeader.slice(7).trim()
      : null;

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "No token. Access denied.",
      });
    }

    const decoded = verifyAccessToken(token);
    return DeviceSessions.findOne({
      where: {
        user_id: decoded.id,
        access_token_hash: hashToken(token),
        status: "active",
      },
    })
      .then((session) => {
        if (!session) {
          return res.status(401).json({
            success: false,
            message: "Invalid token.",
          });
        }

        req.user = decoded;
        req._id = decoded.id;
        req.authToken = token;
        req.deviceSession = session;
        return next();
      })
      .catch(() =>
        res.status(401).json({
          success: false,
          message: "Invalid token.",
        }),
      );
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid token.",
    });
  }
};

module.exports = auth;
