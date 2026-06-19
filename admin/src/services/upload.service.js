"use server";

import axios from "axios";
import { cookies } from "next/headers";
import { AUTH_COOKIE_KEYS } from "@/lib/auth";

const ACCESS_TOKEN_MAX_AGE_SECONDS = 60 * 15;

export async function getUploadToken() {
  const nextCookies = await cookies();

  let token = nextCookies.get(AUTH_COOKIE_KEYS.ACCESS_TOKEN)?.value || null;

  if (token) {
    return { success: true, token };
  }

  // Access token expired — try refreshing using the refresh token
  const refreshToken =
    nextCookies.get(AUTH_COOKIE_KEYS.REFRESH_TOKEN)?.value || null;

  if (!refreshToken) {
    return { success: false, message: "Session expired. Please log in again." };
  }

  try {
    const response = await axios.post(
      `${process.env.BACKEND_BASE_URL}/api/auth/refresh`,
      { refreshToken },
    );

    const newAccessToken = response?.data?.tokens?.accessToken;

    if (!newAccessToken) {
      return {
        success: false,
        message: "Session expired. Please log in again.",
      };
    }

    nextCookies.set(AUTH_COOKIE_KEYS.ACCESS_TOKEN, newAccessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: ACCESS_TOKEN_MAX_AGE_SECONDS,
    });

    return { success: true, token: newAccessToken };
  } catch {
    return { success: false, message: "Session expired. Please log in again." };
  }
}
