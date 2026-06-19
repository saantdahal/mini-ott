"use server";

import axios from "axios";
import { cookies } from "next/headers";
import { AUTH_COOKIE_KEYS } from "@/lib/auth";

const ACCESS_TOKEN_MAX_AGE_SECONDS = 60 * 15;
const REFRESH_TOKEN_MAX_AGE_SECONDS = 60 * 60 * 24 * 7; // 7 days

export async function loginUserAction(data) {
  try {
    const response = await axios.post(
      `${process.env.BACKEND_BASE_URL}/api/auth/login`,
      data,
    );

    const accessToken = response?.data?.tokens?.accessToken;
    const refreshToken = response?.data?.tokens?.refreshToken;
    const encodedAdminUser = response?.data?.user
      ? Buffer.from(JSON.stringify(response.data.user), "utf8").toString(
          "base64url",
        )
      : null;

    if (!accessToken) {
      return {
        success: false,
        message: "Login response is incomplete.",
        statusCode: 502,
      };
    }

    const nextCookies = await cookies();

    nextCookies.set(AUTH_COOKIE_KEYS.ACCESS_TOKEN, accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: ACCESS_TOKEN_MAX_AGE_SECONDS,
    });

    if (refreshToken) {
      nextCookies.set(AUTH_COOKIE_KEYS.REFRESH_TOKEN, refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "lax",
        path: "/",
        maxAge: REFRESH_TOKEN_MAX_AGE_SECONDS,
      });
    }

    if (encodedAdminUser) {
      nextCookies.set(AUTH_COOKIE_KEYS.ADMIN_USER, encodedAdminUser, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "lax",
        path: "/",
        maxAge: REFRESH_TOKEN_MAX_AGE_SECONDS,
      });
    } else {
      nextCookies.delete(AUTH_COOKIE_KEYS.ADMIN_USER);
    }

    return {
      success: true,
      data: response.data,
    };
  } catch (error) {
    const message =
      error.response?.data?.message ||
      error.response?.data?.error ||
      "Internal Server Error";

    return {
      success: false,
      message,
      statusCode: error.response?.status || 500,
    };
  }
}

export async function refreshTokensAction() {
  try {
    const nextCookies = await cookies();
    const refreshToken = nextCookies.get(
      AUTH_COOKIE_KEYS.REFRESH_TOKEN,
    )?.value;

    if (!refreshToken) {
      return { success: false, message: "No refresh token" };
    }

    const response = await axios.post(
      `${process.env.BACKEND_BASE_URL}/api/auth/refresh`,
      { refreshToken },
    );

    const newAccessToken = response?.data?.tokens?.accessToken;
    const newRefreshToken = response?.data?.tokens?.refreshToken;

    if (!newAccessToken) {
      return { success: false, message: "Refresh response incomplete" };
    }

    nextCookies.set(AUTH_COOKIE_KEYS.ACCESS_TOKEN, newAccessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: ACCESS_TOKEN_MAX_AGE_SECONDS,
    });

    if (newRefreshToken) {
      nextCookies.set(AUTH_COOKIE_KEYS.REFRESH_TOKEN, newRefreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "lax",
        path: "/",
        maxAge: REFRESH_TOKEN_MAX_AGE_SECONDS,
      });
    }

    const adminUserCookie = nextCookies.get(
      AUTH_COOKIE_KEYS.ADMIN_USER,
    )?.value;
    if (adminUserCookie) {
      nextCookies.set(AUTH_COOKIE_KEYS.ADMIN_USER, adminUserCookie, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "lax",
        path: "/",
        maxAge: REFRESH_TOKEN_MAX_AGE_SECONDS,
      });
    }

    return { success: true, accessToken: newAccessToken };
  } catch (error) {
    return {
      success: false,
      message:
        error.response?.data?.message || error.message || "Token refresh failed",
    };
  }
}

export async function logoutUserAction() {
  try {
    const nextCookies = await cookies();

    nextCookies.delete(AUTH_COOKIE_KEYS.ACCESS_TOKEN);
    nextCookies.delete(AUTH_COOKIE_KEYS.REFRESH_TOKEN);
    nextCookies.delete(AUTH_COOKIE_KEYS.ADMIN_USER);

    return {
      success: true,
    };
  } catch (error) {
    return {
      success: false,
      message: error?.message || "Unable to logout right now.",
      statusCode: 500,
    };
  }
}
