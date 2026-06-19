export const AUTH_STORAGE_KEYS = {
  USER: "admin.user",
};

export const AUTH_COOKIE_KEYS = {
  ACCESS_TOKEN: "admin_access_token",
  REFRESH_TOKEN: "admin_refresh_token",
  ADMIN_USER: "admin_user",
};

let _accessToken = null;

export const setAccessToken = (token) => {
  _accessToken = token || null;
};

export const getAccessToken = () => {
  return _accessToken;
};

export const saveAdminSession = ({ user }) => {
  if (typeof window === "undefined") {
    return;
  }

  try {
    if (user) {
      localStorage.setItem(AUTH_STORAGE_KEYS.USER, JSON.stringify(user));
    }
  } catch {
    throw new Error("Unable to persist login session in this browser.");
  }
};

export const hasAdminSession = () => {
  if (typeof window === "undefined") {
    return false;
  }

  try {
    return Boolean(localStorage.getItem(AUTH_STORAGE_KEYS.USER));
  } catch {
    return false;
  }
};

export const clearAdminSession = () => {
  if (typeof window === "undefined") {
    return;
  }

  try {
    localStorage.removeItem(AUTH_STORAGE_KEYS.USER);
  } catch {
    // noop
  }
};
