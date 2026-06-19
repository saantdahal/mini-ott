const multer = require("multer");
const path = require("path");
const os = require("os");
const crypto = require("crypto");

const ALLOWED_VIDEO_TYPES = [
  "video/mp4",
  "video/quicktime",
  "video/x-matroska",
  "video/webm",
  "video/avi",
  "video/x-msvideo",
  "video/mpeg",
];

const MAX_VIDEO_SIZE = 50 * 1024 * 1024 * 1024; // 50 GB

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, os.tmpdir());
  },
  filename: (req, file, cb) => {
    const uniqueId = crypto.randomUUID
      ? crypto.randomUUID()
      : crypto.randomBytes(16).toString("hex");
    const ext = path.extname(file.originalname) || ".mp4";
    cb(null, `ott-upload-${uniqueId}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  if (ALLOWED_VIDEO_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        `Invalid video type: ${file.mimetype}. Allowed: ${ALLOWED_VIDEO_TYPES.join(", ")}`
      ),
      false
    );
  }
};

const videoUploadMiddleware = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: MAX_VIDEO_SIZE,
  },
});

module.exports = videoUploadMiddleware;
