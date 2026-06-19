import axios from "axios";

export const loginAdmin = async ({ email, password, signal }) => {
  try {
    const response = await axios.post(
      "/api/login",
      { email, password },
      {
        withCredentials: true,
        headers: {
          "Content-Type": "application/json",
        },
        signal,
      },
    );

    return response.data;
  } catch (error) {
    const responseStatus = error?.response?.status;
    const responseMessage =
      error?.response?.data?.message ||
      error?.message ||
      "Unable to login right now.";
    const normalizedMessage = responseMessage.toLowerCase();

    const isCredentialIssue =
      responseStatus === 401 ||
      normalizedMessage.includes("invalid credentials") ||
      normalizedMessage.includes("invalid email or password");

    if (isCredentialIssue) {
      throw new Error("Invalid credentials");
    }

    throw new Error(responseMessage);
  }
};

export const authApi = {
  loginAdmin,
};
