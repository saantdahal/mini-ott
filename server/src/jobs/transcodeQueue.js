const { Queue } = require("bullmq");
const { getRedisConnection } = require("../config/redis");

const QUEUE_NAME = "adaptive-transcode";

const transcodeQueue = new Queue(QUEUE_NAME, {
  connection: getRedisConnection(),
  defaultJobOptions: {
    attempts: 2,
    backoff: { type: "exponential", delay: 30000 },
    removeOnComplete: { count: 50 },
    removeOnFail: { count: 100 },
  },
});

/**
 * Add an adaptive transcode job to the queue.
 *
 * @param {object} data
 * @param {string} data.transcodingJobId - DB record ID
 * @param {string} data.localFilePath - Path to source video on disk
 * @param {string} data.outputPathPrefix - S3 HLS prefix
 * @param {string} data.contentId
 * @param {string} [data.episodeId]
 */
const addTranscodeJob = async (data) => {
  const job = await transcodeQueue.add("adaptive", data, {
    jobId: data.transcodingJobId,
  });
  console.log(`[Queue] Added adaptive transcode job: ${job.id}`);
  return job;
};

module.exports = { transcodeQueue, addTranscodeJob, QUEUE_NAME };
