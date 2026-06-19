/**
 * Phase 1: CloudFront Distribution Setup Script
 *
 * Creates a CloudFront distribution with OAC (Origin Access Control)
 * for the private S3 bucket and updates the bucket policy.
 *
 * Prerequisites:
 *   - AWS credentials configured (env vars or ~/.aws/credentials)
 *   - .env file with AWS_REGION, AWS_S3_BUCKET_NAME, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
 *
 * Usage:
 *   cd server
 *   node scripts/setup-cloudfront.js
 *
 * Output:
 *   - CloudFront distribution domain name
 *   - CloudFront distribution ID
 *   - OAC ID
 *   - Updated S3 bucket policy
 *
 *   Add these to your .env after running:
 *     AWS_CLOUDFRONT_DOMAIN=<distribution-domain>
 *     AWS_CLOUDFRONT_DISTRIBUTION_ID=<distribution-id>
 */

require("dotenv").config();

const {
  CloudFrontClient,
  CreateOriginAccessControlCommand,
  CreateDistributionCommand,
  ListOriginAccessControlsCommand,
  ListDistributionsCommand,
} = require("@aws-sdk/client-cloudfront");

const {
  S3Client,
  PutBucketPolicyCommand,
  GetBucketPolicyCommand,
} = require("@aws-sdk/client-s3");

// ─── Config ──────────────────────────────────────────────────────────
const REGION = process.env.AWS_REGION;
const BUCKET_NAME = process.env.AWS_S3_BUCKET_NAME;
const OAC_NAME = `${BUCKET_NAME}-oac`;
const DISTRIBUTION_COMMENT = `CDN for ${BUCKET_NAME} - Mini OTT Platform`;

if (!REGION || !BUCKET_NAME) {
  console.error("ERROR: Missing AWS_REGION or AWS_S3_BUCKET_NAME in .env");
  process.exit(1);
}

const cfClient = new CloudFrontClient({ region: REGION });
const s3Client = new S3Client({ region: REGION });

// ─── Helpers ─────────────────────────────────────────────────────────

async function findExistingOAC() {
  const res = await cfClient.send(
    new ListOriginAccessControlsCommand({ MaxItems: "100" })
  );
  const items =
    res.OriginAccessControlList?.Items || [];
  return items.find((oac) => oac.Name === OAC_NAME);
}

async function findExistingDistribution() {
  const res = await cfClient.send(
    new ListDistributionsCommand({ MaxItems: "100" })
  );
  const items = res.DistributionList?.Items || [];
  return items.find((dist) => {
    const origins = dist.Origins?.Items || [];
    return origins.some(
      (o) => o.DomainName === `${BUCKET_NAME}.s3.${REGION}.amazonaws.com`
    );
  });
}

// ─── Step 1: Create Origin Access Control ────────────────────────────

async function createOAC() {
  console.log("\n[1/3] Creating Origin Access Control (OAC)...");

  const existing = await findExistingOAC();
  if (existing) {
    console.log(`  OAC already exists: ${existing.Name} (${existing.Id})`);
    return existing.Id;
  }

  const res = await cfClient.send(
    new CreateOriginAccessControlCommand({
      OriginAccessControlConfig: {
        Name: OAC_NAME,
        Description: `OAC for S3 bucket ${BUCKET_NAME}`,
        SigningProtocol: "sigv4",
        SigningBehavior: "always",
        OriginAccessControlOriginType: "s3",
      },
    })
  );

  const oacId = res.OriginAccessControl.Id;
  console.log(`  OAC created: ${OAC_NAME} (${oacId})`);
  return oacId;
}

// ─── Step 2: Create CloudFront Distribution ──────────────────────────

async function createDistribution(oacId) {
  console.log("\n[2/3] Creating CloudFront distribution...");

  const existing = await findExistingDistribution();
  if (existing) {
    console.log(`  Distribution already exists: ${existing.DomainName}`);
    console.log(`  Distribution ID: ${existing.Id}`);
    return {
      distributionId: existing.Id,
      domainName: existing.DomainName,
    };
  }

  const s3Origin = `${BUCKET_NAME}.s3.${REGION}.amazonaws.com`;
  const originId = `S3-${BUCKET_NAME}`;

  const res = await cfClient.send(
    new CreateDistributionCommand({
      DistributionConfig: {
        CallerReference: `${BUCKET_NAME}-${Date.now()}`,
        Comment: DISTRIBUTION_COMMENT,
        Enabled: true,

        Origins: {
          Quantity: 1,
          Items: [
            {
              Id: originId,
              DomainName: s3Origin,
              OriginAccessControlId: oacId,
              S3OriginConfig: {
                OriginAccessIdentity: "", // empty for OAC (not OAI)
              },
            },
          ],
        },

        DefaultCacheBehavior: {
          TargetOriginId: originId,
          ViewerProtocolPolicy: "redirect-to-https",

          AllowedMethods: {
            Quantity: 2,
            Items: ["GET", "HEAD"],
            CachedMethods: {
              Quantity: 2,
              Items: ["GET", "HEAD"],
            },
          },

          ForwardedValues: {
            QueryString: false,
            Cookies: { Forward: "none" },
          },

          MinTTL: 0,
          DefaultTTL: 86400, // 24 hours
          MaxTTL: 31536000, // 1 year
          Compress: true,
        },

        PriceClass: "PriceClass_All",

        ViewerCertificate: {
          CloudFrontDefaultCertificate: true,
        },

        HttpVersion: "http2",

        Restrictions: {
          GeoRestriction: {
            RestrictionType: "none",
            Quantity: 0,
          },
        },
      },
    })
  );

  const dist = res.Distribution;
  console.log(`  Distribution created: ${dist.DomainName}`);
  console.log(`  Distribution ID: ${dist.Id}`);
  console.log(`  Status: ${dist.Status} (may take 5-10 mins to deploy)`);

  return {
    distributionId: dist.Id,
    domainName: dist.DomainName,
  };
}

// ─── Step 3: Update S3 Bucket Policy ────────────────────────────────

async function updateBucketPolicy(distributionId) {
  console.log("\n[3/3] Updating S3 bucket policy for CloudFront-only access...");

  // Check existing policy
  let existingPolicy = null;
  try {
    const res = await s3Client.send(
      new GetBucketPolicyCommand({ Bucket: BUCKET_NAME })
    );
    existingPolicy = JSON.parse(res.Policy);
  } catch (err) {
    if (err.name !== "NoSuchBucketPolicy") throw err;
  }

  const cloudfrontStatement = {
    Sid: "AllowCloudFrontServicePrincipalReadOnly",
    Effect: "Allow",
    Principal: {
      Service: "cloudfront.amazonaws.com",
    },
    Action: "s3:GetObject",
    Resource: `arn:aws:s3:::${BUCKET_NAME}/*`,
    Condition: {
      StringEquals: {
        "AWS:SourceArn": `arn:aws:cloudfront::${await getAccountId()}:distribution/${distributionId}`,
      },
    },
  };

  let policy;
  if (existingPolicy) {
    // Check if CloudFront statement already exists
    const alreadyExists = existingPolicy.Statement.some(
      (s) => s.Sid === "AllowCloudFrontServicePrincipalReadOnly"
    );
    if (alreadyExists) {
      console.log("  Bucket policy already has CloudFront statement.");
      return;
    }
    existingPolicy.Statement.push(cloudfrontStatement);
    policy = existingPolicy;
  } else {
    policy = {
      Version: "2012-10-17",
      Statement: [cloudfrontStatement],
    };
  }

  await s3Client.send(
    new PutBucketPolicyCommand({
      Bucket: BUCKET_NAME,
      Policy: JSON.stringify(policy),
    })
  );

  console.log("  Bucket policy updated successfully.");
  console.log("  Policy:\n" + JSON.stringify(policy, null, 2));
}

// Get AWS account ID from STS
async function getAccountId() {
  const { STSClient, GetCallerIdentityCommand } = require("@aws-sdk/client-sts");
  const stsClient = new STSClient({ region: REGION });
  const res = await stsClient.send(new GetCallerIdentityCommand({}));
  return res.Account;
}

// ─── Main ────────────────────────────────────────────────────────────

async function main() {
  console.log("=== Phase 1: CloudFront Distribution Setup ===");
  console.log(`Bucket: ${BUCKET_NAME}`);
  console.log(`Region: ${REGION}`);

  try {
    const oacId = await createOAC();
    const { distributionId, domainName } = await createDistribution(oacId);
    await updateBucketPolicy(distributionId);

    console.log("\n=== Setup Complete ===");
    console.log("\nAdd these to your .env file:");
    console.log(`  AWS_CLOUDFRONT_DOMAIN=${domainName}`);
    console.log(`  AWS_CLOUDFRONT_DISTRIBUTION_ID=${distributionId}`);
    console.log(`\nNOTE: Distribution may take 5-10 minutes to fully deploy.`);
    console.log(`After deployment, test with:`);
    console.log(`  curl -I https://${domainName}/<your-s3-key>`);
    console.log(`\nDirect S3 access should be BLOCKED.`);
    console.log(`CloudFront access should return the video file.`);
  } catch (err) {
    console.error("\nERROR:", err.message);
    if (err.Code) console.error("AWS Code:", err.Code);
    process.exit(1);
  }
}

main();
