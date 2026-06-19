import { refreshTokensAction } from "@/services/auth.service";

export async function POST() {
  const result = await refreshTokensAction();

  if (!result.success) {
    return Response.json({ success: false }, { status: 401 });
  }

  return Response.json({ success: true, accessToken: result.accessToken });
}
