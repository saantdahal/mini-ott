const { Op } = require("sequelize");
const VideoUploads = require("../model/video_uploads.model");
const TranscodingJobs = require("../model/transcoding_jobs.model");
const Episodes = require("../model/episodes.model");
const Contents = require("../model/contents.model");

const { runTranscodingJob } = require("../services/transcoder.service");

const {
  generateHlsPlaybackParams,
} = require("../services/cloudfront.service");

const requireAuth = (req) => {
  if (!req.user) {
    const err = new Error("Authentication required");
    err.status = 401;
    throw err;
  }
};

const requireAdmin = (req) => {
  if (!req.user || req.user.role !== "admin") {
    const err = new Error("Only admin can manage transcoding");
    err.status = 403;
    throw err;
  }
};

// ─── POST /api/transcode/:videoUploadId ──────────────────────────────
// Trigger HLS transcoding for a completed upload (runs FFmpeg in background)

const startTranscoding = async (req, res) => {
  try {
    requireAdmin(req);

    const { videoUploadId } = req.params;

    const upload = await VideoUploads.findByPk(videoUploadId);
    if (!upload) {
      return res.status(404).json({
        success: false,
        message: "Video upload not found",
      });
    }

    if (upload.status !== "uploaded") {
      return res.status(400).json({
        success: false,
        message: `Cannot transcode when upload status is "${upload.status}". Must be "uploaded".`,
      });
    }

    if (!upload.s3_key) {
      return res.status(400).json({
        success: false,
        message: "Upload is missing s3_key",
      });
    }

    // Check if there's already an active transcoding job
    const existingJob = await TranscodingJobs.findOne({
      where: {
        video_upload_id: videoUploadId,
        status: { [Op.in]: ["pending", "progressing"] },
      },
    });

    if (existingJob) {
      return res.status(409).json({
        success: false,
        message: `Transcoding already in progress (job: ${existingJob.transcoding_job_id}, status: ${existingJob.status})`,
      });
    }

    // Create DB record
    const job = await TranscodingJobs.create({
      video_upload_id: videoUploadId,
      content_id: upload.content_id,
      season_id: upload.season_id,
      episode_id: upload.episode_id,
      source_s3_key: upload.s3_key,
      status: "progressing",
      initiated_by: req.user.id,
    });

    // Respond immediately — FFmpeg runs in the background
    res.status(201).json({
      success: true,
      message: "Transcoding started (FFmpeg). Poll status for progress.",
      data: {
        transcoding_job_id: job.transcoding_job_id,
        status: "progressing",
      },
    });

    // Run FFmpeg in background (don't await in request handler)
    runTranscodingJob({
      sourceS3Key: upload.s3_key,
      contentId: upload.content_id,
      episodeId: upload.episode_id,
      onProgress: async ({ status, percent }) => {
        try {
          await job.update({
            status: status === "complete" ? "complete" : "progressing",
            progress_percent: percent,
          });
        } catch {
          // Ignore DB update errors during progress
        }
      },
    })
      .then(async (result) => {
        await job.update({
          status: "complete",
          progress_percent: 100,
          output_manifest_key: result.outputManifestKey,
          output_path_prefix: result.outputPathPrefix,
          completed_at: new Date(),
        });

        // Update stream_manifest_key on episode or content
        if (job.episode_id && result.outputManifestKey) {
          await Episodes.update(
            { stream_manifest_key: result.outputManifestKey },
            { where: { episode_id: job.episode_id } }
          );
        } else if (job.content_id && result.outputManifestKey) {
          await Contents.update(
            { stream_manifest_key: result.outputManifestKey },
            { where: { content_id: job.content_id } }
          );
        }

        console.log(
          `[Transcode] Job ${job.transcoding_job_id} complete. ${result.filesUploaded} files uploaded.`
        );
      })
      .catch(async (err) => {
        console.error(
          `[Transcode] Job ${job.transcoding_job_id} failed:`,
          err.message
        );
        await job.update({
          status: "error",
          error_message: err.message,
        });
      });
  } catch (error) {
    console.error("[Transcode] Start error:", error.message);
    const status = error.status || 500;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

// ─── GET /api/transcode/:videoUploadId/status ────────────────────────
// Check transcoding status from DB

const getTranscodingStatus = async (req, res) => {
  try {
    requireAdmin(req);

    const { videoUploadId } = req.params;

    const job = await TranscodingJobs.findOne({
      where: { video_upload_id: videoUploadId },
      order: [["created_at", "DESC"]],
    });

    if (!job) {
      return res.status(404).json({
        success: false,
        message: "No transcoding job found for this upload",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Transcoding status",
      data: {
        transcoding_job_id: job.transcoding_job_id,
        video_upload_id: job.video_upload_id,
        status: job.status,
        progress_percent: job.progress_percent,
        output_manifest_key: job.output_manifest_key,
        output_path_prefix: job.output_path_prefix,
        error_message: job.error_message,
        completed_at: job.completed_at,
        created_at: job.created_at,
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

// ─── GET /api/stream/:videoUploadId/hls ──────────────────────────────
// Get HLS playback params (signed manifest URL + query params for segments)

const getHlsPlaybackParams = async (req, res) => {
  try {
    requireAuth(req);

    const { videoUploadId } = req.params;

    // Look for any job that has output_path_prefix (Phase 1 instant HLS is
    // already on S3 even while Phase 2 adaptive transcode is still running).
    const job = await TranscodingJobs.findOne({
      where: {
        video_upload_id: videoUploadId,
        output_path_prefix: { [Op.ne]: null },
      },
      order: [["created_at", "DESC"]],
    });

    if (!job || !job.output_path_prefix) {
      return res.status(404).json({
        success: false,
        message: "No HLS output found for this upload. Transcode the video first.",
      });
    }

    const { manifestUrl, queryParams, expiresIn } =
      generateHlsPlaybackParams(job.output_path_prefix);

    return res.status(200).json({
      success: true,
      message: "HLS playback params generated",
      data: {
        manifest_url: `${manifestUrl}?${queryParams}`,
        query_params: queryParams,
        base_url: `https://${process.env.AWS_CLOUDFRONT_DOMAIN}/${job.output_path_prefix}`,
        expires_in: expiresIn,
        phase: job.status === "complete" ? "adaptive" : "instant",
      },
    });
  } catch (error) {
    console.error("[Stream] HLS params error:", error.message);
    const status = error.status || 500;
    return res.status(status).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  startTranscoding,
  getTranscodingStatus,
  getHlsPlaybackParams,
};
