"use client";

import { Image as ImageIcon, Loader2, X } from "lucide-react";

export default function ImageDropzone({
  label,
  hint,
  heightClass = "h-64",
  iconSize = 40,
  preview,
  uploading,
  onPick,
  onClear,
  inputRef,
}) {
  const hasImage = Boolean(preview);

  return (
    <label
      className={`relative block rounded-xl border border-dashed border-foreground/10 bg-background/40 backdrop-blur-xl shadow-2xl overflow-hidden cursor-pointer transition-colors ${heightClass} ${
        hasImage
          ? ""
          : "hover:bg-foreground/5 hover:border-brand-primary text-foreground/50 hover:text-brand-primary"
      } group`}
    >
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        onChange={onPick}
        disabled={uploading}
        className="sr-only"
      />

      {hasImage ? (
        <>
          <img
            src={preview}
            alt="preview"
            className="w-full h-full object-cover"
          />
          <button
            type="button"
            onClick={(e) => {
              e.preventDefault();
              onClear();
            }}
            className="absolute top-2 right-2 h-8 w-8 rounded-full bg-black/60 text-white flex items-center justify-center hover:bg-black/80"
            aria-label="Remove image"
          >
            <X size={16} />
          </button>
        </>
      ) : (
        <div className="absolute inset-0 flex flex-col items-center justify-center p-6">
          <ImageIcon
            size={iconSize}
            className="mb-3 opacity-50 group-hover:opacity-100 transition-opacity"
          />
          <p className="text-sm font-bold text-foreground group-hover:text-brand-primary transition-colors">
            {label}
          </p>
          <p className="text-xs mt-1 opacity-70">{hint}</p>
        </div>
      )}

      {uploading && (
        <div className="absolute inset-0 bg-black/60 flex items-center justify-center text-white text-sm gap-2">
          <Loader2 size={18} className="animate-spin" />
          Uploading…
        </div>
      )}
    </label>
  );
}
