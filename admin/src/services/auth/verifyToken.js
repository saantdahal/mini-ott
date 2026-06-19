import { jwtVerify } from "jose";

const secret = new TextEncoder().encode(process.env.JWT_ACCESS_SECRET);

/**
 * Verifies a JWT access token and returns the decoded payload.
 * @param {string} token - The JWT token to verify
 * @returns {Promise<{id: string, role: string, iat: number, exp: number} | null>}
 */
export async function verifyToken(token) {
  if (!token) return null;

  try {
    const { payload } = await jwtVerify(token, secret, {
      algorithms: ["HS256"],
    });
    return payload;
  } catch {
    return null;
  }
}
