const { getSignedUrl } = require("@aws-sdk/cloudfront-signer");
const { getCloudFrontConfig } = require("../config/cloudfront");

const DEFAULT_SIGNED_URL_EXPIRES_SECONDS = 3600; // 1 hour

// ─── Core signing (auth-agnostic, caller-agnostic) ──────────────────

/**
 * Sign any CloudFront URL. This is the low-level signer — no auth checks,
 * no assumptions about who is calling or why.
 *
 * @param {string} s3Key - S3 object key to sign
 * @param {object} [options]
 * @param {number} [options.expiresInSeconds] - URL validity (default: 1 hour or CLOUDFRONT_SIGNED_URL_EXPIRES env)
 * @returns {{ url: string, expiresIn: number }}
 */
const signCloudFrontUrl = (s3Key, options = {}) => {
  const config = getCloudFrontConfig();

  if (!config.isConfigured) {
    const err = new Error(
      "CloudFront is not configured. Check AWS_CLOUDFRONT_DOMAIN, CLOUDFRONT_KEY_PAIR_ID, and CLOUDFRONT_PRIVATE_KEY in .env"
    );
    err.status = 500;
    throw err;
  }

  if (!s3Key) {
    const err = new Error("s3_key is required to generate a signed URL.");
    err.status = 400;
    throw err;
  }

  const expiry =
    options.expiresInSeconds ||
    Number(process.env.CLOUDFRONT_SIGNED_URL_EXPIRES) ||
    DEFAULT_SIGNED_URL_EXPIRES_SECONDS;

  const dateLessThan = new Date(Date.now() + expiry * 1000);

  try {
    const url = getSignedUrl({
      url: `https://${config.domain}/${s3Key}`,
      keyPairId: config.keyPairId,
      privateKey: config.privateKey,
      dateLessThan,
    });

    return { url, expiresIn: expiry };
  } catch (signingError) {
    console.error(
      `[CloudFront] Signing failed for key="${s3Key}":`,
      signingError.message
    );
    const err = new Error("Failed to generate signed URL. Check server logs.");
    err.status = 500;
    throw err;
  }
};

/**
 * Build a public CloudFront URL for an S3 key. No signing — for assets that
 * should be cacheable and freely viewable (posters, banners, thumbnails).
 *
 * @param {string} s3Key
 * @returns {string|null} URL, or null if domain or key missing
 */
const getPublicCloudFrontUrl = (s3Key) => {
  if (!s3Key) return null;
  const config = getCloudFrontConfig();
  if (!config.domain) return null;
  return `https://${config.domain}/${s3Key}`;
};

// ─── Playback helpers (built on signCloudFrontUrl) ───────────────────

/**
 * Generate a signed playback URL for a video_uploads record's s3_key.
 * Validates the key matches the expected upload path structure.
 *
 * @param {string} s3Key - The s3_key from video_uploads table
 * @param {number} [expiresInSeconds]
 * @returns {{ url: string, expiresIn: number }}
 */
const generateSignedPlaybackUrl = (s3Key, expiresInSeconds) => {
  if (!s3Key || !s3Key.startsWith("contents/")) {
    const err = new Error(
      `Invalid s3_key for playback: "${s3Key || ""}". Expected key starting with "contents/".`
    );
    err.status = 400;
    throw err;
  }

  return signCloudFrontUrl(s3Key, { expiresInSeconds });
};

/**
 * Generate a signed playback URL from an episode's video_key.
 *
 * @param {string} videoKey - The video_key from episodes table
 * @param {number} [expiresInSeconds]
 * @returns {{ url: string, expiresIn: number }}
 */
const generateEpisodePlaybackUrl = (videoKey, expiresInSeconds) => {
  if (!videoKey) {
    const err = new Error("Episode does not have a video_key.");
    err.status = 400;
    throw err;
  }

  return signCloudFrontUrl(videoKey, { expiresInSeconds });
};

/**
 * Generate a signed playback URL from a content/season trailer_key.
 *
 * @param {string} trailerKey - The trailer_key from contents or seasons table
 * @param {number} [expiresInSeconds]
 * @returns {{ url: string, expiresIn: number }}
 */
const generateTrailerPlaybackUrl = (trailerKey, expiresInSeconds) => {
  if (!trailerKey) {
    const err = new Error("No trailer_key available.");
    err.status = 400;
    throw err;
  }

  return signCloudFrontUrl(trailerKey, { expiresInSeconds });
};

// ─── HLS playback (custom policy for wildcard path) ─────────────────

/**
 * Generate signed query params for an HLS path prefix using a custom policy.
 * The returned params (Policy, Signature, Key-Pair-Id) can be appended to
 * ANY URL under the path prefix — manifest and all segments.
 *
 * @param {string} hlsPathPrefix - S3 path prefix (e.g. "contents/{id}/hls/")
 * @param {object} [options]
 * @param {number} [options.expiresInSeconds] - Validity (default: 1 hour)
 * @returns {{ manifestUrl: string, queryParams: string, expiresIn: number }}
 */
const generateHlsPlaybackParams = (hlsPathPrefix, options = {}) => {
  const config = getCloudFrontConfig();

  if (!config.isConfigured) {
    const err = new Error(
      "CloudFront is not configured. Check AWS_CLOUDFRONT_DOMAIN, CLOUDFRONT_KEY_PAIR_ID, and CLOUDFRONT_PRIVATE_KEY in .env"
    );
    err.status = 500;
    throw err;
  }

  if (!hlsPathPrefix) {
    const err = new Error("HLS path prefix is required.");
    err.status = 400;
    throw err;
  }

  const expiry =
    options.expiresInSeconds ||
    Number(process.env.CLOUDFRONT_SIGNED_URL_EXPIRES) ||
    DEFAULT_SIGNED_URL_EXPIRES_SECONDS;

  const expiresEpoch = Math.floor(Date.now() / 1000) + expiry;

  // Wildcard resource for all files under the HLS prefix
  const resourceUrl = `https://${config.domain}/${hlsPathPrefix}*`;

  const customPolicy = JSON.stringify({
    Statement: [
      {
        Resource: resourceUrl,
        Condition: {
          DateLessThan: { "AWS:EpochTime": expiresEpoch },
        },
      },
    ],
  });

  try {
    // Sign the wildcard URL with custom policy — the returned URL contains
    // Policy, Signature, and Key-Pair-Id as query params
    const signedUrl = getSignedUrl({
      url: resourceUrl,
      keyPairId: config.keyPairId,
      privateKey: config.privateKey,
      policy: customPolicy,
    });

    // Extract query params from the signed URL
    const urlObj = new URL(signedUrl);
    const queryParams = urlObj.search.slice(1); // remove leading '?'

    // Build the actual manifest URL (not the wildcard)
    const manifestUrl = `https://${config.domain}/${hlsPathPrefix}master.m3u8`;

    return {
      manifestUrl,
      queryParams,
      expiresIn: expiry,
    };
  } catch (signingError) {
    console.error(
      `[CloudFront] HLS policy signing failed for prefix="${hlsPathPrefix}":`,
      signingError.message
    );
    const err = new Error("Failed to generate HLS playback params. Check server logs.");
    err.status = 500;
    throw err;
  }
};

module.exports = {
  signCloudFrontUrl,
  getPublicCloudFrontUrl,
  generateSignedPlaybackUrl,
  generateEpisodePlaybackUrl,
  generateTrailerPlaybackUrl,
  generateHlsPlaybackParams,
};
