require("dotenv").config();

const createError = require("http-errors");
const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");
const cors = require("cors");

const indexRouter = require("./src/routes/index");
const authRouter = require("./src/routes/auth.routes");
const userRouter = require("./src/routes/user.route");
const coinPackageRouter = require("./src/routes/coin_packages.routes");
const khaltiRouter = require("./src/routes/khalti-payment.routes");
const esewaRouter = require("./src/routes/esewa-payment.routes");
const uploadRouter = require("./src/routes/upload.routes");
const walletRouter = require("./src/routes/wallet.routes");
const transcodeRouter = require("./src/routes/transcode.routes");
const streamRouter = require("./src/routes/stream.routes");
const contentRouter = require("./src/routes/content.routes");
const { testPostgresConnection } = require("./src/config/db/database");
const { applyAssociations } = require("./src/model/association");
const { setupSwagger } = require("./src/config/swagger");
const { initCloudinary } = require("./src/config/cloudinary");
const { initFirebase } = require("./src/config/firebase");
const { validateCloudFrontConfig } = require("./src/config/cloudfront");
const { deleteUserAccount } = require("./src/services/user.service");
const { deleteUnverifiedUsers } = require("./src/jobs/cron");
const { startTranscodeWorker } = require("./src/jobs/transcodeWorker");

const app = express();

initCloudinary();
initFirebase();
validateCloudFrontConfig();
applyAssociations();
deleteUnverifiedUsers();
startTranscodeWorker();

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));
const allowedOrigins = (
  process.env.CORS_ALLOWED_ORIGINS ||
  "http://localhost:3000,http://localhost:3001,http://localhost:8080"
)
  .split(",")
  .map((o) => o.trim())
  .filter(Boolean);

const isLocalDevOrigin = (origin) => {
  try {
    const { hostname } = new URL(origin);
    return ["localhost", "127.0.0.1", "::1"].includes(hostname);
  } catch (_) {
    return false;
  }
};

app.use(
  cors({
    origin: (origin, cb) => {
      if (!origin || allowedOrigins.includes(origin)) return cb(null, true);

      if (process.env.NODE_ENV !== "production" && isLocalDevOrigin(origin)) {
        return cb(null, true);
      }

      return cb(new Error(`Origin ${origin} not allowed by CORS`));
    },
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  }),
);
// routes here
app.use("/", indexRouter);
app.use("/api/auth", authRouter);
app.use("/api/users", userRouter);
app.use("/api/coin-packages", coinPackageRouter);
app.use("/api/khalti", khaltiRouter);
app.use("/api/esewa", esewaRouter);
app.use("/api/uploads", uploadRouter);
app.use("/api/wallet", walletRouter);
app.use("/api/transcode", transcodeRouter);
app.use("/api/stream", streamRouter);
app.use("/api/content", contentRouter);
setupSwagger(app);
// database connection
testPostgresConnection();
app.use(function (req, res, next) {
  next(createError(404));
});
// error handlerss
app.use(function (err, req, res, next) {
  const status = err.status || 500;
  const message = err.message || "Internal Server Error";

  res.status(status).json({
    success: false,
    message,
    ...(req.app.get("env") === "development" ? { stack: err.stack } : {}),
  });
});

module.exports = app;
