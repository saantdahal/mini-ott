/**
 * Quick diagnostic script to test the transcoding pipeline.
 * Usage: node scripts/test-transcode.js <s3_key>
 *
 * This tests: S3 download → FFmpeg transcode → S3 upload
 * without touching the DB.
 */

require("dotenv").config();

const { runTranscodingJob } = require("../src/services/transcoder.service");

const sourceS3Key = process.argv[2];

if (!sourceS3Key) {
  console.error("Usage: node scripts/test-transcode.js <s3_key>");
  console.error("Example: node scripts/test-transcode.js contents/abc/video/xyz_file.mp4");
  process.exit(1);
}

console.log("=== Transcode Pipeline Test ===");
console.log("Source S3 key:", sourceS3Key);
console.log("Bucket:", process.env.AWS_S3_BUCKET_NAME);
console.log("Region:", process.env.AWS_REGION);
console.log("");

runTranscodingJob({
  sourceS3Key,
  contentId: "test-content",
  episodeId: null,
  onProgress: ({ status, percent }) => {
    console.log(`[Progress] ${status} — ${percent}%`);
  },
})
  .then((result) => {
    console.log("");
    console.log("=== SUCCESS ===");
    console.log("Output prefix:", result.outputPathPrefix);
    console.log("Manifest key:", result.outputManifestKey);
    console.log("Files uploaded:", result.filesUploaded);
  })
  .catch((err) => {
    console.error("");
    console.error("=== FAILED ===");
    console.error("Error:", err.message);
    console.error(err.stack);
    process.exit(1);
  });
