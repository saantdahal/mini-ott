"use server";

import { revalidatePath } from "next/cache";
import { cookies } from "next/headers";
import apiClient from "@/lib/api/client";
import { AUTH_COOKIE_KEYS } from "@/lib/auth";

const authHeaders = async () => {
  const store = await cookies();
  const token = store.get(AUTH_COOKIE_KEYS.ACCESS_TOKEN)?.value;
  if (!token) {
    const err = new Error("Not authenticated");
    err.status = 401;
    throw err;
  }
  return { Authorization: `Bearer ${token}` };
};

// ─── Public reads ───────────────────────────────────────────────────

export async function getContents(params = {}) {
  try {
    const response = await apiClient.get("/content/contents", { params });
    return response?.result || { items: [], pagination: null };
  } catch (error) {
    console.error("getContents error:", error.message);
    return { items: [], pagination: null };
  }
}

export async function getContentById(contentId) {
  try {
    const response = await apiClient.get(`/content/contents/${contentId}`);
    return response?.result || null;
  } catch (error) {
    console.error("getContentById error:", error.message);
    return null;
  }
}

export async function getSeasonById(seasonId) {
  try {
    const response = await apiClient.get(`/content/seasons/${seasonId}`);
    return response?.result || null;
  } catch (error) {
    console.error("getSeasonById error:", error.message);
    return null;
  }
}

export async function getSeasonsByContent(contentId) {
  if (!contentId) return [];
  try {
    const response = await apiClient.get(
      `/content/contents/${contentId}/seasons`,
    );
    return response?.result || [];
  } catch (error) {
    console.error("getSeasonsByContent error:", error.message);
    return [];
  }
}

export async function getEpisodesBySeason(seasonId) {
  if (!seasonId) return [];
  try {
    const response = await apiClient.get(
      `/content/seasons/${seasonId}/episodes`,
    );
    return response?.result || [];
  } catch (error) {
    console.error("getEpisodesBySeason error:", error.message);
    return [];
  }
}

export async function getEpisodeById(episodeId) {
  if (!episodeId) return null;
  try {
    const response = await apiClient.get(`/content/episodes/${episodeId}`);
    return response?.result || null;
  } catch (error) {
    console.error("getEpisodeById error:", error.message);
    return null;
  }
}

export async function getCategories() {
  try {
    const response = await apiClient.get("/content/categories");
    return response?.result || [];
  } catch (error) {
    console.error("getCategories error:", error.message);
    return [];
  }
}

export async function getGenres() {
  try {
    const response = await apiClient.get("/content/genres");
    return response?.result || [];
  } catch (error) {
    console.error("getGenres error:", error.message);
    return [];
  }
}

// ─── Admin writes ───────────────────────────────────────────────────

export async function presignContentImageAction({
  purpose,
  fileName,
  mimeType,
  contentId = null,
}) {
  try {
    const headers = await authHeaders();
    const response = await apiClient.post(
      "/uploads/image/presign",
      {
        purpose,
        file_name: fileName,
        mime_type: mimeType,
        content_id: contentId,
      },
      { headers },
    );

    const data = response?.data;
    if (!data?.upload_url || !data?.view_url) {
      return { success: false, message: "Invalid presign response" };
    }

    return {
      success: true,
      uploadUrl: data.upload_url,
      viewUrl: data.view_url,
      s3Key: data.s3_key,
    };
  } catch (error) {
    console.error("presignContentImageAction error:", error?.message);
    return {
      success: false,
      message: error?.message || "Failed to generate upload URL",
    };
  }
}

const parseIdList = (raw) => {
  if (!raw) return [];
  if (Array.isArray(raw)) return raw.filter(Boolean);
  return String(raw)
    .split(",")
    .map((v) => v.trim())
    .filter(Boolean);
};

const optionalString = (formData, key) => {
  const value = formData.get(key);
  if (value === null || value === undefined) return undefined;
  const trimmed = String(value).trim();
  return trimmed.length === 0 ? undefined : trimmed;
};

export async function createSeasonAction(_prevState, formData) {
  try {
    const contentId = optionalString(formData, "content_id");
    const seasonNumberRaw = optionalString(formData, "season_number");
    const title = optionalString(formData, "title");

    if (!contentId) {
      return { success: false, message: "content_id is required" };
    }
    if (!seasonNumberRaw) {
      return {
        success: false,
        message: "Season number is required",
        fieldErrors: { season_number: "Required" },
      };
    }
    const seasonNumber = Number(seasonNumberRaw);
    if (!Number.isFinite(seasonNumber) || seasonNumber < 1) {
      return {
        success: false,
        message: "Season number must be a positive integer",
        fieldErrors: { season_number: "Must be a positive integer" },
      };
    }

    const payload = {
      season_number: seasonNumber,
      title,
      description: optionalString(formData, "description"),
      thumbnail_key: optionalString(formData, "thumbnail_key"),
      status: optionalString(formData, "status") || "draft",
    };
    Object.keys(payload).forEach((k) => {
      if (payload[k] === undefined) delete payload[k];
    });

    const headers = await authHeaders();
    const response = await apiClient.post(
      `/content/contents/${contentId}/seasons`,
      payload,
      { headers },
    );

    revalidatePath("/dashboard/video-library");

    return {
      success: true,
      message: "Season created successfully",
      season: response?.result || null,
    };
  } catch (error) {
    console.error("createSeasonAction error:", error?.data || error?.message);
    return {
      success: false,
      message: error?.message || "Failed to create season",
    };
  }
}

export async function createEpisodeAction(_prevState, formData) {
  try {
    const contentId = optionalString(formData, "content_id");
    const seasonId = optionalString(formData, "season_id");
    const episodeNumberRaw = optionalString(formData, "episode_number");
    const title = optionalString(formData, "title");

    if (!contentId) {
      return { success: false, message: "content_id is required" };
    }
    if (!episodeNumberRaw) {
      return {
        success: false,
        message: "Episode number is required",
        fieldErrors: { episode_number: "Required" },
      };
    }
    const episodeNumber = Number(episodeNumberRaw);
    if (!Number.isFinite(episodeNumber) || episodeNumber < 1) {
      return {
        success: false,
        message: "Episode number must be a positive integer",
        fieldErrors: { episode_number: "Must be a positive integer" },
      };
    }

    const payload = {
      season_id: seasonId || undefined,
      episode_number: episodeNumber,
      title,
      description: optionalString(formData, "description"),
      thumbnail_key: optionalString(formData, "thumbnail_key"),
      status: optionalString(formData, "status") || "draft",
    };
    Object.keys(payload).forEach((k) => {
      if (payload[k] === undefined) delete payload[k];
    });

    const headers = await authHeaders();
    const response = await apiClient.post(
      `/content/contents/${contentId}/episodes`,
      payload,
      { headers },
    );

    revalidatePath("/dashboard/video-library");

    return {
      success: true,
      message: "Episode created successfully",
      episode: response?.result || null,
    };
  } catch (error) {
    console.error("createEpisodeAction error:", error?.data || error?.message);
    return {
      success: false,
      message: error?.message || "Failed to create episode",
    };
  }
}

export async function createContentAction(_prevState, formData) {
  try {
    const title = optionalString(formData, "title");
    const contentType = optionalString(formData, "content_type");

    if (!title) {
      return {
        success: false,
        message: "Title is required",
        fieldErrors: { title: "Title is required" },
      };
    }
    if (!contentType) {
      return {
        success: false,
        message: "Content type is required",
        fieldErrors: { content_type: "Content type is required" },
      };
    }

    const payload = {
      title,
      content_type: contentType,
      is_series: contentType === "series",
      status: optionalString(formData, "status") || "draft",
      access_type: optionalString(formData, "access_type") || "free",
      description: optionalString(formData, "description"),
      short_description: optionalString(formData, "short_description"),
      slug: optionalString(formData, "slug"),
      poster_key: optionalString(formData, "poster_key"),
      banner_key: optionalString(formData, "banner_key"),
      thumbnail_key: optionalString(formData, "thumbnail_key"),
      category_ids: parseIdList(formData.get("category_ids")),
      genre_ids: parseIdList(formData.get("genre_ids")),
    };

    Object.keys(payload).forEach((k) => {
      if (payload[k] === undefined) delete payload[k];
    });

    const headers = await authHeaders();
    const response = await apiClient.post("/content/contents", payload, {
      headers,
    });

    revalidatePath("/dashboard/video-library");

    return {
      success: true,
      message: "Content created successfully",
      content: response?.result || null,
    };
  } catch (error) {
    console.error("createContentAction error:", error?.data || error?.message);
    return {
      success: false,
      message: error?.message || "Failed to create content",
    };
  }
}
