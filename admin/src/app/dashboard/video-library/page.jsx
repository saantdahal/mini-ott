"use client";

import AdminSectionPage from "@/components/common/AdminSectionPage";
import {
  Plus,
  Search,
  Film,
  Tv,
  Edit,
  Loader2,
  Inbox,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import Link from "next/link";
import React, { useEffect, useState } from "react";
import { getContents } from "@/services/content.service";

const PAGE_SIZE = 12;

const STATUS_BADGE = {
  published: "bg-green-500/15 text-green-500",
  draft: "bg-yellow-500/15 text-yellow-500",
  archived: "bg-foreground/10 text-foreground/60",
};

export default function ContentListPage() {
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [contentType, setContentType] = useState(""); // "" | movie | series
  const [status, setStatus] = useState(""); // "" | draft | published | archived
  const [page, setPage] = useState(1);

  const [items, setItems] = useState([]);
  const [pagination, setPagination] = useState(null);
  const [loading, setLoading] = useState(true);

  // Debounce the search field so we don't hammer the API
  useEffect(() => {
    const t = setTimeout(() => setDebouncedSearch(search.trim()), 300);
    return () => clearTimeout(t);
  }, [search]);

  // Reset to page 1 whenever filters change
  useEffect(() => {
    setPage(1);
  }, [debouncedSearch, contentType, status]);

  // Fetch
  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    const params = { page, limit: PAGE_SIZE };
    if (debouncedSearch) params.search = debouncedSearch;
    if (contentType) params.content_type = contentType;
    if (status) params.status = status;

    getContents(params)
      .then((res) => {
        if (cancelled) return;
        setItems(Array.isArray(res?.items) ? res.items : []);
        setPagination(res?.pagination || null);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [page, debouncedSearch, contentType, status]);

  const totalPages = pagination?.total_pages || 1;
  const total = pagination?.total ?? items.length;

  const editHrefFor = (row) =>
    row.is_series || row.content_type === "series"
      ? `/dashboard/video-library/seasons?content_id=${row.content_id}`
      : `/dashboard/video-library/upload?content_id=${row.content_id}`;

  return (
    <AdminSectionPage
      eyebrow="Library"
      title="Content Management"
      description="Manage movies and web series across the platform."
    >
      {/* Top Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 mb-6 rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-4 shadow-lg">
        <div className="relative w-full sm:w-96">
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-foreground/50"
            size={18}
          />
          <input
            type="text"
            placeholder="Search by title…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-foreground/5 border border-foreground/10 rounded-lg pl-10 pr-4 py-2 text-sm text-foreground focus:outline-none focus:border-brand-primary transition-colors"
          />
        </div>
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <select
            value={contentType}
            onChange={(e) => setContentType(e.target.value)}
            className="px-3 py-2 rounded-lg bg-foreground/5 border border-foreground/10 text-sm cursor-pointer focus:outline-none focus:border-brand-primary"
          >
            <option value="" className="bg-background">
              All types
            </option>
            <option value="movie" className="bg-background">
              Movies
            </option>
            <option value="series" className="bg-background">
              Web Series
            </option>
          </select>
          <select
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            className="px-3 py-2 rounded-lg bg-foreground/5 border border-foreground/10 text-sm cursor-pointer focus:outline-none focus:border-brand-primary"
          >
            <option value="" className="bg-background">
              All statuses
            </option>
            <option value="draft" className="bg-background">
              Draft
            </option>
            <option value="published" className="bg-background">
              Published
            </option>
            <option value="archived" className="bg-background">
              Archived
            </option>
          </select>
          <Link
            href="/dashboard/video-library/new"
            className="flex items-center gap-2 px-4 py-2 rounded-lg bg-brand-primary text-white text-sm font-medium hover:bg-brand-deep transition-all shadow-[0_0_15px_var(--color-brand-primary)] whitespace-nowrap"
          >
            <Plus size={16} /> Add Content
          </Link>
        </div>
      </div>

      <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl overflow-hidden shadow-2xl">
        <table className="w-full text-left text-sm text-foreground/80">
          <thead className="bg-foreground/5 border-b border-foreground/10 text-xs uppercase font-semibold text-foreground/60">
            <tr>
              <th className="px-6 py-4">Title & Poster</th>
              <th className="px-6 py-4">Type</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4">Structure</th>
              <th className="px-6 py-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-foreground/10">
            {loading ? (
              <tr>
                <td colSpan={5} className="px-6 py-16 text-center">
                  <div className="flex items-center justify-center gap-2 text-sm text-foreground/50">
                    <Loader2 size={16} className="animate-spin" />
                    Loading…
                  </div>
                </td>
              </tr>
            ) : items.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-6 py-16 text-center">
                  <Inbox
                    size={32}
                    className="mx-auto mb-2 opacity-40 text-foreground/50"
                  />
                  <p className="text-sm text-foreground/60">
                    {debouncedSearch || contentType || status
                      ? "No content matches the current filters."
                      : "No content yet. Click Add Content to create one."}
                  </p>
                </td>
              </tr>
            ) : (
              items.map((item) => {
                const isSeries =
                  item.is_series || item.content_type === "series";
                return (
                  <tr
                    key={item.content_id}
                    className="hover:bg-foreground/5 transition-colors group"
                  >
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-4">
                        <div className="h-16 w-12 rounded overflow-hidden bg-foreground/5 border border-foreground/10 shadow-sm shrink-0">
                          {item.poster_url ? (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img
                              src={item.poster_url}
                              alt={item.title}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <div className="w-full h-full bg-gradient-to-br from-brand-primary/20 to-brand-deep/20" />
                          )}
                        </div>
                        <span className="font-bold text-foreground">
                          {item.title}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="flex items-center gap-2 text-xs font-medium">
                        {isSeries ? (
                          <Tv size={14} className="text-blue-500" />
                        ) : (
                          <Film size={14} className="text-brand-primary" />
                        )}
                        {isSeries ? "Web Series" : "Movie"}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider ${
                          STATUS_BADGE[item.status] ||
                          "bg-foreground/10 text-foreground/60"
                        }`}
                      >
                        {item.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-xs">
                      {isSeries
                        ? `${item.total_seasons || 0} Seasons · ${item.total_episodes || 0} Eps`
                        : item.stream_manifest_key
                          ? "Video uploaded"
                          : "No video yet"}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <Link
                        href={editHrefFor(item)}
                        className="inline-flex items-center justify-center h-8 w-8 rounded hover:bg-foreground/10 text-foreground/60 hover:text-brand-primary transition-colors"
                        title={isSeries ? "Manage seasons" : "Upload video"}
                      >
                        <Edit size={16} />
                      </Link>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>

        {/* Pagination footer */}
        {!loading && total > 0 && (
          <div className="flex items-center justify-between px-6 py-3 border-t border-foreground/10 text-xs text-foreground/60">
            <span>
              Showing {(page - 1) * PAGE_SIZE + 1}–
              {Math.min(page * PAGE_SIZE, total)} of {total}
            </span>
            <div className="flex items-center gap-2">
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                className="inline-flex items-center gap-1 px-2 py-1 rounded hover:bg-foreground/10 disabled:opacity-40 disabled:cursor-not-allowed"
              >
                <ChevronLeft size={14} />
                Prev
              </button>
              <span>
                Page {page} / {totalPages}
              </span>
              <button
                disabled={page >= totalPages}
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                className="inline-flex items-center gap-1 px-2 py-1 rounded hover:bg-foreground/10 disabled:opacity-40 disabled:cursor-not-allowed"
              >
                Next
                <ChevronRight size={14} />
              </button>
            </div>
          </div>
        )}
      </div>
    </AdminSectionPage>
  );
}
