const express = require("express");

const auth = require("../middleware/auth");
const videoUpload = require("../middleware/videoUpload");
const {
  initUpload,
  signPart,
  savePart,
  completeUpload,
  abortUpload,
  getUploadStatus,
  getVideoPlaybackUrl,
  uploadVideo,
  presignContentImage,
} = require("../controller/upload.controller");

const router = express.Router();

// Presigned PUT for poster/banner/thumbnail images
router.post("/image/presign", auth, presignContentImage);

// Direct upload + HLS transcode (new flow)
router.post("/video", auth, videoUpload.single("video"), uploadVideo);

// S3 multipart upload (legacy flow)
router.post("/init", auth, initUpload);
router.post("/sign-part", auth, signPart);
router.post("/save-part", auth, savePart);
router.post("/complete", auth, completeUpload);
router.post("/abort", auth, abortUpload);
router.get("/:id/status", auth, getUploadStatus);
router.get("/:id/play-url", auth, getVideoPlaybackUrl);

module.exports = router;
