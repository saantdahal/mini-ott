const {
  S3Client,
  CreateMultipartUploadCommand,
  CompleteMultipartUploadCommand,
  AbortMultipartUploadCommand,
  UploadPartCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

let cachedClient = null;

const getS3Client = () => {
  if (cachedClient) return cachedClient;

  const region = process.env.AWS_REGION;
  if (!region) {
    throw new Error("Missing AWS_REGION env var");
  }

  cachedClient = new S3Client({ region });
  return cachedClient;
};

const getBucketName = () => {
  const bucket = process.env.AWS_S3_BUCKET_NAME;
  if (!bucket) {
    throw new Error("Missing AWS_S3_BUCKET_NAME env var");
  }
  return bucket;
};

const createMultipartUpload = async ({ key, contentType }) => {
  if (!key) throw new Error("Missing S3 object key");

  const s3 = getS3Client();
  const Bucket = getBucketName();

  const command = new CreateMultipartUploadCommand({
    Bucket,
    Key: key,
    ContentType: contentType || undefined,
  });

  const result = await s3.send(command);

  if (!result.UploadId) {
    throw new Error("Failed to create multipart upload");
  }

  return {
    uploadId: result.UploadId,
  };
};

const generatePresignedPartUrl = async ({
  key,
  uploadId,
  partNumber,
  expiresInSeconds = 600,
}) => {
  if (!key) throw new Error("Missing S3 object key");
  if (!uploadId) throw new Error("Missing uploadId");
  if (!partNumber) throw new Error("Missing partNumber");

  const s3 = getS3Client();
  const Bucket = getBucketName();

  const command = new UploadPartCommand({
    Bucket,
    Key: key,
    UploadId: uploadId,
    PartNumber: partNumber,
  });

  const url = await getSignedUrl(s3, command, {
    expiresIn: expiresInSeconds,
  });

  return url;
};

const completeMultipartUpload = async ({ key, uploadId, parts }) => {
  if (!key) throw new Error("Missing S3 object key");
  if (!uploadId) throw new Error("Missing uploadId");
  if (!Array.isArray(parts) || parts.length === 0) {
    throw new Error("Parts array is required");
  }

  const s3 = getS3Client();
  const Bucket = getBucketName();

  const sortedParts = [...parts].sort((a, b) => a.PartNumber - b.PartNumber);

  const command = new CompleteMultipartUploadCommand({
    Bucket,
    Key: key,
    UploadId: uploadId,
    MultipartUpload: {
      Parts: sortedParts,
    },
  });

  return await s3.send(command);
};

const generatePresignedPutUrl = async ({
  key,
  contentType,
  expiresInSeconds = 600,
}) => {
  if (!key) throw new Error("Missing S3 object key");

  const s3 = getS3Client();
  const Bucket = getBucketName();

  const command = new PutObjectCommand({
    Bucket,
    Key: key,
    ContentType: contentType || undefined,
  });

  return await getSignedUrl(s3, command, { expiresIn: expiresInSeconds });
};

const abortMultipartUpload = async ({ key, uploadId }) => {
  if (!key) throw new Error("Missing S3 object key");
  if (!uploadId) throw new Error("Missing uploadId");

  const s3 = getS3Client();
  const Bucket = getBucketName();

  const command = new AbortMultipartUploadCommand({
    Bucket,
    Key: key,
    UploadId: uploadId,
  });

  return await s3.send(command);
};

module.exports = {
  getS3Client,
  getBucketName,
  createMultipartUpload,
  generatePresignedPartUrl,
  generatePresignedPutUrl,
  completeMultipartUpload,
  abortMultipartUpload,
};
