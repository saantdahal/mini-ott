/**
 * Redis connection config for BullMQ.
 *
 * Set REDIS_URL in .env for custom Redis (default: localhost:6379).
 * Examples:
 *   REDIS_URL=redis://localhost:6379
 *   REDIS_URL=redis://:password@host:6379
 */

const getRedisConnection = () => {
  const url = process.env.REDIS_URL || "redis://localhost:6379";

  try {
    const parsed = new URL(url);
    return {
      host: parsed.hostname || "localhost",
      port: parseInt(parsed.port, 10) || 6379,
      password: parsed.password || undefined,
    };
  } catch {
    return { host: "localhost", port: 6379 };
  }
};

module.exports = { getRedisConnection };
