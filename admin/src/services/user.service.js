"use server";

import axios from "axios";
import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { AUTH_COOKIE_KEYS } from "@/lib/auth";

const BACKEND_BASE_URL = process.env.BACKEND_BASE_URL;

async function getToken() {
  try {
    const cookieStore = await cookies();
    return cookieStore.get(AUTH_COOKIE_KEYS.ACCESS_TOKEN)?.value || null;
  } catch {
    return null;
  }
}

async function serverGet(path) {
  const token = await getToken();
  const response = await axios.get(`${BACKEND_BASE_URL}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    timeout: 10000,
  });
  return response.data;
}

async function serverDelete(path) {
  const token = await getToken();
  const response = await axios.delete(`${BACKEND_BASE_URL}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    timeout: 10000,
  });
  return response.data;
}

export async function getAllUsers() {
  try {
    const data = await serverGet("/api/users");
    return data?.users || [];
  } catch (error) {
    console.error(
      "SSR Fetch Error (getAllUsers):",
      error?.response?.data?.message || error.message,
    );
    return [];
  }
}

export async function getUserById(id) {
  try {
    const data = await serverGet(`/api/users/${id}`);
    return data?.user || null;
  } catch (error) {
    console.error(
      "SSR Fetch Error (getUserById):",
      error?.response?.data?.message || error.message,
    );
    return null;
  }
}

export async function deleteUser(id) {
  try {
    await serverDelete(`/api/users/${id}`);
    revalidatePath("/user-management");
    return { success: true, message: "User deleted successfully" };
  } catch (error) {
    return {
      success: false,
      message:
        error?.response?.data?.message ||
        error?.message ||
        "Failed to delete user",
    };
  }
}
