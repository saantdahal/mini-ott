import { cookies } from "next/headers";
import { AUTH_COOKIE_KEYS } from "@/lib/auth";
import { verifyToken } from "@/services/auth/verifyToken";
import { refreshTokensAction } from "@/services/auth.service";

export async function adminProxy() {
  const cookieStore = await cookies();
  let token = cookieStore.get(AUTH_COOKIE_KEYS.ACCESS_TOKEN)?.value;

  let payload = token ? await verifyToken(token) : null;

  if (!payload) {
    const refreshResult = await refreshTokensAction();
    if (refreshResult.success && refreshResult.accessToken) {
      payload = await verifyToken(refreshResult.accessToken);
    }
  }

  if (!payload || payload.role !== "admin") {
    return { allowed: false, payload: null };
  }

  return { allowed: true, payload };
}
