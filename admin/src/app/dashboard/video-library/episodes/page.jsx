"use client";

import AdminSectionPage from "@/components/common/AdminSectionPage";
import ImageDropzone from "@/components/common/ImageDropzone";
import {
  ChevronDown,
  Loader2,
  Save,
  Plus,
  Film,
  ArrowLeft,
  Upload,
  CheckCircle2,
} from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import React, { useEffect, useRef, useState } from "react";
import {
  createEpisodeAction,
  getEpisodesBySeason,
  getSeasonById,
  presignContentImageAction,
} from "@/services/content.service";

const ALLOWED_IMAGE_TYPES = [
  "image/jpeg",
  "image/jpg",
  "image/png",
  "image/webp",
  "image/gif",
  "image/avif",
];

export default function EpisodesPage() {
  const params = useSearchParams();
  const seasonId = params.get("season_id");
  const contentId = params.get("content_id");

  const [season, setSeason] = useState(null);
  const [episodes, setEpisodes] = useState([]);
  const [loading, setLoading] = useState(true);

  const [episodeNumber, setEpisodeNumber] = useState("");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [status, setStatus] = useState("draft");

  const [thumbKey, setThumbKey] = useState("");
  const [thumbPreview, setThumbPreview] = useState("");
  const [isUploadingThumb, setIsUploadingThumb] = useState(false);
  const thumbInputRef = useRef(null);

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorText, setErrorText] = useState("");
  const [successText, setSuccessText] = useState("");

  const refresh = async () => {
    if (!seasonId) return;
    const list = await getEpisodesBySeason(seasonId);
    setEpisodes(Array.isArray(list) ? list : []);
    const nextNum =
      Array.isArray(list) && list.length > 0
        ? Math.max(...list.map((row) => Number(row.episode_number) || 0)) + 1
        : 1;
    setEpisodeNumber(String(nextNum));
  };

  useEffect(() => {
    if (!seasonId) {
      setLoading(false);
      return;
    }
    let cancelled = false;
    setLoading(true);
    Promise.all([getSeasonById(seasonId), getEpisodesBySeason(seasonId)])
      .then(([s, list]) => {
        if (cancelled) return;
        setSeason(s);
        setEpisodes(Array.isArray(list) ? list : []);
        const nextNum =
          Array.isArray(list) && list.length > 0
            ? Math.max(
                ...list.map((row) => Number(row.episode_number) || 0),
              ) + 1
            : 1;
        setEpisodeNumber(String(nextNum));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [seasonId]);

  useEffect(() => {
    return () => {
      if (thumbPreview) URL.revokeObjectURL(thumbPreview);
    };
  }, [thumbPreview]);

  const uploadImage = async (file, purpose) => {
    if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
      throw new Error(
        `Unsupported image type "${file.type}". Use JPEG, PNG, WebP, GIF or AVIF.`,
      );
    }
    const presign = await presignContentImageAction({
      purpose,
      fileName: file.name,
      mimeType: file.type,
      contentId,
    });
    if (!presign.success) {
      throw new Error(presign.message || "Failed to get upload URL");
    }
    const putRes = await fetch(presign.uploadUrl, {
      method: "PUT",
      headers: { "Content-Type": file.type },
      body: file,
    });
    if (!putRes.ok) {
      throw new Error(`Upload to S3 failed (HTTP ${putRes.status})`);
    }
    return { s3Key: presign.s3Key, viewUrl: presign.viewUrl };
  };

  const handleThumbPick = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setErrorText("");
    setIsUploadingThumb(true);
    try {
      if (thumbPreview) URL.revokeObjectURL(thumbPreview);
      setThumbPreview(URL.createObjectURL(file));
      const { s3Key } = await uploadImage(file, "episode-thumbnail");
      setThumbKey(s3Key);
    } catch (err) {
      setErrorText(err.message);
      setThumbPreview("");
      setThumbKey("");
    } finally {
      setIsUploadingThumb(false);
      if (thumbInputRef.current) thumbInputRef.current.value = "";
    }
  };

  const clearThumb = () => {
    if (thumbPreview) URL.revokeObjectURL(thumbPreview);
    setThumbPreview("");
    setThumbKey("");
  };

  const resetForm = () => {
    setTitle("");
    setDescription("");
    setStatus("draft");
    setThumbKey("");
    if (thumbPreview) URL.revokeObjectURL(thumbPreview);
    setThumbPreview("");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;
    setErrorText("");
    setSuccessText("");

    const fd = new FormData();
    fd.set("content_id", contentId);
    fd.set("season_id", seasonId);
    fd.set("episode_number", episodeNumber);
    fd.set("title", title.trim());
    if (description.trim()) fd.set("description", description.trim());
    fd.set("status", status);
    if (thumbKey) fd.set("thumbnail_key", thumbKey);

    setIsSubmitting(true);
    try {
      const result = await createEpisodeAction(null, fd);
      if (!result.success) {
        setErrorText(result.message || "Failed to create episode");
        return;
      }
      setSuccessText(`Episode ${episodeNumber} created`);
      resetForm();
      await refresh();
    } catch (err) {
      setErrorText(err?.message || "Failed to create episode");
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!seasonId) {
    return (
      <AdminSectionPage
        eyebrow="Library > Episodes"
        title="Pick a season first"
        description="Episodes belong to a season. Open a season from the seasons list to manage its episodes."
      >
        <Link
          href={
            contentId
              ? `/dashboard/video-library/seasons?content_id=${contentId}`
              : "/dashboard/video-library"
          }
          className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-brand-primary text-white text-sm font-semibold hover:bg-brand-deep transition-colors"
        >
          <ArrowLeft size={16} />
          Back
        </Link>
      </AdminSectionPage>
    );
  }

  const canSubmit =
    episodeNumber.trim().length > 0 &&
    title.trim().length > 0 &&
    !isUploadingThumb &&
    !isSubmitting;

  return (
    <AdminSectionPage
      eyebrow={`Library > Season ${season?.season_number ?? "…"} > Episodes`}
      title={
        season
          ? `${season.title || `Season ${season.season_number}`} — Episodes`
          : "Manage Episodes"
      }
      description="Add episodes to this season. Each saved episode appears immediately on the left; the form clears for the next one."
    >
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Existing episodes */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold tracking-wider uppercase text-foreground/70">
              Existing episodes
            </h2>
            <div className="flex items-center gap-3">
              {episodes.length > 0 && (
                <span className="text-xs text-foreground/50">
                  {episodes.length} total
                </span>
              )}
              {contentId && (
                <Link
                  href={`/dashboard/video-library/seasons?content_id=${contentId}`}
                  className="inline-flex items-center gap-1 text-xs font-semibold text-brand-primary hover:underline"
                >
                  <ArrowLeft size={14} />
                  Back to seasons
                </Link>
              )}
            </div>
          </div>

          {loading ? (
            <div className="flex items-center gap-2 text-sm text-foreground/50">
              <Loader2 size={16} className="animate-spin" />
              Loading…
            </div>
          ) : episodes.length === 0 ? (
            <div className="rounded-xl border border-dashed border-foreground/10 bg-background/40 backdrop-blur-xl p-8 text-center">
              <Film
                size={28}
                className="mx-auto mb-2 opacity-50 text-foreground/50"
              />
              <p className="text-sm text-foreground/60">
                No episodes yet. Add the first one on the right.
              </p>
            </div>
          ) : (
            <ul className="space-y-3">
              {episodes.map((ep) => {
                const hasVideo = Boolean(
                  ep.stream_manifest_key || ep.video_key,
                );
                return (
                  <li
                    key={ep.episode_id}
                    className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-4 flex items-center gap-4"
                  >
                    <div className="h-16 w-28 rounded-lg overflow-hidden bg-foreground/5 shrink-0">
                      {ep.thumbnail_url ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={ep.thumbnail_url}
                          alt={ep.title}
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
                        Episode {ep.episode_number}
                      </p>
                      <p className="text-sm font-semibold truncate">
                        {ep.title}
                      </p>
                      {ep.description && (
                        <p className="text-xs text-foreground/60 mt-0.5 line-clamp-1">
                          {ep.description}
                        </p>
                      )}
                    </div>
                    <span
                      className={`px-2 py-1 rounded text-[10px] uppercase tracking-wider font-bold ${
                        ep.status === "published"
                          ? "bg-green-500/10 text-green-600"
                          : ep.status === "archived"
                            ? "bg-foreground/10 text-foreground/60"
                            : "bg-yellow-500/10 text-yellow-600"
                      }`}
                    >
                      {ep.status}
                    </span>
                    <Link
                      href={`/dashboard/video-library/upload?episode_id=${ep.episode_id}&content_id=${contentId}&season_id=${seasonId}`}
                      className={`inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold whitespace-nowrap transition-colors ${
                        hasVideo
                          ? "bg-green-500/10 text-green-600 hover:bg-green-500/20"
                          : "bg-brand-primary/10 text-brand-primary hover:bg-brand-primary hover:text-white"
                      }`}
                      title={hasVideo ? "Replace video" : "Upload video"}
                    >
                      {hasVideo ? (
                        <CheckCircle2 size={14} />
                      ) : (
                        <Upload size={14} />
                      )}
                      {hasVideo ? "Replace video" : "Upload video"}
                    </Link>
                  </li>
                );
              })}
            </ul>
          )}
        </div>

        {/* Add-episode form */}
        <form
          onSubmit={handleSubmit}
          className="space-y-5 rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-6 shadow-2xl"
        >
          <div className="flex items-center gap-2 text-sm font-bold tracking-wider uppercase text-foreground/70">
            <Plus size={14} />
            Add new episode
          </div>

          <div>
            <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
              Episode number
            </label>
            <input
              type="number"
              min="1"
              value={episodeNumber}
              onChange={(e) => setEpisodeNumber(e.target.value)}
              required
              className="w-full mt-1.5 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none transition-colors"
            />
          </div>

          <div>
            <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
              Title
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              placeholder="e.g. Genesis"
              className="w-full mt-1.5 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none transition-colors"
            />
          </div>

          <div>
            <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
              Description
            </label>
            <textarea
              rows={3}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full mt-1.5 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-3 text-sm text-foreground focus:border-brand-primary outline-none resize-none transition-colors"
              placeholder="Episode synopsis…"
            />
          </div>

          <div>
            <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
              Status
            </label>
            <div className="relative mt-1.5">
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                className="w-full bg-foreground/5 border border-foreground/10 rounded-lg pl-4 pr-10 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none appearance-none transition-colors cursor-pointer"
              >
                <option value="draft" className="bg-background text-foreground">
                  Draft
                </option>
                <option
                  value="published"
                  className="bg-background text-foreground"
                >
                  Published
                </option>
                <option
                  value="archived"
                  className="bg-background text-foreground"
                >
                  Archived
                </option>
              </select>
              <ChevronDown
                size={16}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-foreground/50 pointer-events-none"
              />
            </div>
          </div>

          <ImageDropzone
            label="Thumbnail (optional)"
            hint="Recommended: 1280x720px (16:9)"
            heightClass="h-32"
            iconSize={28}
            preview={thumbPreview}
            uploading={isUploadingThumb}
            onPick={handleThumbPick}
            onClear={clearThumb}
            inputRef={thumbInputRef}
          />

          {errorText && (
            <div className="rounded-md border border-red-500/20 bg-red-500/5 p-3 text-sm text-red-500">
              {errorText}
            </div>
          )}
          {successText && (
            <div className="rounded-md border border-green-500/20 bg-green-500/5 p-3 text-sm text-green-600">
              {successText}
            </div>
          )}

          <button
            type="submit"
            disabled={!canSubmit}
            className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl bg-brand-primary text-white font-bold tracking-wide hover:bg-brand-deep transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSubmitting ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <Save size={18} />
            )}
            {isSubmitting ? "Saving…" : "Save Episode"}
          </button>
        </form>
      </div>
    </AdminSectionPage>
  );
}
