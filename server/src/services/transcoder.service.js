const path = require("path");
const fs = require("fs");
const os = require("os");
const { promisify } = require("util");
const ffmpeg = require("fluent-ffmpeg");
const ffmpegInstaller = require("@ffmpeg-installer/ffmpeg");
const {
  S3Client,
  PutObjectCommand,
  DeleteObjectsCommand,
} = require("@aws-sdk/client-s3");

ffmpeg.setFfmpegPath(ffmpegInstaller.path);

const mkdir = promisify(fs.mkdir);
const readdir = promisify(fs.readdir);
const rm = promisify(fs.rm);
const stat = promisify(fs.stat);

const REGION = () => process.env.AWS_REGION || "us-east-1";
const BUCKET = () => process.env.AWS_S3_BUCKET_NAME;

let cachedS3 = null;
const getS3 = () => {
  if (cachedS3) return cachedS3;
  cachedS3 = new S3Client({ region: REGION() });
  return cachedS3;
};

// ─── S3 helpers ──────────────────────────────────────────────────────

const uploadFileToS3 = async (filePath, s3Key, contentType) => {
  const s3 = getS3();
  await s3.send(
    new PutObjectCommand({
      Bucket: BUCKET(),
      Key: s3Key,
      Body: fs.createReadStream(filePath),
      ContentType: contentType,
    })
  );
};

const uploadDirToS3 = async (dirPath, s3Prefix, onFileUploaded) => {
  const files = await readdir(dirPath);
  let uploaded = 0;

  for (const file of files) {
    const filePath = path.join(dirPath, file);
    const s3Key = `${s3Prefix}${file}`;

    let contentType = "application/octet-stream";
    if (file.endsWith(".m3u8")) contentType = "application/vnd.apple.mpegurl";
    if (file.endsWith(".ts")) contentType = "video/mp2t";

    await uploadFileToS3(filePath, s3Key, contentType);
    uploaded++;
    if (onFileUploaded) onFileUploaded(uploaded, files.length);
  }

  return { filesUploaded: uploaded };
};

const deleteS3Prefix = async (prefix) => {
  // List and delete all objects under the prefix
  const { ListObjectsV2Command } = require("@aws-sdk/client-s3");
  const s3 = getS3();
  const bucket = BUCKET();

  const listRes = await s3.send(
    new ListObjectsV2Command({ Bucket: bucket, Prefix: prefix })
  );

  const objects = (listRes.Contents || []).map((o) => ({ Key: o.Key }));
  if (objects.length === 0) return;

  await s3.send(
    new DeleteObjectsCommand({
      Bucket: bucket,
      Delete: { Objects: objects },
    })
  );
};

// ─── HLS presets ─────────────────────────────────────────────────────

const HLS_OUTPUTS = [
  { label: "480p", width: 854, height: 480, videoBitrate: "1500k", audioBitrate: "128k" },
  { label: "720p", width: 1280, height: 720, videoBitrate: "3000k", audioBitrate: "128k" },
  { label: "1080p", width: 1920, height: 1080, videoBitrate: "6000k", audioBitrate: "192k" },
];

// ─── Phase 1: Instant segmentation (no re-encode) ───────────────────

/**
 * Segment a video into HLS using -c copy (no re-encoding).
 * Takes seconds even for large files.
 *
 * @param {string} localFilePath - Path to the source video file
 * @param {string} outputDir - Directory to write HLS files
 * @returns {Promise<string>} Path to the generated playlist
 */
const segmentCopy = (localFilePath, outputDir) => {
  return new Promise((resolve, reject) => {
    const playlistPath = path.join(outputDir, "original.m3u8");
    const segmentPattern = path.join(outputDir, "original_%03d.ts");

    ffmpeg(localFilePath)
      .outputOptions([
        "-c copy",           // no re-encoding
        "-hls_time 6",
        "-hls_list_size 0",
        "-hls_segment_filename", segmentPattern,
        "-f hls",
      ])
      .output(playlistPath)
      .on("start", (cmd) => {
        console.log(`[Transcoder] Segment copy cmd: ${cmd}`);
      })
      .on("end", () => resolve(playlistPath))
      .on("error", (err) => reject(err))
      .run();
  });
};

/**
 * Generate a master playlist pointing to a single variant.
 */
const generateSingleVariantMaster = (outputDir, variantPlaylist, width, height, bandwidth) => {
  const lines = [
    "#EXTM3U",
    `#EXT-X-STREAM-INF:BANDWIDTH=${bandwidth},RESOLUTION=${width}x${height}`,
    variantPlaylist,
  ];
  const masterPath = path.join(outputDir, "master.m3u8");
  fs.writeFileSync(masterPath, lines.join("\n") + "\n");
  return masterPath;
};

/**
 * Phase 1: Instant HLS from local file — segments with copy codec, uploads to S3.
 * Video is immediately playable after this step.
 *
 * @param {object} params
 * @param {string} params.localFilePath
 * @param {string} params.contentId
 * @param {string} [params.episodeId]
 * @returns {{ outputPathPrefix: string, outputManifestKey: string, filesUploaded: number }}
 */
const instantSegment = async ({ localFilePath, contentId, episodeId }) => {
  const bucket = BUCKET();
  if (!bucket) {
    const err = new Error("AWS_S3_BUCKET_NAME is not configured.");
    err.status = 500;
    throw err;
  }

  if (!localFilePath || !fs.existsSync(localFilePath)) {
    throw new Error(`Source file not found: ${localFilePath}`);
  }

  const inputStats = await stat(localFilePath);
  console.log(
    `[Transcoder] Phase 1 — instant segment: ${(inputStats.size / (1024 * 1024)).toFixed(1)} MB`
  );

  let outputPathPrefix;
  if (episodeId) {
    outputPathPrefix = `contents/${contentId}/episodes/${episodeId}/hls/`;
  } else {
    outputPathPrefix = `contents/${contentId}/hls/`;
  }

  const tmpDir = path.join(
    os.tmpdir(),
    `ott-segment-${Date.now()}-${Math.random().toString(36).slice(2)}`
  );
  await mkdir(tmpDir, { recursive: true });

  try {
    // Segment with copy codec (instant)
    console.log("[Transcoder] Segmenting with -c copy...");
    await segmentCopy(localFilePath, tmpDir);

    // Generate master playlist pointing to the single variant
    generateSingleVariantMaster(tmpDir, "original.m3u8", 1920, 1080, 8000000);

    // Upload to S3
    console.log("[Transcoder] Uploading instant HLS to S3...");
    const { filesUploaded } = await uploadDirToS3(tmpDir, outputPathPrefix);

    console.log(`[Transcoder] Phase 1 done: ${filesUploaded} files → s3://${bucket}/${outputPathPrefix}`);

    return {
      outputPathPrefix,
      outputManifestKey: `${outputPathPrefix}master.m3u8`,
      filesUploaded,
    };
  } finally {
    try {
      await rm(tmpDir, { recursive: true, force: true });
    } catch {
      console.warn("[Transcoder] Failed to cleanup segment temp dir");
    }
  }
};

// ─── Phase 2: Adaptive transcode (background) ───────────────────────

/**
 * Transcode a single variant to HLS (re-encodes).
 */
const transcodeVariant = (inputPath, outputDir, preset) => {
  return new Promise((resolve, reject) => {
    const playlistName = `${preset.label}.m3u8`;
    const segmentPattern = path.join(outputDir, `${preset.label}_%03d.ts`);
    const playlistPath = path.join(outputDir, playlistName);

    ffmpeg(inputPath)
      .videoCodec("libx264")
      .audioCodec("aac")
      .size(`${preset.width}x?`)
      .videoBitrate(preset.videoBitrate)
      .audioBitrate(preset.audioBitrate)
      .outputOptions([
        "-preset fast",
        "-g 48",
        "-sc_threshold 0",
        "-hls_time 6",
        "-hls_list_size 0",
        "-hls_segment_filename", segmentPattern,
        "-f hls",
      ])
      .output(playlistPath)
      .on("start", (cmd) => {
        console.log(`[Transcoder] FFmpeg cmd: ${cmd}`);
      })
      .on("stderr", (line) => {
        if (line.includes("time=") || line.includes("Error")) {
          console.log(`[Transcoder][${preset.label}] ${line.trim()}`);
        }
      })
      .on("end", () => resolve({ preset, playlistName, playlistPath }))
      .on("error", (err) => reject(err))
      .run();
  });
};

/**
 * Generate an adaptive master playlist with all variants.
 */
const generateAdaptiveMaster = (outputDir, variants) => {
  const lines = ["#EXTM3U"];

  for (const v of variants) {
    const bandwidth = parseInt(v.preset.videoBitrate) * 1000;
    lines.push(
      `#EXT-X-STREAM-INF:BANDWIDTH=${bandwidth},RESOLUTION=${v.preset.width}x${v.preset.height}`
    );
    lines.push(v.playlistName);
  }

  const masterPath = path.join(outputDir, "master.m3u8");
  fs.writeFileSync(masterPath, lines.join("\n") + "\n");
  return masterPath;
};

/**
 * Phase 2: Adaptive bitrate transcode — re-encodes to multiple resolutions,
 * then replaces the Phase 1 HLS in S3.
 *
 * @param {object} params
 * @param {string} params.localFilePath - Source video (still on disk from Phase 1)
 * @param {string} params.outputPathPrefix - S3 prefix (same as Phase 1)
 * @param {function} [params.onProgress] - Progress callback ({ status, percent })
 * @returns {{ filesUploaded: number }}
 */
const adaptiveTranscode = async ({ localFilePath, outputPathPrefix, onProgress }) => {
  const bucket = BUCKET();

  if (!localFilePath || !fs.existsSync(localFilePath)) {
    throw new Error(`Source file not found for adaptive transcode: ${localFilePath}`);
  }

  console.log("[Transcoder] Phase 2 — adaptive transcode starting...");

  const tmpDir = path.join(
    os.tmpdir(),
    `ott-adaptive-${Date.now()}-${Math.random().toString(36).slice(2)}`
  );
  await mkdir(tmpDir, { recursive: true });

  try {
    // Transcode each variant
    const variants = [];
    for (let i = 0; i < HLS_OUTPUTS.length; i++) {
      const preset = HLS_OUTPUTS[i];
      console.log(`[Transcoder] Encoding ${preset.label}...`);

      if (onProgress) {
        const pct = Math.floor((i / HLS_OUTPUTS.length) * 80);
        onProgress({ status: `encoding_${preset.label}`, percent: pct });
      }

      const result = await transcodeVariant(localFilePath, tmpDir, preset);
      variants.push(result);
      console.log(`[Transcoder] ${preset.label} done`);
    }

    // Generate adaptive master playlist
    if (onProgress) onProgress({ status: "generating_manifest", percent: 82 });
    generateAdaptiveMaster(tmpDir, variants);

    // Delete the old Phase 1 files from S3
    if (onProgress) onProgress({ status: "replacing_hls", percent: 85 });
    console.log("[Transcoder] Deleting Phase 1 HLS from S3...");
    try {
      await deleteS3Prefix(outputPathPrefix);
    } catch (delErr) {
      console.warn("[Transcoder] Failed to delete old HLS:", delErr.message);
    }

    // Upload adaptive HLS to S3 (same prefix — seamless replacement)
    if (onProgress) onProgress({ status: "uploading_hls", percent: 88 });
    console.log("[Transcoder] Uploading adaptive HLS to S3...");

    const { filesUploaded } = await uploadDirToS3(
      tmpDir,
      outputPathPrefix,
      (uploaded, total) => {
        if (onProgress) {
          const pct = 88 + Math.floor((uploaded / total) * 11);
          onProgress({ status: "uploading_hls", percent: Math.min(pct, 99) });
        }
      }
    );

    console.log(
      `[Transcoder] Phase 2 done: ${filesUploaded} adaptive files → s3://${bucket}/${outputPathPrefix}`
    );

    if (onProgress) onProgress({ status: "complete", percent: 100 });

    return { filesUploaded };
  } finally {
    try {
      await rm(tmpDir, { recursive: true, force: true });
    } catch {
      console.warn("[Transcoder] Failed to cleanup adaptive temp dir");
    }
  }
};

/**
 * Delete the local source file.
 */
const cleanupSourceFile = async (filePath) => {
  try {
    if (filePath && fs.existsSync(filePath)) {
      await rm(filePath, { force: true });
      console.log("[Transcoder] Source file cleaned up");
    }
  } catch {
    console.warn(`[Transcoder] Failed to cleanup source: ${filePath}`);
  }
};

module.exports = {
  instantSegment,
  adaptiveTranscode,
  cleanupSourceFile,
  HLS_OUTPUTS,
};
