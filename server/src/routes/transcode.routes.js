const express = require("express");

const auth = require("../middleware/auth");
const {
  startTranscoding,
  getTranscodingStatus,
  getHlsPlaybackParams,
} = require("../controller/transcode.controller");

const router = express.Router();

// Trigger HLS transcoding for a completed upload
router.post("/:videoUploadId", auth, startTranscoding);

// Check transcoding job status
router.get("/:videoUploadId/status", auth, getTranscodingStatus);

module.exports = router;
