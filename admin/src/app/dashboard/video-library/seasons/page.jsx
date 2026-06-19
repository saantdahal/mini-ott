"use client";

import AdminSectionPage from "@/components/common/AdminSectionPage";
import ImageDropzone from "@/components/common/ImageDropzone";
import { ChevronDown, Loader2, Save, Plus, Layers } from "lucide-react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import React, { useEffect, useRef, useState } from "react";
import {
  createSeasonAction,
  getContentById,
  getSeasonsByContent,
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

export default function SeasonsPage() {
  const router = useRouter();
  const params = useSearchParams();
  const contentId = params.get("content_id");

  const [content, setContent] = useState(null);
  const [seasons, setSeasons] = useState([]);
  const [loading, setLoading] = useState(true);

  const [seasonNumber, setSeasonNumber] = useState("");
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

  useEffect(() => {
    if (!contentId) {
      setLoading(false);
      return;
    }
    let cancelled = false;
    setLoading(true);
    Promise.all([getContentById(contentId), getSeasonsByContent(contentId)])
      .then(([c, s]) => {
        if (cancelled) return;
        setContent(c);
        setSeasons(Array.isArray(s) ? s : []);
        const nextNum =
          Array.isArray(s) && s.length > 0
            ? Math.max(...s.map((row) => Number(row.season_number) || 0)) + 1
            : 1;
        setSeasonNumber(String(nextNum));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [contentId]);

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
      const { s3Key } = await uploadImage(file, "season-thumbnail");
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

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;
    setErrorText("");
    setSuccessText("");

    const fd = new FormData();
    fd.set("content_id", contentId);
    fd.set("season_number", seasonNumber);
    if (title.trim()) fd.set("title", title.trim());
    if (description.trim()) fd.set("description", description.trim());
    fd.set("status", status);
    if (thumbKey) fd.set("thumbnail_key", thumbKey);

    setIsSubmitting(true);
    try {
      const result = await createSeasonAction(null, fd);
      if (!result.success) {
        setErrorText(result.message || "Failed to create season");
        return;
      }
      setSuccessText("Season created");
      const newSeasonId = result.season?.season_id;
      if (newSeasonId) {
        router.push(
          `/dashboard/video-library/episodes?season_id=${newSeasonId}&content_id=${contentId}`,
        );
      }
    } catch (err) {
      setErrorText(err?.message || "Failed to create season");
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!contentId) {
    return (
      <AdminSectionPage
        eyebrow="Library > Seasons"
        title="Pick a series first"
        description="Seasons belong to a series. Open a series from the library to manage its seasons."
      >
        <Link
          href="/dashboard/video-library"
          className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-brand-primary text-white text-sm font-semibold hover:bg-brand-deep transition-colors"
        >
          Back to library
        </Link>
      </AdminSectionPage>
    );
  }

  const canSubmit =
    seasonNumber.trim().length > 0 && !isUploadingThumb && !isSubmitting;

  return (
    <AdminSectionPage
      eyebrow={`Library > ${content?.title || "…"} > Seasons`}
      title="Manage Seasons"
      description={
        content
          ? `Add seasons to "${content.title}" and then drop episodes into each one.`
          : "Loading series…"
      }
    >
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Existing seasons */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold tracking-wider uppercase text-foreground/70">
              Existing seasons
            </h2>
            {seasons.length > 0 && (
              <span className="text-xs text-foreground/50">
                {seasons.length} total
              </span>
            )}
          </div>

          {loading ? (
            <div className="flex items-center gap-2 text-sm text-foreground/50">
              <Loader2 size={16} className="animate-spin" />
              Loading…
            </div>
          ) : seasons.length === 0 ? (
            <div className="rounded-xl border border-dashed border-foreground/10 bg-background/40 backdrop-blur-xl p-8 text-center">
              <Layers
                size={28}
                className="mx-auto mb-2 opacity-50 text-foreground/50"
              />
              <p className="text-sm text-foreground/60">
                No seasons yet. Add the first one on the right.
              </p>
            </div>
          ) : (
            <ul className="space-y-3">
              {seasons.map((s) => (
                <li
                  key={s.season_id}
                  className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-4 flex items-center gap-4"
                >
                  <div className="h-16 w-28 rounded-lg overflow-hidden bg-foreground/5 shrink-0">
                    {s.thumbnail_url ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={s.thumbnail_url}
                        alt={s.title || `Season ${s.season_number}`}
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
                      Season {s.season_number}
                    </p>
                    <p className="text-sm font-semibold truncate">
                      {s.title || "Untitled"}
                    </p>
                    {s.description && (
                      <p className="text-xs text-foreground/60 mt-0.5 line-clamp-1">
                        {s.description}
                      </p>
                    )}
                  </div>
                  <Link
                    href={`/dashboard/video-library/episodes?season_id=${s.season_id}&content_id=${contentId}`}
                    className="px-3 py-2 rounded-lg bg-brand-primary/10 text-brand-primary text-xs font-semibold hover:bg-brand-primary hover:text-white transition-colors whitespace-nowrap"
                  >
                    Manage Episodes
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Add-season form */}
        <form
          onSubmit={handleSubmit}
          className="space-y-5 rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-6 shadow-2xl"
        >
          <div className="flex items-center gap-2 text-sm font-bold tracking-wider uppercase text-foreground/70">
            <Plus size={14} />
            Add new season
          </div>

          <div>
            <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
              Season number
            </label>
            <input
              type="number"
              min="1"
              value={seasonNumber}
              onChange={(e) => setSeasonNumber(e.target.value)}
              required
              className="w-full mt-1.5 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none transition-colors"
            />
          </div>

          <div>
            <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
              Title (optional)
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. The Awakening"
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
              placeholder="Short blurb for this season…"
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
            {isSubmitting ? "Saving…" : "Save & Add Episodes"}
          </button>
        </form>
      </div>
    </AdminSectionPage>
  );
}
