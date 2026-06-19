const { Worker } = require("bullmq");
const { getRedisConnection } = require("../config/redis");
const { QUEUE_NAME } = require("./transcodeQueue");
const {
  adaptiveTranscode,
  cleanupSourceFile,
} = require("../services/transcoder.service");

let TranscodingJobs;
let Episodes;
let Contents;

// Lazy-load models to avoid circular dependency issues at startup
const getModels = () => {
  if (!TranscodingJobs) {
    TranscodingJobs = require("../model/transcoding_jobs.model");
    Episodes = require("../model/episodes.model");
    Contents = require("../model/contents.model");
  }
  return { TranscodingJobs, Episodes, Contents };
};

const startTranscodeWorker = () => {
  const worker = new Worker(
    QUEUE_NAME,
    async (job) => {
      const {
        transcodingJobId,
        localFilePath,
        outputPathPrefix,
        contentId,
        episodeId,
      } = job.data;

      const { TranscodingJobs, Episodes, Contents } = getModels();

      console.log(
        `[Worker] Processing adaptive transcode: ${transcodingJobId}`
      );

      const dbJob = await TranscodingJobs.findByPk(transcodingJobId);
      if (!dbJob) {
        throw new Error(`Transcoding job ${transcodingJobId} not found in DB`);
      }

      // If job was already cancelled (e.g. superseded by a newer upload), skip
      if (dbJob.status === "cancelled") {
        console.log(`[Worker] Job ${transcodingJobId} already cancelled, skipping`);
        await cleanupSourceFile(localFilePath);
        return { filesUploaded: 0 };
      }

      await dbJob.update({ status: "progressing" });

      try {
        const result = await adaptiveTranscode({
          localFilePath,
          outputPathPrefix,
          onProgress: async ({ percent }) => {
            await job.updateProgress(percent);
            try {
              // Re-check if job was cancelled mid-transcode
              await dbJob.reload();
              if (dbJob.status === "cancelled") {
                throw new Error("Job cancelled — superseded by newer upload");
              }
              await dbJob.update({ progress_percent: percent });
            } catch (err) {
              if (err.message.includes("cancelled")) throw err;
              // Ignore other DB progress errors
            }
          },
        });

        // Before overwriting S3, check if a newer upload has taken over this path.
        // If another job was created for the same episode/content after this one,
        // this job's output is stale — skip the S3 write to avoid clobbering.
        const whereClause = episodeId
          ? { episode_id: episodeId }
          : { content_id: contentId };
        const newerJob = await TranscodingJobs.findOne({
          where: {
            ...whereClause,
            created_at: { [require("sequelize").Op.gt]: dbJob.created_at },
          },
          order: [["created_at", "DESC"]],
        });

        if (newerJob) {
          console.log(
            `[Worker] Skipping S3 write for stale job ${transcodingJobId} — newer job ${newerJob.transcoding_job_id} exists`
          );
          await dbJob.update({
            status: "cancelled",
            error_message: `Superseded by newer upload (job ${newerJob.transcoding_job_id})`,
          });
          await cleanupSourceFile(localFilePath);
          return { filesUploaded: 0 };
        }

        // Mark complete
        await dbJob.update({
          status: "complete",
          progress_percent: 100,
          output_manifest_key: `${outputPathPrefix}master.m3u8`,
          output_path_prefix: outputPathPrefix,
          completed_at: new Date(),
        });

        // Update stream_manifest_key
        if (episodeId) {
          await Episodes.update(
            { stream_manifest_key: `${outputPathPrefix}master.m3u8` },
            { where: { episode_id: episodeId } }
          );
        } else if (contentId) {
          await Contents.update(
            { stream_manifest_key: `${outputPathPrefix}master.m3u8` },
            { where: { content_id: contentId } }
          );
        }

        console.log(
          `[Worker] Adaptive transcode complete: ${transcodingJobId} (${result.filesUploaded} files)`
        );

        // Cleanup source file — no longer needed
        await cleanupSourceFile(localFilePath);

        return { filesUploaded: result.filesUploaded };
      } catch (err) {
        await dbJob.update({
          status: "error",
          error_message: err.message,
        });
        throw err;
      }
    },
    {
      connection: getRedisConnection(),
      concurrency: 1, // one transcode at a time to avoid CPU overload
    }
  );

  worker.on("completed", (job) => {
    console.log(`[Worker] Job ${job.id} completed`);
  });

  worker.on("failed", (job, err) => {
    console.error(`[Worker] Job ${job?.id} failed:`, err.message);
  });

  console.log("[Worker] Adaptive transcode worker started");
  return worker;
};

module.exports = { startTranscodeWorker };
