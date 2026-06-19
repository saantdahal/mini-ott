/**
 * Attach managed SimpleCORS response headers policy to the CloudFront
 * distribution's default cache behavior, and set S3 bucket CORS.
 *
 * Usage:
 *   cd server
 *   node scripts/setup-cloudfront-cors.js
 *
 * Requires AWS_CLOUDFRONT_DISTRIBUTION_ID and AWS_S3_BUCKET_NAME in .env.
 */

require("dotenv").config();

const {
  CloudFrontClient,
  GetDistributionConfigCommand,
  UpdateDistributionCommand,
} = require("@aws-sdk/client-cloudfront");

const {
  S3Client,
  PutBucketCorsCommand,
} = require("@aws-sdk/client-s3");

const REGION = process.env.AWS_REGION;
const BUCKET_NAME = process.env.AWS_S3_BUCKET_NAME;
const DISTRIBUTION_ID = process.env.AWS_CLOUDFRONT_DISTRIBUTION_ID;

// AWS-managed "SimpleCORS" response headers policy (stable, global).
const MANAGED_SIMPLE_CORS_POLICY_ID = "60669652-455b-4ae9-85a4-c4c02393f86c";

if (!REGION || !BUCKET_NAME || !DISTRIBUTION_ID) {
  console.error(
    "ERROR: Missing one of AWS_REGION, AWS_S3_BUCKET_NAME, AWS_CLOUDFRONT_DISTRIBUTION_ID in .env"
  );
  process.exit(1);
}

const cfClient = new CloudFrontClient({ region: REGION });
const s3Client = new S3Client({ region: REGION });

async function attachCorsPolicy() {
  console.log("\n[1/2] Attaching managed SimpleCORS policy to CloudFront...");

  const getRes = await cfClient.send(
    new GetDistributionConfigCommand({ Id: DISTRIBUTION_ID })
  );

  const config = getRes.DistributionConfig;
  const etag = getRes.ETag;

  const current = config.DefaultCacheBehavior.ResponseHeadersPolicyId;
  if (current === MANAGED_SIMPLE_CORS_POLICY_ID) {
    console.log("  Policy already attached — skipping update.");
    return;
  }

  config.DefaultCacheBehavior.ResponseHeadersPolicyId =
    MANAGED_SIMPLE_CORS_POLICY_ID;

  await cfClient.send(
    new UpdateDistributionCommand({
      Id: DISTRIBUTION_ID,
      IfMatch: etag,
      DistributionConfig: config,
    })
  );

  console.log("  Policy attached. Deployment may take 5-10 min to propagate.");
}

async function putBucketCors() {
  console.log("\n[2/2] Setting S3 bucket CORS...");

  const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS ||
    "http://localhost:3000,http://localhost:3001")
    .split(",")
    .map((o) => o.trim())
    .filter(Boolean);

  await s3Client.send(
    new PutBucketCorsCommand({
      Bucket: BUCKET_NAME,
      CORSConfiguration: {
        CORSRules: [
          {
            AllowedOrigins: allowedOrigins,
            AllowedMethods: ["GET", "HEAD"],
            AllowedHeaders: ["*"],
            ExposeHeaders: ["ETag"],
            MaxAgeSeconds: 3000,
          },
        ],
      },
    })
  );

  console.log(`  S3 CORS set for origins: ${allowedOrigins.join(", ")}`);
}

async function main() {
  console.log("=== CloudFront + S3 CORS Setup ===");
  console.log(`Distribution: ${DISTRIBUTION_ID}`);
  console.log(`Bucket: ${BUCKET_NAME}`);

  try {
    await attachCorsPolicy();
    await putBucketCors();

    console.log("\n=== Done ===");
    console.log("Wait ~5-10 min for CloudFront to deploy, then reload the page.");
    console.log(`Verify with:`);
    console.log(
      `  curl -I -H "Origin: http://localhost:3000" https://${process.env.AWS_CLOUDFRONT_DOMAIN}/<some-key>`
    );
    console.log("Response should include: access-control-allow-origin");
  } catch (err) {
    console.error("\nERROR:", err.message);
    if (err.Code) console.error("AWS Code:", err.Code);
    process.exit(1);
  }
}

main();
