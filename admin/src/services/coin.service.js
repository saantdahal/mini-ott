"use server";

import { revalidatePath } from "next/cache";
import apiClient from "@/lib/api/client";

export async function getCoinPackages() {
  try {
    const response = await apiClient.get("/coin-packages/all");
    return response?.result || [];
  } catch (error) {
    console.error("SSR Fetch Error:", error.message);
    return [];
  }
}

export async function createCoinPackageAction(prevState, formData) {
  try {
    const sortOrderRaw = formData.get("sort_order");
    const sortOrderTrimmed = String(sortOrderRaw ?? "").trim();
    const sortOrderProvided = sortOrderTrimmed.length > 0;

    const payload = {
      title: formData.get("title"),
      description: formData.get("description") || "",
      coins: parseInt(formData.get("coins"), 10),
      bonus_coins: parseInt(formData.get("bonus_coins"), 10) || 0,
      price_amount: parseFloat(formData.get("price_amount")),
      currency: "NPR",
      is_popular: formData.get("is_popular") === "on",

      sort_order: sortOrderProvided ? parseInt(sortOrderTrimmed, 10) : null,
      status: formData.get("status") || "active",
    };

    console.log("🚀 Sending Payload to Backend:", payload);

    const response = await apiClient.post("/coin-packages/create", payload);

    if (response) {
      revalidatePath("/coin-system/coin-management");
      return { success: true, message: "Coin package created successfully!" };
    }
  } catch (error) {
    console.error("Backend Error Details:", error?.data || error?.message);

    if (
      error?.code === "COIN_PACKAGE_SORT_ORDER_TAKEN" ||
      error?.status === 409
    ) {
      return {
        success: false,
        message: error.message,
        fieldErrors: { sort_order: error.message },
      };
    }

    return {
      success: false,
      message:
        error?.message || "Internal Server Error. Please check terminal.",
    };
  }
}
