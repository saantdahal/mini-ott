"use client";

import React, {
  createContext,
  useContext,
  useState,
  useCallback,
  useEffect,
} from "react";
import { loginUserAction, logoutUserAction } from "@/services/auth.service";
import {
  saveAdminSession,
  clearAdminSession,
  hasAdminSession,
  setAccessToken,
  AUTH_STORAGE_KEYS,
} from "@/lib/auth";

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    try {
      if (hasAdminSession()) {
        const storedUser = localStorage.getItem("admin.user");
        const parsedUser = storedUser ? JSON.parse(storedUser) : null;
        setUser(parsedUser);
        setIsAuthenticated(Boolean(parsedUser));
      }
    } catch (err) {
      console.error("Failed to load session:", err);
    }

    setIsLoading(false);
  }, []);

  const login = useCallback(async (email, password, signal) => {
    setError(null);
    setIsLoading(true);

    try {
      if (signal?.aborted) {
        throw new DOMException("Login request aborted", "AbortError");
      }

      const result = await loginUserAction({ email, password });

      if (!result?.success) {
        throw new Error(result?.message || "Login failed");
      }

      const responseData = result?.data || {};
      const resolvedUser = responseData?.user || null;

      setAccessToken(responseData?.tokens?.accessToken);

      if (resolvedUser) {
        saveAdminSession({ user: resolvedUser });
      } else if (typeof window !== "undefined") {
        localStorage.removeItem(AUTH_STORAGE_KEYS.USER);
      }

      setUser(resolvedUser);
      setIsAuthenticated(Boolean(resolvedUser));

      return responseData;
    } catch (err) {
      setError(err.message || "Login failed");
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const logout = useCallback(async () => {
    await logoutUserAction();
    clearAdminSession();
    setAccessToken(null);
    setUser(null);
    setIsAuthenticated(false);
    setError(null);
  }, []);

  return (
    <AuthContext.Provider
      value={{ user, isAuthenticated, isLoading, error, login, logout }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
};
