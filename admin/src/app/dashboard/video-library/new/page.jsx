"use client";

import AdminSectionPage from "@/components/common/AdminSectionPage";
import ImageDropzone from "@/components/common/ImageDropzone";
import {
  Save,
  Clapperboard,
  ChevronDown,
  Loader2,
} from "lucide-react";
import { useRouter } from "next/navigation";
import React, { useEffect, useRef, useState } from "react";
import {
  createContentAction,
  getCategories,
  getGenres,
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

export default function CreateContentPage() {
  const router = useRouter();

  const [title, setTitle] = useState("");
  const [contentType, setContentType] = useState("series");
  const [categoryId, setCategoryId] = useState("");
  const [genresText, setGenresText] = useState("");
  const [status, setStatus] = useState("draft");
  const [description, setDescription] = useState("");

  const [categories, setCategories] = useState([]);
  const [genres, setGenres] = useState([]);

  const [posterKey, setPosterKey] = useState("");
  const [posterPreview, setPosterPreview] = useState("");
  const [isUploadingPoster, setIsUploadingPoster] = useState(false);

  const [bannerKey, setBannerKey] = useState("");
  const [bannerPreview, setBannerPreview] = useState("");
  const [isUploadingBanner, setIsUploadingBanner] = useState(false);

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorText, setErrorText] = useState("");
  const [successText, setSuccessText] = useState("");

  const posterInputRef = useRef(null);
  const bannerInputRef = useRef(null);

  useEffect(() => {
    getCategories().then(setCategories);
    getGenres().then(setGenres);
  }, []);

  useEffect(() => {
    return () => {
      if (posterPreview) URL.revokeObjectURL(posterPreview);
      if (bannerPreview) URL.revokeObjectURL(bannerPreview);
    };
  }, [posterPreview, bannerPreview]);

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

  const handlePosterPick = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setErrorText("");
    setIsUploadingPoster(true);
    try {
      if (posterPreview) URL.revokeObjectURL(posterPreview);
      setPosterPreview(URL.createObjectURL(file));
      const { s3Key } = await uploadImage(file, "poster");
      setPosterKey(s3Key);
    } catch (err) {
      setErrorText(err.message);
      setPosterPreview("");
      setPosterKey("");
    } finally {
      setIsUploadingPoster(false);
      if (posterInputRef.current) posterInputRef.current.value = "";
    }
  };

  const handleBannerPick = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setErrorText("");
    setIsUploadingBanner(true);
    try {
      if (bannerPreview) URL.revokeObjectURL(bannerPreview);
      setBannerPreview(URL.createObjectURL(file));
      const { s3Key } = await uploadImage(file, "banner");
      setBannerKey(s3Key);
    } catch (err) {
      setErrorText(err.message);
      setBannerPreview("");
      setBannerKey("");
    } finally {
      setIsUploadingBanner(false);
      if (bannerInputRef.current) bannerInputRef.current.value = "";
    }
  };

  const clearPoster = () => {
    if (posterPreview) URL.revokeObjectURL(posterPreview);
    setPosterPreview("");
    setPosterKey("");
  };
  const clearBanner = () => {
    if (bannerPreview) URL.revokeObjectURL(bannerPreview);
    setBannerPreview("");
    setBannerKey("");
  };

  const matchGenreIds = () => {
    if (!genresText.trim()) return [];
    const wanted = genresText
      .split(",")
      .map((s) => s.trim().toLowerCase())
      .filter(Boolean);
    return genres
      .filter(
        (g) =>
          wanted.includes(String(g.name).toLowerCase()) ||
          wanted.includes(String(g.slug).toLowerCase()),
      )
      .map((g) => g.genre_id);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (isSubmitting) return;
    setErrorText("");
    setSuccessText("");

    const apiContentType = contentType === "movie" ? "movie" : "series";

    const fd = new FormData();
    fd.set("title", title);
    fd.set("content_type", apiContentType);
    fd.set("status", status);
    fd.set("description", description);
    if (categoryId) fd.set("category_ids", categoryId);
    const matchedGenres = matchGenreIds();
    if (matchedGenres.length > 0) {
      fd.set("genre_ids", matchedGenres.join(","));
    }
    if (posterKey) fd.set("poster_key", posterKey);
    if (bannerKey) fd.set("banner_key", bannerKey);

    setIsSubmitting(true);
    try {
      const result = await createContentAction(null, fd);
      if (!result.success) {
        setErrorText(result.message || "Failed to create content");
        return;
      }
      setSuccessText("Content created");
      const newId = result.content?.content_id;
      if (apiContentType === "movie") {
        router.push(
          newId
            ? `/dashboard/video-library/upload?content_id=${newId}`
            : "/dashboard/video-library/upload",
        );
      } else {
        router.push(
          newId
            ? `/dashboard/video-library/seasons?content_id=${newId}`
            : "/dashboard/video-library/seasons",
        );
      }
    } catch (err) {
      setErrorText(err?.message || "Failed to create content");
    } finally {
      setIsSubmitting(false);
    }
  };

  const canSubmit =
    title.trim().length > 0 &&
    !isUploadingPoster &&
    !isUploadingBanner &&
    !isSubmitting;

  return (
    <AdminSectionPage
      eyebrow="Library > New"
      title="Create Content"
      description="Add a new movie or web series to the catalog and assign its metadata."
    >
      <form
        onSubmit={handleSubmit}
        className="grid grid-cols-1 lg:grid-cols-3 gap-6"
      >
        <div className="lg:col-span-2 space-y-6 rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-6 shadow-2xl">
          <div className="space-y-5">
            <div>
              <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
                Title
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                required
                className="w-full mt-1.5 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none transition-colors"
                placeholder="Enter content title..."
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
              <div>
                <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
                  Content Type
                </label>
                <div className="relative mt-1.5">
                  <select
                    value={contentType}
                    onChange={(e) => setContentType(e.target.value)}
                    className="w-full bg-foreground/5 border border-foreground/10 rounded-lg pl-10 pr-10 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none appearance-none transition-colors cursor-pointer"
                  >
                    <option
                      value="movie"
                      className="bg-background text-foreground py-2"
                    >
                      Movie
                    </option>
                    <option
                      value="series"
                      className="bg-background text-foreground py-2"
                    >
                      Web Series
                    </option>
                  </select>
                  <Clapperboard
                    size={16}
                    className="absolute left-3 top-1/2 -translate-y-1/2 text-foreground/50 pointer-events-none"
                  />
                  <ChevronDown
                    size={16}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-foreground/50 pointer-events-none"
                  />
                </div>
              </div>

              <div>
                <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
                  Category
                </label>
                <div className="relative mt-1.5">
                  <select
                    value={categoryId}
                    onChange={(e) => setCategoryId(e.target.value)}
                    className="w-full bg-foreground/5 border border-foreground/10 rounded-lg pl-4 pr-10 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none appearance-none transition-colors cursor-pointer"
                  >
                    <option
                      value=""
                      className="bg-background text-foreground/50 py-2"
                    >
                      Select a category...
                    </option>
                    {categories.map((cat) => (
                      <option
                        key={cat.category_id}
                        value={cat.category_id}
                        className="bg-background text-foreground py-2"
                      >
                        {cat.name}
                      </option>
                    ))}
                  </select>
                  <ChevronDown
                    size={16}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-foreground/50 pointer-events-none"
                  />
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
              <div>
                <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
                  Tags / Genres
                </label>
                <input
                  type="text"
                  value={genresText}
                  onChange={(e) => setGenresText(e.target.value)}
                  className="w-full mt-1.5 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none transition-colors"
                  placeholder="Comma-separated, e.g. Cyberpunk, Dystopian"
                />
                {genres.length > 0 && (
                  <p className="mt-1 text-[10px] text-foreground/40">
                    Available:{" "}
                    {genres
                      .slice(0, 8)
                      .map((g) => g.name)
                      .join(", ")}
                    {genres.length > 8 ? "…" : ""}
                  </p>
                )}
              </div>

              <div>
                <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
                  Initial Status
                </label>
                <div className="relative mt-1.5">
                  <select
                    value={status}
                    onChange={(e) => setStatus(e.target.value)}
                    className="w-full bg-foreground/5 border border-foreground/10 rounded-lg pl-4 pr-10 py-2.5 text-sm text-foreground focus:border-brand-primary outline-none appearance-none transition-colors cursor-pointer"
                  >
                    <option
                      value="draft"
                      className="bg-background text-foreground py-2"
                    >
                      Draft (Hidden)
                    </option>
                    <option
                      value="published"
                      className="bg-background text-foreground py-2"
                    >
                      Published (Live)
                    </option>
                    <option
                      value="archived"
                      className="bg-background text-foreground py-2"
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
            </div>

            <div>
              <label className="text-xs font-semibold text-foreground/70 uppercase tracking-wider">
                Synopsis / Description
              </label>
              <textarea
                rows={5}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="w-full mt-1.5 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-3 text-sm text-foreground focus:border-brand-primary outline-none resize-none transition-colors"
                placeholder="Write a compelling description for the viewers..."
              />
            </div>

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
          </div>
        </div>

        <div className="space-y-6">
          <ImageDropzone
            label="Upload Vertical Poster"
            hint="Recommended: 800x1200px (2:3)"
            heightClass="h-64"
            iconSize={40}
            preview={posterPreview}
            uploading={isUploadingPoster}
            onPick={handlePosterPick}
            onClear={clearPoster}
            inputRef={posterInputRef}
          />

          <ImageDropzone
            label="Upload Hero Banner"
            hint="Recommended: 1920x1080px (16:9)"
            heightClass="h-40"
            iconSize={30}
            preview={bannerPreview}
            uploading={isUploadingBanner}
            onPick={handleBannerPick}
            onClear={clearBanner}
            inputRef={bannerInputRef}
          />

          <button
            type="submit"
            disabled={!canSubmit}
            className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl bg-brand-primary text-white font-bold tracking-wide hover:bg-brand-deep transition-all shadow-[0_0_20px_rgba(219,0,0,0.4)] hover:shadow-none disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none"
          >
            {isSubmitting ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <Save size={18} />
            )}
            {contentType === "movie"
              ? isSubmitting
                ? "Saving..."
                : "Save & Upload Video"
              : isSubmitting
                ? "Saving..."
                : "Save & Manage Seasons"}
          </button>
        </div>
      </form>
    </AdminSectionPage>
  );
}

