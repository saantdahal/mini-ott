const crypto = require("crypto");

const Contents = require("../model/contents.model");
const Seasons = require("../model/seasons.model");
const Episodes = require("../model/episodes.model");
const VideoUploads = require("../model/video_uploads.model");

const {
  createMultipartUpload,
  generatePresignedPartUrl,
  generatePresignedPutUrl,
  completeMultipartUpload,
  abortMultipartUpload,
  getBucketName,
} = require("../services/s3.service");
const {
  generateSignedPlaybackUrl,
  getPublicCloudFrontUrl,
} = require("../services/cloudfront.service");
const { instantSegment } = require("../services/transcoder.service");
const { addTranscodeJob } = require("../jobs/transcodeQueue");
const TranscodingJobs = require("../model/transcoding_jobs.model");

const {
  validateInitUploadPayload,
  validateSignPartPayload,
  validateSavePartPayload,
  validateCompleteUploadPayload,
  validateAbortUploadPayload,
} = require("../validator/upload.validator");

const DEFAULT_PRESIGN_EXPIRY_SECONDS = 10 * 60;
const DEFAULT_MAX_FILE_SIZE_BYTES = 50 * 1024 * 1024 * 1024; // 50GB

const requireAuth = (req) => {
  if (!req.user) {
    const err = new Error("Authentication required");
    err.status = 401;
    throw err;
  }
};

const generateUuid = () => {
  if (typeof crypto.randomUUID === "function") {
    return crypto.randomUUID();
  }

  const bytes = crypto.randomBytes(16);
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  const hex = bytes.toString("hex");
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(
    16,
    20,
  )}-${hex.slice(20)}`;
};

const getMaxFileSizeBytes = () => {
  const raw = process.env.UPLOAD_MAX_FILE_SIZE_BYTES;
  if (!raw) return DEFAULT_MAX_FILE_SIZE_BYTES;
  const parsed = Number(raw);
  return Number.isFinite(parsed) && parsed > 0
    ? parsed
    : DEFAULT_MAX_FILE_SIZE_BYTES;
};

const getAllowedMimeTypes = () => {
  const raw = process.env.UPLOAD_ALLOWED_MIME_TYPES;
  if (raw && raw.trim()) {
    return raw
      .split(",")
      .map((v) => v.trim())
      .filter(Boolean);
  }

  return ["video/mp4", "video/quicktime", "video/x-matroska"];
};

const requireAdmin = (req) => {
  if (!req.user || req.user.role !== "admin") {
    const err = new Error("Only admin can upload videos");
    err.status = 403;
    throw err;
  }
};

const buildS3Key = ({
  uploadFor,
  contentId,
  seasonId,
  episodeId,
  fileName,
}) => {
  const safeFileName = String(fileName || "file")
    .replace(/\s+/g, "_")
    .replace(/[^a-zA-Z0-9._-]/g, "");

  const keyId = generateUuid();
  const ts = Date.now();

  if (uploadFor === "episode_video") {
    return `contents/${contentId}/episodes/${episodeId}/video/${ts}_${keyId}_${safeFileName}`;
  }

  if (uploadFor === "season_trailer") {
    return `contents/${contentId}/seasons/${seasonId}/trailer/${ts}_${keyId}_${safeFileName}`;
  }

  // movie_trailer
  return `contents/${contentId}/trailer/${ts}_${keyId}_${safeFileName}`;
};

const initUpload = async (req, res) => {
  try {
    requireAdmin(req);

    const payload = validateInitUploadPayload(req.body);

    const maxSize = getMaxFileSizeBytes();
    if (payload.file_size > maxSize) {
      return res.status(400).json({
        success: false,
        message: `File too large. Max allowed is ${maxSize} bytes`,
      });
    }

    const allowedMimeTypes = getAllowedMimeTypes();
    if (!allowedMimeTypes.includes(payload.mime_type)) {
      return res.status(400).json({
        success: false,
        message: `Invalid mime type. Allowed: ${allowedMimeTypes.join(", ")}`,
      });
    }

    // const content = await Contents.findByPk(payload.content_id);
    // if (!content) {
    //   return res.status(404).json({
    //     success: false,
    //     message: "Content not found",
    //   });
    // }

    let season = null;
    let episode = null;

    // if (payload.season_id) {
    //   season = await Seasons.findByPk(payload.season_id);
    //   if (!season || season.content_id !== payload.content_id) {
    //     return res.status(400).json({
    //       success: false,
    //       message: "Invalid season_id for this content",
    //     });
    //   }
    // }

    if (payload.episode_id) {
      //   episode = await Episodes.findByPk(payload.episode_id);
      //   if (!episode || episode.content_id !== payload.content_id) {
      //     return res.status(400).json({
      //       success: false,
      //       message: "Invalid episode_id for this content",
      //     });
      //   }
      //   if (payload.season_id && episode.season_id !== payload.season_id) {
      //     return res.status(400).json({
      //       success: false,
      //       message: "episode_id does not belong to provided season_id",
      //     });
      //   }
      // }
      // if (payload.upload_for === "episode_video" && !payload.episode_id) {
      //   return res.status(400).json({
      //     success: false,
      //     message: "episode_id is required for upload_for=episode_video",
      //   });
      // }
      // if (payload.upload_for === "season_trailer" && !payload.season_id) {
      //   return res.status(400).json({
      //     success: false,
      //     message: "season_id is required for upload_for=season_trailer",
      //   });
    }

    const s3Key = buildS3Key({
      uploadFor: payload.upload_for,
      contentId: payload.content_id,
      seasonId: payload.season_id,
      episodeId: payload.episode_id,
      fileName: payload.file_name,
    });

    const { uploadId } = await createMultipartUpload({
      key: s3Key,
      contentType: payload.mime_type,
    });

    const record = await VideoUploads.create({
      content_id: payload.content_id,
      season_id: payload.season_id,
      episode_id: payload.episode_id,
      upload_for: payload.upload_for,
      bucket_name: getBucketName(),
      s3_key: s3Key,
      upload_id: uploadId,
      status: "initiated",
      file_name: payload.file_name,
      mime_type: payload.mime_type,
      file_size: payload.file_size,
      parts_uploaded: null,
      initiated_by: req.user.id,
      error_message: null,
    });

    return res.status(201).json({
      success: true,
      message: "Upload initiated",
      video_upload_id: record.video_upload_id,
      upload_id: uploadId,
      s3_key: s3Key,
      status: record.status,
    });
  } catch (error) {
    const status = error.status || 400;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

const signPart = async (req, res) => {
  try {
    requireAdmin(req);

    const payload = validateSignPartPayload(req.body);

    const record = await VideoUploads.findByPk(payload.video_upload_id);
    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Upload not found",
      });
    }

    if (!["initiated", "uploading"].includes(record.status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot sign parts when status=${record.status}`,
      });
    }

    const expiresIn =
      Number(process.env.UPLOAD_PRESIGN_EXPIRY_SECONDS) ||
      DEFAULT_PRESIGN_EXPIRY_SECONDS;

    const url = await generatePresignedPartUrl({
      key: record.s3_key,
      uploadId: record.upload_id,
      partNumber: payload.part_number,
      expiresInSeconds: expiresIn,
    });

    if (record.status !== "uploading") {
      await record.update({ status: "uploading" });
    }

    return res.status(200).json({
      success: true,
      message: "Presigned URL generated",
      url,
      expires_in_seconds: expiresIn,
    });
  } catch (error) {
    const status = error.status || 400;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

const savePart = async (req, res) => {
  try {
    requireAdmin(req);

    const payload = validateSavePartPayload(req.body);

    const record = await VideoUploads.findByPk(payload.video_upload_id);
    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Upload not found",
      });
    }

    if (!["initiated", "uploading"].includes(record.status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot save part when status=${record.status}`,
      });
    }

    const existing = Array.isArray(record.parts_uploaded)
      ? record.parts_uploaded
      : [];

    const alreadySaved = existing.some(
      (p) => p.partNumber === payload.part_number,
    );

    if (alreadySaved) {
      return res.status(200).json({
        success: true,
        message: "Part already recorded",
        parts_uploaded: existing,
      });
    }

    const updated = [
      ...existing,
      { partNumber: payload.part_number, etag: payload.etag },
    ];

    await record.update({
      parts_uploaded: updated,
      status: "uploading",
    });

    return res.status(200).json({
      success: true,
      message: "Part saved",
      parts_uploaded: updated,
    });
  } catch (error) {
    const status = error.status || 400;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

// No longer used — replaced by two-phase flow in uploadVideo

const completeUpload = async (req, res) => {
  try {
    requireAdmin(req);

    const payload = validateCompleteUploadPayload(req.body);

    const record = await VideoUploads.findByPk(payload.video_upload_id);
    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Upload not found",
      });
    }

    if (!["initiated", "uploading"].includes(record.status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot complete upload when status=${record.status}`,
      });
    }

    const result = await completeMultipartUpload({
      key: record.s3_key,
      uploadId: record.upload_id,
      parts: payload.parts,
    });

    await record.update({
      status: "uploaded",
      parts_uploaded: payload.parts,
      error_message: null,
    });

    if (record.upload_for === "episode_video") {
      await Episodes.update(
        { video_key: record.s3_key },
        { where: { episode_id: record.episode_id } },
      );
    } else if (record.upload_for === "movie_trailer") {
      await Contents.update(
        { trailer_key: record.s3_key },
        { where: { content_id: record.content_id } },
      );
    } else if (record.upload_for === "season_trailer") {
      await Seasons.update(
        { trailer_key: record.s3_key },
        { where: { season_id: record.season_id } },
      );
    }

    return res.status(200).json({
      success: true,
      message: "Upload completed",
      status: "uploaded",
      s3_key: record.s3_key,
      location: result.Location || null,
      etag: result.ETag || null,
    });
  } catch (error) {
    const status = error.status || 400;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

const abortUpload = async (req, res) => {
  try {
    requireAdmin(req);

    const payload = validateAbortUploadPayload(req.body);

    const record = await VideoUploads.findByPk(payload.video_upload_id);
    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Upload not found",
      });
    }

    if (["aborted", "uploaded"].includes(record.status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot abort upload when status=${record.status}`,
      });
    }

    await abortMultipartUpload({
      key: record.s3_key,
      uploadId: record.upload_id,
    });

    await record.update({ status: "aborted" });

    return res.status(200).json({
      success: true,
      message: "Upload aborted",
      status: "aborted",
    });
  } catch (error) {
    const status = error.status || 400;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

const getUploadStatus = async (req, res) => {
  try {
    requireAdmin(req);

    const { id } = req.params;
    const record = await VideoUploads.findByPk(id);

    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Upload not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Upload status",
      result: {
        video_upload_id: record.video_upload_id,
        content_id: record.content_id,
        season_id: record.season_id,
        episode_id: record.episode_id,
        upload_for: record.upload_for,
        s3_key: record.s3_key,
        upload_id: record.upload_id,
        status: record.status,
        file_name: record.file_name,
        mime_type: record.mime_type,
        file_size: record.file_size,
        parts_uploaded: record.parts_uploaded,
        initiated_by: record.initiated_by,
        error_message: record.error_message,
        created_at: record.created_at,
        updated_at: record.updated_at,
      },
    });
  } catch (error) {
    const status = error.status || 400;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

const getVideoPlaybackUrl = async (req, res) => {
  try {
    requireAuth(req);

    const { id } = req.params;
    const record = await VideoUploads.findByPk(id);

    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Upload not found",
      });
    }

    if (record.status !== "uploaded") {
      return res.status(400).json({
        success: false,
        message: `Cannot generate playback URL when status=${record.status}. Upload must be completed first.`,
      });
    }

    if (!record.bucket_name || !record.s3_key) {
      return res.status(400).json({
        success: false,
        message: "Upload record is missing bucket_name or s3_key",
      });
    }

    const { url, expiresIn } = generateSignedPlaybackUrl(record.s3_key);

    return res.status(200).json({
      success: true,
      message: "Playback URL generated",
      data: {
        url,
        expires_in: expiresIn,
      },
    });
  } catch (error) {
    const status = error.status || 500;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

// ─── Direct upload + transcode (no S3 intermediate) ──────────────────
// POST /api/uploads/video
// Accepts video file via multer → transcodes to HLS → uploads only HLS to S3

const uploadVideo = async (req, res) => {
  try {
    requireAdmin(req);

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No video file provided",
      });
    }

    const {
      content_id,
      season_id,
      episode_id,
      upload_for = "episode_video",
    } = req.body;

    if (!content_id) {
      return res.status(400).json({
        success: false,
        message: "content_id is required",
      });
    }

    const localFilePath = req.file.path;

    // Build the HLS output path prefix
    let outputPathPrefix;
    if (episode_id) {
      outputPathPrefix = `contents/${content_id}/episodes/${episode_id}/hls/`;
    } else if (season_id) {
      outputPathPrefix = `contents/${content_id}/seasons/${season_id}/hls/`;
    } else {
      outputPathPrefix = `contents/${content_id}/hls/`;
    }

    const hlsManifestKey = `${outputPathPrefix}master.m3u8`;

    // Cancel any in-progress transcode jobs for the same episode/content
    // so the old Phase 2 doesn't overwrite this new upload's HLS files
    const cancelWhere = episode_id
      ? { episode_id, status: ["queued", "progressing", "pending"] }
      : { content_id, status: ["queued", "progressing", "pending"] };
    const { Op } = require("sequelize");
    await TranscodingJobs.update(
      { status: "cancelled", error_message: "Superseded by new upload" },
      { where: { ...cancelWhere, status: { [Op.in]: cancelWhere.status } } },
    );

    // ── Phase 1: Instant segment (copy codec → HLS → S3) ──────────
    console.log(
      `[UploadVideo] Phase 1 — instant segmentation for ${req.file.originalname}`,
    );
    const segResult = await instantSegment({
      localFilePath,
      contentId: content_id,
      episodeId: episode_id,
    });

    // Create video_uploads record (status = uploaded — playable immediately)
    const record = await VideoUploads.create({
      content_id,
      season_id: season_id || null,
      episode_id: episode_id || null,
      upload_for,
      bucket_name: getBucketName(),
      s3_key: hlsManifestKey,
      upload_id: null,
      status: "uploaded",
      file_name: req.file.originalname,
      mime_type: req.file.mimetype,
      file_size: req.file.size,
      parts_uploaded: null,
      initiated_by: req.user.id,
      error_message: null,
    });

    // Update stream_manifest_key on episode or content
    if (episode_id) {
      await Episodes.update(
        { stream_manifest_key: hlsManifestKey },
        { where: { episode_id } },
      );
    } else if (content_id) {
      await Contents.update(
        { stream_manifest_key: hlsManifestKey },
        { where: { content_id } },
      );
    }

    // ── Phase 2: Queue adaptive transcode (BullMQ background job) ──
    const job = await TranscodingJobs.create({
      video_upload_id: record.video_upload_id,
      content_id,
      season_id: season_id || null,
      episode_id: episode_id || null,
      source_s3_key: null,
      output_path_prefix: outputPathPrefix,
      output_manifest_key: hlsManifestKey,
      status: "queued",
      initiated_by: req.user.id,
    });

    await addTranscodeJob({
      transcodingJobId: job.transcoding_job_id,
      localFilePath,
      outputPathPrefix,
      contentId: content_id,
      episodeId: episode_id,
    });

    console.log(
      `[UploadVideo] Phase 1 done (${segResult.filesUploaded} files). Phase 2 queued: ${job.transcoding_job_id}`,
    );

    return res.status(201).json({
      success: true,
      message:
        "Video ready for playback. Adaptive transcode queued in background.",
      data: {
        video_upload_id: record.video_upload_id,
        transcoding_job_id: job.transcoding_job_id,
        manifest_key: hlsManifestKey,
        phase: "instant_ready",
        adaptive_status: "queued",
      },
    });
  } catch (error) {
    // Clean up uploaded file on early error
    if (req.file?.path) {
      const fs = require("fs");
      fs.unlink(req.file.path, () => {});
    }
    const status = error.status || 500;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

// ─── Presigned PUT for poster/banner/thumbnail images ──────────────

const ALLOWED_IMAGE_MIME_TYPES = new Set([
  "image/jpeg",
  "image/jpg",
  "image/png",
  "image/webp",
  "image/gif",
  "image/avif",
]);

const ALLOWED_IMAGE_PURPOSES = new Set([
  "poster",
  "banner",
  "thumbnail",
  "season-thumbnail",
  "episode-thumbnail",
]);

const MIME_TO_EXT = {
  "image/jpeg": "jpg",
  "image/jpg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/gif": "gif",
  "image/avif": "avif",
};

const presignContentImage = async (req, res) => {
  try {
    requireAdmin(req);

    const {
      purpose,
      file_name: fileName,
      mime_type: mimeType,
      content_id: contentId,
    } = req.body || {};

    if (!purpose || !ALLOWED_IMAGE_PURPOSES.has(purpose)) {
      return res.status(400).json({
        success: false,
        message: `Invalid purpose. Allowed: ${[...ALLOWED_IMAGE_PURPOSES].join(", ")}`,
      });
    }

    if (!mimeType || !ALLOWED_IMAGE_MIME_TYPES.has(mimeType)) {
      return res.status(400).json({
        success: false,
        message: `Invalid mime_type. Allowed: ${[...ALLOWED_IMAGE_MIME_TYPES].join(", ")}`,
      });
    }

    const ext =
      MIME_TO_EXT[mimeType] ||
      String(fileName || "")
        .split(".")
        .pop()
        ?.toLowerCase()
        ?.replace(/[^a-z0-9]/g, "") ||
      "bin";

    const safeContentId =
      typeof contentId === "string" && contentId.trim().length > 0
        ? contentId.trim()
        : "unassigned";

    const s3Key = `contents/${safeContentId}/${purpose}/${generateUuid()}.${ext}`;

    const uploadUrl = await generatePresignedPutUrl({
      key: s3Key,
      contentType: mimeType,
      expiresInSeconds:
        Number(process.env.UPLOAD_PRESIGN_EXPIRY_SECONDS) ||
        DEFAULT_PRESIGN_EXPIRY_SECONDS,
    });

    const viewUrl = getPublicCloudFrontUrl(s3Key);

    return res.status(200).json({
      success: true,
      message: "Presigned upload URL generated",
      data: {
        upload_url: uploadUrl,
        view_url: viewUrl,
        s3_key: s3Key,
      },
    });
  } catch (error) {
    const status = error.status || 500;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  initUpload,
  signPart,
  savePart,
  completeUpload,
  abortUpload,
  getUploadStatus,
  getVideoPlaybackUrl,
  uploadVideo,
  presignContentImage,
};
