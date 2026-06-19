"use client";

import AdminSectionPage from "@/components/common/AdminSectionPage";
import {
  Film,
  Upload,
  Loader2,
  CheckCircle2,
  XCircle,
  ArrowLeft,
  X,
  PlayCircle,
} from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import React, { useEffect, useMemo, useRef, useState } from "react";
import { getContentById, getEpisodeById } from "@/services/content.service";
import { getUploadToken } from "@/services/upload.service";

const ALLOWED_VIDEO_TYPES = [
  "video/mp4",
  "video/quicktime",
  "video/x-matroska",
  "video/webm",
  "video/avi",
  "video/x-msvideo",
  "video/mpeg",
];

const DEFAULT_API_BASE_URL = process.env.BACKEND_BASE_URL;

const joinUrl = (base, path) => {
  const normalizedBase = String(base || "").replace(/\/+$/, "");
  const normalizedPath = String(path || "").replace(/^\/+/, "");
  return `${normalizedBase}/${normalizedPath}`;
};

const formatFileSize = (bytes) => {
  if (!bytes) return "";
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  if (bytes < 1024 * 1024 * 1024)
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
};

const playNotificationSound = () => {
  try {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const notes = [523.25, 659.25, 783.99];
    notes.forEach((freq, i) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine";
      osc.frequency.value = freq;
      gain.gain.setValueAtTime(0.15, ctx.currentTime + i * 0.12);
      gain.gain.exponentialRampToValueAtTime(
        0.001,
        ctx.currentTime + i * 0.12 + 0.4,
      );
      osc.connect(gain).connect(ctx.destination);
      osc.start(ctx.currentTime + i * 0.12);
      osc.stop(ctx.currentTime + i * 0.12 + 0.4);
    });
  } catch {
    /* silent */
  }
};

const showBrowserNotification = (title, body) => {
  if (!("Notification" in window)) return;
  if (Notification.permission === "granted") {
    new Notification(title, { body, icon: "/favicon.ico" });
  } else if (Notification.permission !== "denied") {
    Notification.requestPermission().then((perm) => {
      if (perm === "granted")
        new Notification(title, { body, icon: "/favicon.ico" });
    });
  }
};

export default function VideoUploadPage() {
  const params = useSearchParams();
  const contentId = params.get("content_id") || "";
  const episodeId = params.get("episode_id") || "";
  const seasonId = params.get("season_id") || "";

  const apiBaseUrl =
    process.env.NEXT_PUBLIC_API_BASE_URL || DEFAULT_API_BASE_URL;

  // Mode is derived from URL: episode video vs movie video
  const mode = episodeId ? "episode" : contentId ? "movie" : "none";
  const uploadFor = mode === "episode" ? "episode_video" : "movie_trailer";

  const [content, setContent] = useState(null);
  const [episode, setEpisode] = useState(null);
  const [loadingContext, setLoadingContext] = useState(true);

  const [file, setFile] = useState(null);
  const [isDragging, setIsDragging] = useState(false);
  const fileInputRef = useRef(null);

  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [statusText, setStatusText] = useState("");
  const [errorText, setErrorText] = useState("");

  const [videoUploadId, setVideoUploadId] = useState("");
  const [transcodeStatus, setTranscodeStatus] = useState(null);
  const [phaseOneDone, setPhaseOneDone] = useState(false);

  const pollRef = useRef(null);
  const xhrRef = useRef(null);

  // Fetch context (content + optional episode) ─────────────────────────
  useEffect(() => {
    if (mode === "none") {
      setLoadingContext(false);
      return;
    }
    let cancelled = false;
    setLoadingContext(true);
    const promises = [
      contentId ? getContentById(contentId) : Promise.resolve(null),
    ];
    if (episodeId) promises.push(getEpisodeById(episodeId));
    Promise.all(promises)
      .then(([c, ep]) => {
        if (cancelled) return;
        setContent(c);
        setEpisode(ep || null);
      })
      .finally(() => {
        if (!cancelled) setLoadingContext(false);
      });
    return () => {
      cancelled = true;
    };
  }, [mode, contentId, episodeId]);

  // Browser notification permission + cleanup ──────────────────────────
  useEffect(() => {
    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission();
    }
    return () => {
      if (pollRef.current) clearInterval(pollRef.current);
    };
  }, []);

  // File picker handlers ───────────────────────────────────────────────
  const pickFile = (f) => {
    if (!f) return;
    if (f.type && !ALLOWED_VIDEO_TYPES.includes(f.type)) {
      setErrorText(
        `Unsupported video type "${f.type}". Use MP4, MOV, MKV, WebM, AVI, or MPEG.`,
      );
      return;
    }
    setErrorText("");
    setFile(f);
  };

  const onPick = (e) => pickFile(e.target.files?.[0]);

  const onDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    if (isUploading) return;
    pickFile(e.dataTransfer.files?.[0]);
  };

  const clearFile = () => {
    setFile(null);
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  // Upload ─────────────────────────────────────────────────────────────
  const canUpload = useMemo(
    () => mode !== "none" && !!file && !isUploading,
    [mode, file, isUploading],
  );

  const handleUpload = async () => {
    if (!canUpload) return;

    setIsUploading(true);
    setUploadProgress(0);
    setPhaseOneDone(false);
    setStatusText("Uploading to server…");
    setErrorText("");
    setVideoUploadId("");
    setTranscodeStatus(null);

    try {
      const tokenRes = await getUploadToken();
      if (!tokenRes.success || !tokenRes.token) {
        throw new Error(
          tokenRes.message || "Not authenticated. Please log in.",
        );
      }

      const formData = new FormData();
      formData.append("video", file);
      formData.append("content_id", contentId);
      formData.append("upload_for", uploadFor);
      if (seasonId) formData.append("season_id", seasonId);
      if (episodeId) formData.append("episode_id", episodeId);

      const data = await new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        xhrRef.current = xhr;

        xhr.upload.onprogress = (e) => {
          if (e.lengthComputable) {
            const pct = Math.round((e.loaded / e.total) * 100);
            setUploadProgress(pct);
            if (pct < 100) setStatusText(`Uploading to server… ${pct}%`);
          }
        };
        xhr.upload.onload = () => {
          setStatusText("Server is segmenting and uploading to S3…");
        };
        xhr.onload = () => {
          xhrRef.current = null;
          try {
            const res = JSON.parse(xhr.responseText);
            if (xhr.status >= 200 && xhr.status < 300) resolve(res);
            else
              reject(
                new Error(res?.message || `Upload failed (${xhr.status})`),
              );
          } catch {
            reject(new Error(`Upload failed (${xhr.status})`));
          }
        };
        xhr.onerror = () => {
          xhrRef.current = null;
          reject(new Error("Network error during upload"));
        };
        xhr.onabort = () => {
          xhrRef.current = null;
          reject(new Error("Upload aborted"));
        };

        const url = joinUrl(apiBaseUrl, "api/uploads/video");
        xhr.open("POST", url);
        xhr.setRequestHeader("Authorization", `Bearer ${tokenRes.token}`);
        xhr.send(formData);
      });

      const newId = data?.data?.video_upload_id;
      setVideoUploadId(newId || "");
      setUploadProgress(100);
      setPhaseOneDone(true);
      setIsUploading(false);
      setStatusText(
        data?.data?.phase === "instant_ready"
          ? "Video ready for playback. Adaptive transcode running in background."
          : "Upload complete — processing.",
      );

      playNotificationSound();
      showBrowserNotification(
        "Upload complete",
        `${file.name} is ready for playback.`,
      );

      if (newId) startTranscodePoll(newId, tokenRes.token);
    } catch (err) {
      setIsUploading(false);
      setErrorText(err?.message || "Upload failed");
      setStatusText("");
    }
  };

  const handleAbort = () => {
    if (xhrRef.current) {
      xhrRef.current.abort();
      xhrRef.current = null;
    }
    setIsUploading(false);
    setStatusText("Aborted.");
  };

  const startTranscodePoll = (uploadId, token) => {
    if (pollRef.current) clearInterval(pollRef.current);

    const poll = async () => {
      try {
        const tokenRes = token
          ? { success: true, token }
          : await getUploadToken();
        if (!tokenRes.success) return;
        const url = joinUrl(apiBaseUrl, `api/transcode/${uploadId}/status`);
        const res = await fetch(url, {
          headers: { Authorization: `Bearer ${tokenRes.token}` },
        });
        const json = await res.json();
        if (!json?.data) return;

        setTranscodeStatus(json.data);
        if (json.data.status === "complete") {
          clearInterval(pollRef.current);
          pollRef.current = null;
        } else if (json.data.status === "error") {
          clearInterval(pollRef.current);
          pollRef.current = null;
          setErrorText(json.data.error_message || "Transcoding error");
        }
      } catch {
        /* silent retry */
      }
    };
    poll();
    pollRef.current = setInterval(poll, 3000);
  };

  // Empty state ───────────────────────────────────────────────────────
  if (mode === "none") {
    return (
      <AdminSectionPage
        eyebrow="Library > Upload"
        title="Pick a movie or episode first"
        description="Open a movie from the library, or create an episode and click Upload Video on it."
      >
        <Link
          href="/dashboard/video-library"
          className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-brand-primary text-white text-sm font-semibold hover:bg-brand-deep transition-colors"
        >
          <ArrowLeft size={16} />
          Back to library
        </Link>
      </AdminSectionPage>
    );
  }

  // Header label ──────────────────────────────────────────────────────
  const headerTitle =
    mode === "episode"
      ? episode
        ? `Episode ${episode.episode_number} — ${episode.title}`
        : "Upload Episode Video"
      : content
        ? content.title
        : "Upload Movie Video";

  const eyebrow =
    mode === "episode"
      ? `Library > ${content?.title || "…"} > Upload`
      : "Library > Upload";

  const backHref =
    mode === "episode" && seasonId && contentId
      ? `/dashboard/video-library/episodes?season_id=${seasonId}&content_id=${contentId}`
      : "/dashboard/video-library";

  return (
    <AdminSectionPage
      eyebrow={eyebrow}
      title={headerTitle}
      description={
        mode === "episode"
          ? "Upload the video for this episode. It transcodes to HLS automatically."
          : "Upload the movie video. It transcodes to HLS automatically."
      }
    >
      <div className="space-y-6">
        {/* Context card */}
        {!loadingContext && (content || episode) && (
          <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-4 flex items-center gap-4">
            <div className="h-16 w-28 rounded-lg overflow-hidden bg-foreground/5 shrink-0">
              {episode?.thumbnail_url || content?.poster_url ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={episode?.thumbnail_url || content?.poster_url}
                  alt={headerTitle}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-foreground/30 text-xs">
                  No image
                </div>
              )}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs font-bold uppercase tracking-wider text-brand-primary">
                {mode === "episode" ? "Episode" : "Movie"}
              </p>
              <p className="text-sm font-semibold truncate">{headerTitle}</p>
              <p className="text-xs text-foreground/50 mt-0.5 truncate">
                {mode === "episode"
                  ? `Series: ${content?.title || ""}`
                  : `content_id: ${contentId}`}
              </p>
            </div>
            <Link
              href={backHref}
              className="inline-flex items-center gap-1 text-xs font-semibold text-brand-primary hover:underline"
            >
              <ArrowLeft size={14} />
              Back
            </Link>
          </div>
        )}

        {/* Drop zone */}
        <div
          onDragOver={(e) => {
            e.preventDefault();
            if (!isUploading) setIsDragging(true);
          }}
          onDragLeave={() => setIsDragging(false)}
          onDrop={onDrop}
          onClick={() => !isUploading && fileInputRef.current?.click()}
          className={`relative rounded-xl border-2 border-dashed bg-background/40 backdrop-blur-xl p-10 text-center cursor-pointer transition-all ${
            isDragging
              ? "border-brand-primary bg-brand-primary/5"
              : "border-foreground/10 hover:border-brand-primary"
          } ${isUploading ? "pointer-events-none opacity-50" : ""}`}
        >
          <input
            ref={fileInputRef}
            type="file"
            accept="video/*"
            onChange={onPick}
            className="sr-only"
          />

          {file ? (
            <div className="flex items-center justify-center gap-3">
              <Film size={28} className="text-brand-primary shrink-0" />
              <div className="text-left">
                <p className="text-sm font-semibold truncate max-w-md">
                  {file.name}
                </p>
                <p className="text-xs text-foreground/50">
                  {formatFileSize(file.size)} · {file.type || "video"}
                </p>
              </div>
              {!isUploading && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    clearFile();
                  }}
                  className="ml-2 h-8 w-8 rounded-full bg-foreground/10 hover:bg-foreground/20 flex items-center justify-center"
                  aria-label="Remove file"
                >
                  <X size={14} />
                </button>
              )}
            </div>
          ) : (
            <>
              <Upload size={36} className="mx-auto mb-3 text-foreground/40" />
              <p className="text-sm font-bold">
                Drop a video here, or click to browse
              </p>
              <p className="text-xs text-foreground/50 mt-1">
                MP4, MOV, MKV, WebM up to 50 GB
              </p>
            </>
          )}
        </div>

        {/* Action row */}
        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={handleUpload}
            disabled={!canUpload}
            className="flex-1 sm:flex-none flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-brand-primary text-white font-bold tracking-wide hover:bg-brand-deep transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isUploading ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <Upload size={18} />
            )}
            {isUploading ? "Uploading…" : "Upload & Transcode"}
          </button>

          {isUploading && (
            <button
              onClick={handleAbort}
              className="px-5 py-3.5 rounded-xl border border-foreground/10 bg-background/40 text-sm font-semibold hover:bg-foreground/5 transition-colors"
            >
              Cancel
            </button>
          )}
        </div>

        {/* Progress bar */}
        {(isUploading || uploadProgress > 0) && (
          <div className="space-y-2">
            <div className="h-2 w-full rounded-full bg-foreground/10 overflow-hidden">
              <div
                className="h-full bg-brand-primary transition-all"
                style={{ width: `${uploadProgress}%` }}
              />
            </div>
            <p className="text-xs text-foreground/70">{statusText}</p>
          </div>
        )}

        {errorText && (
          <div className="flex items-start gap-2 rounded-md border border-red-500/20 bg-red-500/5 p-3 text-sm text-red-500">
            <XCircle size={16} className="mt-0.5 shrink-0" />
            <span>{errorText}</span>
          </div>
        )}

        {/* Phase 1 ready */}
        {phaseOneDone && videoUploadId && (
          <div className="rounded-xl border border-green-500/20 bg-green-500/5 p-5 flex flex-wrap items-center gap-3">
            <CheckCircle2 size={20} className="text-green-600" />
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold text-green-700">
                Video ready for playback
              </p>
              <p className="text-xs text-green-700/80">
                Instant HLS is live at original quality.
              </p>
            </div>
            <a
              href={`/test/video?id=${videoUploadId}`}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-brand-primary text-white text-sm font-semibold hover:bg-brand-deep transition-colors"
            >
              <PlayCircle size={16} />
              Test Playback
            </a>
          </div>
        )}

        {/* Phase 2 (adaptive transcode) */}
        {transcodeStatus && (
          <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-5 space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold uppercase tracking-wider text-foreground/70">
                Adaptive transcode
              </h3>
              <span
                className={`text-[10px] font-bold uppercase tracking-wider px-2 py-1 rounded ${
                  transcodeStatus.status === "complete"
                    ? "bg-green-500/10 text-green-600"
                    : transcodeStatus.status === "error"
                      ? "bg-red-500/10 text-red-600"
                      : "bg-yellow-500/10 text-yellow-600"
                }`}
              >
                {transcodeStatus.status}
              </span>
            </div>

            {transcodeStatus.status === "complete" ? (
              <p className="text-xs text-green-700">
                Adaptive HLS ready (480p / 720p / 1080p).
              </p>
            ) : ["queued", "progressing"].includes(transcodeStatus.status) ? (
              <>
                <p className="text-xs text-foreground/60">
                  Encoding 480p, 720p, 1080p in background…
                </p>
                {transcodeStatus.progress_percent > 0 && (
                  <div className="h-2 w-full rounded-full bg-foreground/10 overflow-hidden">
                    <div
                      className="h-full bg-brand-primary transition-all"
                      style={{
                        width: `${transcodeStatus.progress_percent}%`,
                      }}
                    />
                  </div>
                )}
              </>
            ) : null}

            {transcodeStatus.error_message && (
              <p className="text-xs text-red-600">
                {transcodeStatus.error_message}
              </p>
            )}
          </div>
        )}
      </div>
    </AdminSectionPage>
  );
}
