import axios from "axios";
import { getAccessToken, setAccessToken } from "@/lib/auth";

const baseURL = (process.env.NEXT_PUBLIC_API_URL || "")
  .trim()
  .replace(/\/+$/, "");

if (!baseURL) {
  throw new Error("NEXT_PUBLIC_API_URL is not configured.");
}

const apiClient = axios.create({
  baseURL,
  timeout: 15000,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});

apiClient.interceptors.request.use(
  (config) => {
    const token = getAccessToken();
    if (token) {
      config.headers = config.headers || {};
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error),
);

let isRefreshing = false;
let refreshQueue = [];

const processQueue = (error) => {
  refreshQueue.forEach(({ resolve, reject }) => {
    if (error) {
      reject(error);
    } else {
      resolve();
    }
  });
  refreshQueue = [];
};

apiClient.interceptors.response.use(
  (response) => response.data,
  async (error) => {
    const originalRequest = error.config;

    if (error?.response?.status === 401 && !originalRequest._retried) {
      originalRequest._retried = true;

      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          refreshQueue.push({ resolve, reject });
        }).then(() => apiClient(originalRequest));
      }

      isRefreshing = true;

      try {
        const res = await fetch("/api/auth/refresh", { method: "POST" });
        if (!res.ok) throw new Error("Refresh failed");
        const data = await res.json();
        if (data.accessToken) setAccessToken(data.accessToken);
        processQueue(null);
        return apiClient(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError);
        if (typeof window !== "undefined") {
          window.location.href = "/";
        }
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    const message =
      error?.response?.data?.message || error?.message || "Request failed";

    const apiError = new Error(message);
    apiError.status = error?.response?.status;
    apiError.code = error?.response?.data?.code;
    apiError.details = error?.response?.data?.details;
    apiError.data = error?.response?.data;
    apiError.cause = error;

    return Promise.reject(apiError);
  },
);

export default apiClient;
