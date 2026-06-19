"use client";

import React, { useCallback, useEffect, useRef, useState } from "react";
import { useSearchParams } from "next/navigation";
import Hls from "hls.js";
import { getUploadToken } from "@/services/upload.service";

const DEFAULT_API_BASE_URL = process.env.BACKEND_BASE_URL;

const joinUrl = (base, path) => {
  const normalizedBase = String(base || "").replace(/\/+$/, "");
  const normalizedPath = String(path || "").replace(/^\/+/, "");
  return `${normalizedBase}/${normalizedPath}`;
};

const apiJson = async ({ apiBaseUrl, path, token, method = "GET" }) => {
  const url = joinUrl(apiBaseUrl, path);
  const res = await fetch(url, {
    method,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  const data = await res.json().catch(() => null);

  if (!res.ok) {
    const msg =
      data?.message || data?.error || `Request failed (${res.status})`;
    const err = new Error(msg);
    err.status = res.status;
    err.data = data;
    throw err;
  }

  return data;
};

const fetchToken = async () => {
  const result = await getUploadToken();
  if (!result.success || !result.token) {
    throw new Error(result.message || "Not authenticated. Please log in.");
  }
  return result.token;
};

export default function TestVideoPage() {
  const searchParams = useSearchParams();
  const [videoUploadId, setVideoUploadId] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  // MP4 playback
  const [videoUrl, setVideoUrl] = useState(null);
  const [expiresIn, setExpiresIn] = useState(null);

  // HLS playback
  const [hlsData, setHlsData] = useState(null);
  const [playMode, setPlayMode] = useState(null); // "mp4" | "hls"
  const hlsRef = useRef(null);
  const videoRef = useRef(null);

  // Metadata + transcoding
  const [metadata, setMetadata] = useState(null);
  const [transcodeStatus, setTranscodeStatus] = useState(null);
  const [isPolling, setIsPolling] = useState(false);
  const autoLoadedRef = useRef(false);
  const pollTimerRef = useRef(null);

  const apiBaseUrl =
    process.env.NEXT_PUBLIC_API_URL?.replace(/\/api\/?$/, "") ||
    DEFAULT_API_BASE_URL;

  // Cleanup HLS instance and poll timer on unmount
  useEffect(() => {
    return () => {
      if (hlsRef.current) {
        hlsRef.current.destroy();
        hlsRef.current = null;
      }
      if (pollTimerRef.current) {
        clearInterval(pollTimerRef.current);
        pollTimerRef.current = null;
      }
    };
  }, []);

  // Attach HLS to video element when hlsData changes
  useEffect(() => {
    if (!hlsData || playMode !== "hls" || !videoRef.current) return;

    // Cleanup previous HLS instance
    if (hlsRef.current) {
      hlsRef.current.destroy();
      hlsRef.current = null;
    }

    const manifestUrl = hlsData.manifest_url;

    if (Hls.isSupported()) {
      const hls = new Hls({
        xhrSetup: (xhr, url) => {
          // Append signed query params to all HLS requests (manifest + segments)
          if (hlsData.query_params && !url.includes("Policy=")) {
            const separator = url.includes("?") ? "&" : "?";
            xhr.open("GET", `${url}${separator}${hlsData.query_params}`, true);
          }
        },
      });

      hls.loadSource(manifestUrl);
      hls.attachMedia(videoRef.current);

      hls.on(Hls.Events.ERROR, (event, data) => {
        if (data.fatal) {
          setError(`HLS error: ${data.type} - ${data.details}`);
        }
      });

      hlsRef.current = hls;
    } else if (videoRef.current.canPlayType("application/vnd.apple.mpegurl")) {
      // Safari native HLS
      videoRef.current.src = manifestUrl;
    } else {
      setError("HLS is not supported in this browser.");
    }
  }, [hlsData, playMode]);

  const loadVideo = useCallback(
    async (id) => {
      const trimmedId = (id || "").trim();
      if (!trimmedId) {
        setError("Please enter a video upload ID.");
        return;
      }

      setIsLoading(true);
      setError(null);
      setVideoUrl(null);
      setHlsData(null);
      setPlayMode(null);
      setMetadata(null);
      setExpiresIn(null);
      setTranscodeStatus(null);

      try {
        const token = await fetchToken();

        // Fetch upload metadata
        const statusRes = await apiJson({
          apiBaseUrl,
          path: `/api/uploads/${trimmedId}/status`,
          token,
        });

        const record = statusRes.result;

        setMetadata({
          fileName: record?.file_name || "Unknown",
          status: record?.status || "Unknown",
          contentId: record?.content_id || "N/A",
          mimeType: record?.mime_type || "N/A",
          fileSize: record?.file_size || null,
          uploadFor: record?.upload_for || "N/A",
        });

        if (record?.status !== "uploaded") {
          setError(
            `Video is not ready for playback. Current status: "${record?.status || "unknown"}". Upload must be completed first.`,
          );
          return;
        }

        if (!record?.s3_key) {
          setError("Upload record is missing s3_key.");
          return;
        }

        // Check if HLS transcoding is available
        try {
          const tcRes = await apiJson({
            apiBaseUrl,
            path: `/api/transcode/${trimmedId}/status`,
            token,
          });
          setTranscodeStatus(tcRes.data);

          // Try HLS playback — works for both Phase 1 (instant) and Phase 2 (adaptive)
          const hlsRes = await apiJson({
            apiBaseUrl,
            path: `/api/stream/${trimmedId}/hls`,
            token,
          });

          if (hlsRes.data?.manifest_url) {
            setHlsData(hlsRes.data);
            setExpiresIn(hlsRes.data.expires_in);
            setPlayMode("hls");
            return;
          }
        } catch {
          // No transcoding job found — fall through to MP4
        }

        // Fallback to MP4 signed URL
        const playRes = await apiJson({
          apiBaseUrl,
          path: `/api/uploads/${trimmedId}/play-url`,
          token,
        });

        if (!playRes.data?.url) {
          throw new Error("No playback URL returned from server.");
        }

        setVideoUrl(playRes.data.url);
        setExpiresIn(playRes.data.expires_in);
        setPlayMode("mp4");
      } catch (err) {
        setError(err.message || "Failed to load video.");
        setVideoUrl(null);
        setHlsData(null);
      } finally {
        setIsLoading(false);
      }
    },
    [apiBaseUrl],
  );

  // Auto-poll transcoding status every 5s while in progress
  useEffect(() => {
    if (pollTimerRef.current) {
      clearInterval(pollTimerRef.current);
      pollTimerRef.current = null;
    }

    const status = transcodeStatus?.status;
    const trimmedId = videoUploadId.trim();

    if (!trimmedId || !status) return;
    if (status === "complete" || status === "error" || status === "cancelled")
      return;

    pollTimerRef.current = setInterval(async () => {
      try {
        const token = await fetchToken();
        const res = await apiJson({
          apiBaseUrl,
          path: `/api/transcode/${trimmedId}/status`,
          token,
        });

        setTranscodeStatus(res.data);

        if (res.data?.status === "complete") {
          clearInterval(pollTimerRef.current);
          pollTimerRef.current = null;
          loadVideo(trimmedId);
        }
      } catch {
        // Silently ignore poll errors
      }
    }, 5000);

    return () => {
      if (pollTimerRef.current) {
        clearInterval(pollTimerRef.current);
        pollTimerRef.current = null;
      }
    };
  }, [transcodeStatus?.status, videoUploadId, apiBaseUrl, loadVideo]);

  // Auto-fill and auto-load from ?id= query param
  useEffect(() => {
    const idParam = searchParams.get("id");
    if (idParam && !autoLoadedRef.current) {
      autoLoadedRef.current = true;
      setVideoUploadId(idParam);
      loadVideo(idParam);
    }
  }, [searchParams, loadVideo]);

  const handleLoadVideo = () => loadVideo(videoUploadId);

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !isLoading) {
      handleLoadVideo();
    }
  };

  // ─── Transcoding ────────────────────────────────────────────────────

  const handlePollTranscoding = async () => {
    const trimmedId = videoUploadId.trim();
    if (!trimmedId) return;

    setIsPolling(true);
    setError(null);

    try {
      const token = await fetchToken();
      const res = await apiJson({
        apiBaseUrl,
        path: `/api/transcode/${trimmedId}/status`,
        token,
      });

      setTranscodeStatus(res.data);

      // If complete, auto-load HLS
      if (res.data?.status === "complete") {
        loadVideo(trimmedId);
      }
    } catch (err) {
      setError(err.message || "Failed to check transcoding status.");
    } finally {
      setIsPolling(false);
    }
  };

  // ─── Helpers ────────────────────────────────────────────────────────

  const formatFileSize = (bytes) => {
    if (!bytes) return "N/A";
    const num = Number(bytes);
    if (num < 1024) return `${num} B`;
    if (num < 1024 * 1024) return `${(num / 1024).toFixed(1)} KB`;
    if (num < 1024 * 1024 * 1024)
      return `${(num / (1024 * 1024)).toFixed(1)} MB`;
    return `${(num / (1024 * 1024 * 1024)).toFixed(2)} GB`;
  };

  const transcodeStatusColor = (status) => {
    if (status === "complete") return "bg-green-100 text-green-800";
    if (status === "error" || status === "cancelled")
      return "bg-red-100 text-red-800";
    if (status === "progressing" || status === "submitted")
      return "bg-yellow-100 text-yellow-800";
    return "bg-gray-100 text-gray-700";
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <header className="rounded-md border border-foreground/10 bg-foreground/2 p-4 md:p-5">
        <p className="text-sm md:text-base text-brand-muted">Test</p>
        <h1 className="text-xl md:text-2xl font-bold mt-1">
          Video Playback Test
        </h1>
        <p className="text-xs md:text-sm text-foreground/60 mt-1">
          Test CloudFront playback — MP4 (signed URL) or HLS (adaptive
          streaming).
        </p>
      </header>

      {/* Input Section */}
      <div className="rounded-md border border-foreground/10 bg-background p-4 md:p-6">
        <h3 className="text-lg font-semibold mb-4">Load Video</h3>

        <div className="flex flex-col sm:flex-row gap-3">
          <input
            type="text"
            value={videoUploadId}
            onChange={(e) => setVideoUploadId(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Enter video_upload_id (UUID)"
            disabled={isLoading}
            className="flex-1 px-3 py-2 rounded-md border border-foreground/10 bg-background text-sm focus:ring-1 focus:ring-brand-primary outline-none placeholder:text-brand-muted/40 disabled:opacity-50"
          />
          <button
            onClick={handleLoadVideo}
            disabled={isLoading || !videoUploadId.trim()}
            className="px-6 py-2 bg-brand-primary text-white font-semibold rounded-md hover:bg-brand-deep disabled:opacity-50 transition-all text-sm"
          >
            {isLoading ? "Loading..." : "Load Video"}
          </button>
        </div>
      </div>

      {/* Error Display */}
      {error && (
        <div className="p-4 rounded-md border border-red-200 bg-red-50 text-red-700 text-sm">
          {error}
        </div>
      )}

      {/* Metadata Display */}
      {metadata && (
        <div className="rounded-md border border-foreground/10 bg-background p-4">
          <h3 className="text-sm font-semibold mb-3 text-brand-muted uppercase tracking-wide">
            Video Metadata
          </h3>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
            <div>
              <p className="text-xs text-brand-muted">File Name</p>
              <p
                className="text-sm font-medium truncate"
                title={metadata.fileName}
              >
                {metadata.fileName}
              </p>
            </div>
            <div>
              <p className="text-xs text-brand-muted">Status</p>
              <span
                className={`text-xs font-semibold px-2 py-0.5 rounded ${
                  metadata.status === "uploaded"
                    ? "bg-green-100 text-green-800"
                    : "bg-gray-100 text-gray-700"
                }`}
              >
                {metadata.status}
              </span>
            </div>
            <div>
              <p className="text-xs text-brand-muted">Content ID</p>
              <p
                className="text-sm font-medium truncate"
                title={metadata.contentId}
              >
                {metadata.contentId}
              </p>
            </div>
            <div>
              <p className="text-xs text-brand-muted">Type</p>
              <p className="text-sm font-medium">{metadata.uploadFor}</p>
            </div>
            <div>
              <p className="text-xs text-brand-muted">MIME Type</p>
              <p className="text-sm font-medium">{metadata.mimeType}</p>
            </div>
            <div>
              <p className="text-xs text-brand-muted">File Size</p>
              <p className="text-sm font-medium">
                {formatFileSize(metadata.fileSize)}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Transcoding Section */}
      {metadata && metadata.status === "uploaded" && (
        <div className="rounded-md border border-foreground/10 bg-background p-4">
          <h3 className="text-sm font-semibold mb-3 text-brand-muted uppercase tracking-wide">
            HLS Transcoding
          </h3>

          {transcodeStatus ? (
            <div className="space-y-3">
              <div className="flex items-center gap-3">
                <span
                  className={`text-xs font-semibold px-2 py-0.5 rounded ${transcodeStatusColor(transcodeStatus.status)}`}
                >
                  {transcodeStatus.status}
                </span>
                {transcodeStatus.progress_percent > 0 &&
                  transcodeStatus.status !== "complete" && (
                    <span className="text-xs text-foreground/60">
                      {transcodeStatus.progress_percent}%
                    </span>
                  )}
                {transcodeStatus.status === "complete" && (
                  <span className="text-xs text-green-700">
                    Ready for HLS playback
                  </span>
                )}
              </div>

              {transcodeStatus.progress_percent > 0 &&
                transcodeStatus.status !== "complete" && (
                  <div className="h-2 w-full rounded-full bg-foreground/10 overflow-hidden">
                    <div
                      className="h-full bg-brand-primary transition-all"
                      style={{
                        width: `${transcodeStatus.progress_percent}%`,
                      }}
                    />
                  </div>
                )}

              {transcodeStatus.error_message && (
                <p className="text-xs text-red-600">
                  {transcodeStatus.error_message}
                </p>
              )}

              {transcodeStatus.output_manifest_key && (
                <p className="text-xs text-foreground/50 truncate">
                  Manifest: {transcodeStatus.output_manifest_key}
                </p>
              )}

              <div className="flex gap-2">
                {["submitted", "progressing"].includes(
                  transcodeStatus.status,
                ) && (
                  <button
                    onClick={handlePollTranscoding}
                    disabled={isPolling}
                    className="px-4 py-1.5 rounded-md border border-foreground/10 bg-background text-sm font-semibold disabled:opacity-50"
                  >
                    {isPolling ? "Checking..." : "Refresh Status"}
                  </button>
                )}
                {transcodeStatus.status === "complete" && !hlsData && (
                  <button
                    onClick={() => loadVideo(videoUploadId)}
                    className="px-4 py-1.5 rounded-md bg-brand-primary text-white text-sm font-semibold hover:bg-brand-deep transition-all"
                  >
                    Play HLS
                  </button>
                )}
              </div>
            </div>
          ) : (
            <div className="flex items-center gap-3">
              <span className="text-xs font-semibold px-2 py-0.5 rounded bg-gray-100 text-gray-700">
                pending
              </span>
              <span className="text-xs text-foreground/50">
                HLS transcoding starts automatically after upload. Check back
                shortly.
              </span>
              <button
                onClick={handlePollTranscoding}
                disabled={isPolling}
                className="px-4 py-1.5 rounded-md border border-foreground/10 bg-background text-sm font-semibold disabled:opacity-50"
              >
                {isPolling ? "Checking..." : "Refresh"}
              </button>
            </div>
          )}
        </div>
      )}

      {/* Video Player */}
      {(videoUrl || hlsData) && (
        <div className="rounded-md border border-foreground/10 bg-background p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-semibold text-brand-muted uppercase tracking-wide">
                Video Player
              </h3>
              {playMode && (
                <span
                  className={`text-xs font-semibold px-2 py-0.5 rounded ${
                    playMode === "hls"
                      ? "bg-purple-100 text-purple-800"
                      : "bg-blue-100 text-blue-800"
                  }`}
                >
                  {playMode === "hls" ? "HLS Adaptive" : "MP4 Direct"}
                </span>
              )}
            </div>
            {expiresIn && (
              <span className="text-xs text-foreground/50">
                URL expires in {Math.floor(expiresIn / 60)} min
              </span>
            )}
          </div>
          <div className="rounded-md overflow-hidden bg-black">
            {playMode === "hls" ? (
              <video
                ref={videoRef}
                controls
                className="w-full max-h-[70vh]"
                autoPlay={false}
              >
                Your browser does not support the video tag.
              </video>
            ) : (
              <video
                src={videoUrl}
                controls
                className="w-full max-h-[70vh]"
                autoPlay={false}
              >
                Your browser does not support the video tag.
              </video>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
