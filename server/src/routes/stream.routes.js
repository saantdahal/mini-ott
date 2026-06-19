const express = require("express");

const auth = require("../middleware/auth");
const { getHlsPlaybackParams } = require("../controller/transcode.controller");

const router = express.Router();

// Get signed HLS playback params for a transcoded upload
router.get("/:videoUploadId/hls", auth, getHlsPlaybackParams);

module.exports = router;
