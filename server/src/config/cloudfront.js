/**
 * CloudFront Configuration
 *
 * Handles CloudFront environment variable loading, private key parsing,
 * and startup validation for signed URL/cookie generation.
 *
 * Private key in .env should be the PEM content with literal \n for newlines:
 *   CLOUDFRONT_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\nMIIE...\n-----END RSA PRIVATE KEY-----"
 *
 * Or use base64-encoded PEM (auto-detected):
 *   CLOUDFRONT_PRIVATE_KEY="base64:LS0tLS1CRUdJTi..."
 */

let cachedConfig = null;

/**
 * Parse the private key from env var.
 * Supports two formats:
 *   1. PEM with escaped newlines (\n as literal string)
 *   2. Base64-encoded PEM (prefixed with "base64:")
 */
const parsePrivateKey = (raw) => {
  if (!raw) return null;

  // Base64-encoded format
  if (raw.startsWith("base64:")) {
    return Buffer.from(raw.slice(7), "base64").toString("utf-8");
  }

  // Replace literal \n with actual newlines
  return raw.replace(/\\n/g, "\n");
};

/**
 * Get CloudFront config. Reads from env once and caches.
 */
const getCloudFrontConfig = () => {
  if (cachedConfig) return cachedConfig;

  const domain = process.env.AWS_CLOUDFRONT_DOMAIN || process.env.CLOUDFRONT_DOMAIN;
  const keyPairId = process.env.CLOUDFRONT_KEY_PAIR_ID;
  const privateKeyRaw = process.env.CLOUDFRONT_PRIVATE_KEY;
  const distributionId = process.env.AWS_CLOUDFRONT_DISTRIBUTION_ID;

  const privateKey = parsePrivateKey(privateKeyRaw);

  cachedConfig = {
    domain,
    keyPairId,
    privateKey,
    distributionId,
    isConfigured: !!(domain && keyPairId && privateKey),
  };

  return cachedConfig;
};

/**
 * Validate CloudFront env vars on startup.
 * Logs warnings for missing values (non-blocking, like Cloudinary pattern).
 */
const validateCloudFrontConfig = () => {
  const config = getCloudFrontConfig();

  const missing = [];
  if (!config.domain) missing.push("AWS_CLOUDFRONT_DOMAIN");
  if (!config.keyPairId) missing.push("CLOUDFRONT_KEY_PAIR_ID");
  if (!config.privateKey) missing.push("CLOUDFRONT_PRIVATE_KEY");

  if (missing.length > 0) {
    console.warn(
      ` CloudFront config incomplete. Missing: ${missing.join(", ")}. Video playback via CloudFront will not work.`
    );
    return false;
  }

  // Validate private key looks like a PEM
  if (
    !config.privateKey.includes("-----BEGIN") ||
    !config.privateKey.includes("-----END")
  ) {
    console.warn(
      " CloudFront private key does not appear to be valid PEM format. Check CLOUDFRONT_PRIVATE_KEY in .env."
    );
    return false;
  }

  console.log(
    ` CloudFront config loaded. Domain: ${config.domain}`
  );
  return true;
};

module.exports = {
  getCloudFrontConfig,
  validateCloudFrontConfig,
  parsePrivateKey,
};
