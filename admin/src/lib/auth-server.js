import { cookies } from "next/headers";
import { AUTH_COOKIE_KEYS } from "@/lib/auth";

export const getServerAccessToken = async () =>
  (await cookies()).get(AUTH_COOKIE_KEYS.ACCESS_TOKEN)?.value || null;

export const hasServerAdminSession = async () =>
  Boolean(await getServerAccessToken());

export const getServerAdminUser = async () => {
  const encodedUser =
    (await cookies()).get(AUTH_COOKIE_KEYS.ADMIN_USER)?.value || null;

  if (!encodedUser) {
    return null;
  }

  try {
    const decodedUser = Buffer.from(encodedUser, "base64url").toString("utf8");
    return JSON.parse(decodedUser);
  } catch {
    return null;
  }
};

export const getServerAdminName = async () => {
  const adminUser = await getServerAdminUser();

  return (
    adminUser?.full_name ||
    adminUser?.fullName ||
    adminUser?.name ||
    (adminUser?.email ? adminUser.email.split("@")[0] : null) ||
    "Admin"
  );
};
