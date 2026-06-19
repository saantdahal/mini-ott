import apiClient from "@/lib/api/client";

export async function getCoinPackagesApi() {
  const response = await apiClient.get("/coin-packages/all");
  return response?.result || [];
}

export async function createCoinPackageApi(payload) {
  const response = await apiClient.post("/coin-packages/create", payload);
  return {
    message: response?.message || "Coin package created successfully.",
    data: response?.result,
  };
}
