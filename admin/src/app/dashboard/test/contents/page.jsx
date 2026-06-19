"use client";

import { useEffect, useState, useTransition } from "react";
import {
  BadgeCheck,
  Crown,
  Film,
  Info,
  Play,
  Plus,
  Tv,
  ChevronLeft,
} from "lucide-react";
import {
  getContents,
  getContentById,
  getSeasonById,
} from "@/services/content.service";

const POSTER_GRADIENTS = [
  "from-rose-700 via-red-900 to-zinc-900",
  "from-indigo-700 via-blue-900 to-zinc-900",
  "from-emerald-700 via-teal-900 to-zinc-900",
  "from-amber-600 via-orange-900 to-zinc-900",
  "from-fuchsia-700 via-purple-900 to-zinc-900",
  "from-cyan-600 via-sky-900 to-zinc-900",
  "from-lime-600 via-green-900 to-zinc-900",
];

const pickGradient = (seed) => {
  const str = String(seed || "");
  let hash = 0;
  for (let i = 0; i < str.length; i += 1) {
    hash = (hash * 31 + str.charCodeAt(i)) >>> 0;
  }
  return POSTER_GRADIENTS[hash % POSTER_GRADIENTS.length];
};

const formatYear = (date) => {
  if (!date) return null;
  const year = new Date(date).getUTCFullYear();
  return Number.isFinite(year) ? year : null;
};

const formatDuration = (seconds) => {
  if (!seconds) return null;
  const total = Number(seconds);
  if (!Number.isFinite(total) || total <= 0) return null;
  const h = Math.floor(total / 3600);
  const m = Math.floor((total % 3600) / 60);
  if (h > 0) return `${h}h ${m}m`;
  return `${m}m`;
};

const ContentTypeIcon = ({ type, className = "" }) => {
  if (type === "movie") return <Film size={14} className={className} />;
  if (type === "series") return <Tv size={14} className={className} />;
  return <BadgeCheck size={14} className={className} />;
};

const Badge = ({ children, tone = "default" }) => {
  const tones = {
    default: "bg-foreground/10 text-foreground/70",
    premium:
      "bg-linear-to-r from-amber-400 to-amber-600 text-black shadow-[0_0_10px_rgba(251,191,36,0.45)]",
    free: "bg-emerald-500/15 text-emerald-300 border border-emerald-500/30",
    rating: "bg-foreground/15 text-foreground/80 border border-foreground/20",
  };
  return (
    <span
      className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider ${tones[tone]}`}
    >
      {children}
    </span>
  );
};

const Poster = ({ content }) => {
  const gradient = pickGradient(content.slug || content.title);
  return (
    <div
      className={`h-56 w-full relative rounded-lg overflow-hidden bg-linear-to-br ${gradient} border border-foreground/10`}
    >
      <div className="absolute inset-0 bg-linear-to-t from-black/80 via-black/10 to-transparent" />
      <div className="absolute inset-0 flex items-end p-3">
        <div className="space-y-1">
          <p className="text-[10px] uppercase tracking-widest text-white/60 font-semibold">
            {content.content_type}
          </p>
          <p className="text-white font-bold text-base leading-tight line-clamp-2 drop-shadow">
            {content.title}
          </p>
        </div>
      </div>
      {content.access_type === "premium" && (
        <div className="absolute top-2 right-2">
          <Badge tone="premium">
            <Crown size={10} /> Premium
          </Badge>
        </div>
      )}
    </div>
  );
};

const ContentCard = ({ content, onClick }) => {
  const year = formatYear(content.release_date);
  const duration = formatDuration(content.duration_seconds);
  const genreNames = (content.genres || []).slice(0, 2).map((g) => g.name);

  return (
    <button
      type="button"
      onClick={onClick}
      className="group relative w-full text-left"
    >
      <div className="relative transform transition-transform duration-300 group-hover:-translate-y-1 group-hover:scale-[1.03]">
        <Poster content={content} />
        <div className="absolute inset-0 rounded-lg bg-black/70 opacity-0 group-hover:opacity-100 transition-opacity duration-300 p-3 flex flex-col justify-end">
          <p className="text-white font-bold text-sm line-clamp-1">
            {content.title}
          </p>
          <div className="flex items-center gap-2 mt-1 text-[11px] text-white/70">
            {year && <span>{year}</span>}
            {duration && <span>• {duration}</span>}
            {content.age_rating && (
              <span className="px-1.5 rounded border border-white/30">
                {content.age_rating}
              </span>
            )}
          </div>
          {content.short_description && (
            <p className="mt-2 text-[11px] text-white/70 line-clamp-3">
              {content.short_description}
            </p>
          )}
          <div className="flex items-center gap-2 mt-3">
            <span className="inline-flex items-center justify-center h-8 w-8 rounded-full bg-white text-black">
              <Play size={14} fill="currentColor" />
            </span>
            <span className="inline-flex items-center justify-center h-8 w-8 rounded-full bg-foreground/10 border border-white/30 text-white">
              <Plus size={14} />
            </span>
            <span className="inline-flex items-center justify-center h-8 w-8 rounded-full bg-foreground/10 border border-white/30 text-white ml-auto">
              <Info size={14} />
            </span>
          </div>
        </div>
      </div>

      <div className="mt-2 px-1">
        <p className="text-sm font-semibold text-foreground line-clamp-1">
          {content.title}
        </p>
        <div className="flex items-center gap-2 mt-1 text-[11px] text-foreground/50">
          <ContentTypeIcon
            type={content.content_type}
            className="text-brand-primary"
          />
          <span className="capitalize">{content.content_type}</span>
          {year && <span>• {year}</span>}
          {content.is_series &&
            typeof content.total_seasons === "number" &&
            content.total_seasons > 0 && (
              <span>
                • {content.total_seasons} Season
                {content.total_seasons > 1 ? "s" : ""}
              </span>
            )}
        </div>
        {genreNames.length > 0 && (
          <p className="mt-1 text-[10px] uppercase tracking-wider text-foreground/40">
            {genreNames.join(" • ")}
          </p>
        )}
      </div>
    </button>
  );
};

const Row = ({ title, items, onContentClick }) => {
  if (!items || items.length === 0) return null;
  return (
    <section className="space-y-3">
      <div className="flex items-end justify-between px-1">
        <h2 className="text-lg md:text-xl font-bold text-foreground">
          {title}
        </h2>
        <span className="text-xs text-foreground/40">
          {items.length} title{items.length > 1 ? "s" : ""}
        </span>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
        {items.map((content) => (
          <ContentCard
            key={content.content_id}
            content={content}
            onClick={() => onContentClick(content.content_id)}
          />
        ))}
      </div>
    </section>
  );
};

const SeasonCard = ({ season, onClick, isActive }) => {
  const gradient = pickGradient(season.season_id);
  return (
    <button
      type="button"
      onClick={onClick}
      className={`group relative text-left rounded-lg overflow-hidden border transition transform hover:-translate-y-1 ${
        isActive
          ? "border-brand-primary shadow-[0_0_0_2px_rgba(219,0,0,0.4)]"
          : "border-foreground/10 hover:border-foreground/30"
      }`}
    >
      <div
        className={`h-40 w-full bg-linear-to-br ${gradient} relative`}
      >
        <div className="absolute inset-0 bg-linear-to-t from-black/80 via-black/10 to-transparent" />
        <div className="absolute inset-0 p-3 flex flex-col justify-end">
          <p className="text-[10px] uppercase tracking-widest text-white/60 font-semibold">
            Season {season.season_number}
          </p>
          <p className="text-white font-bold text-sm leading-tight line-clamp-2 drop-shadow">
            {season.title || `Season ${season.season_number}`}
          </p>
        </div>
      </div>
      <div className="p-3 bg-background/40">
        <div className="flex items-center gap-2 text-[11px] text-foreground/60">
          <span className="capitalize">{season.status}</span>
          {season.release_date && (
            <span>• {formatYear(season.release_date)}</span>
          )}
        </div>
      </div>
    </button>
  );
};

const EpisodeRow = ({ episode }) => (
  <li className="flex items-center gap-4 rounded-lg border border-foreground/10 bg-background/40 p-3 hover:bg-foreground/5 transition">
    <div
      className={`h-16 w-28 shrink-0 rounded-md bg-linear-to-br ${pickGradient(
        episode.episode_id,
      )} relative overflow-hidden border border-foreground/10`}
    >
      <div className="absolute inset-0 bg-black/30" />
      <div className="absolute inset-0 flex items-center justify-center">
        <span className="text-white font-bold text-lg drop-shadow">
          {episode.episode_number}
        </span>
      </div>
    </div>
    <div className="flex-1 min-w-0">
      <p className="text-sm font-semibold text-foreground line-clamp-1">
        {episode.title}
      </p>
      {episode.short_description && (
        <p className="text-xs text-foreground/60 line-clamp-2 mt-0.5">
          {episode.short_description}
        </p>
      )}
      <div className="flex items-center gap-2 mt-1.5 text-[11px] text-foreground/50">
        <span className="capitalize">{episode.access_type}</span>
        <span>•</span>
        <span className="capitalize">{episode.status}</span>
        {episode.duration_seconds && (
          <>
            <span>•</span>
            <span>{formatDuration(episode.duration_seconds)}</span>
          </>
        )}
        {episode.required_coins > 0 && (
          <>
            <span>•</span>
            <span className="text-amber-400">
              {episode.required_coins} coins
            </span>
          </>
        )}
      </div>
    </div>
  </li>
);

export default function ContentsTestPage() {
  const [items, setItems] = useState([]);
  const [listLoading, setListLoading] = useState(true);

  const [selectedContent, setSelectedContent] = useState(null);
  const [contentLoading, startContentLoad] = useTransition();

  const [selectedSeason, setSelectedSeason] = useState(null);
  const [seasonLoading, startSeasonLoad] = useTransition();

  useEffect(() => {
    getContents({ limit: 100 })
      .then((data) => setItems(data?.items || []))
      .finally(() => setListLoading(false));
  }, []);

  const handleContentClick = (contentId) => {
    setSelectedSeason(null);
    startContentLoad(async () => {
      const data = await getContentById(contentId);
      setSelectedContent(data);
    });
  };

  const handleSeasonClick = (seasonId) => {
    startSeasonLoad(async () => {
      const data = await getSeasonById(seasonId);
      setSelectedSeason(data);
    });
  };

  const backToList = () => {
    setSelectedContent(null);
    setSelectedSeason(null);
  };

  const published = items.filter((c) => c.status === "published");
  const trending = published.slice(0, 10);
  const movies = items.filter((c) => c.content_type === "movie");
  const series = items.filter((c) => c.content_type === "series");
  const documentaries = items.filter((c) => c.content_type === "documentary");
  const premium = items.filter((c) => c.access_type === "premium");

  return (
    <div className="relative min-h-screen w-full">
      <div className="fixed inset-0 z-0 bg-[url('/background.jpg')] bg-cover bg-center bg-no-repeat opacity-10 pointer-events-none" />

      <div className="relative z-10 p-4 md:p-8 mx-auto max-w-400 space-y-10">
        {selectedContent || contentLoading ? (
          <ContentDetailView
            content={selectedContent}
            contentLoading={contentLoading}
            selectedSeason={selectedSeason}
            seasonLoading={seasonLoading}
            onBack={backToList}
            onSeasonClick={handleSeasonClick}
          />
        ) : listLoading ? (
          <div className="rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-10 text-center">
            <p className="text-foreground/60 text-sm">Loading contents…</p>
          </div>
        ) : items.length === 0 ? (
          <div className="rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-10 text-center">
            <p className="text-foreground/60 text-sm">
              No content found. Make sure the backend is running on{" "}
              <code className="text-brand-primary">
                {process.env.NEXT_PUBLIC_API_URL}
              </code>{" "}
              and that the seeds have run.
            </p>
          </div>
        ) : (
          <>
            <Row
              title="Trending Now"
              items={trending}
              onContentClick={handleContentClick}
            />
            <Row
              title="Movies"
              items={movies}
              onContentClick={handleContentClick}
            />
            <Row
              title="Series"
              items={series}
              onContentClick={handleContentClick}
            />
            <Row
              title="Documentaries"
              items={documentaries}
              onContentClick={handleContentClick}
            />
            <Row
              title="Premium Picks"
              items={premium}
              onContentClick={handleContentClick}
            />
          </>
        )}
      </div>
    </div>
  );
}

function ContentDetailView({
  content,
  contentLoading,
  selectedSeason,
  seasonLoading,
  onBack,
  onSeasonClick,
}) {
  if (contentLoading || !content) {
    return (
      <div className="rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-10 text-center">
        <p className="text-foreground/60 text-sm">Loading content…</p>
      </div>
    );
  }

  const gradient = pickGradient(content.slug || content.title);
  const year = formatYear(content.release_date);
  const genreNames = (content.genres || []).slice(0, 3).map((g) => g.name);
  const seasons = content.seasons || [];

  return (
    <div className="space-y-8">
      <button
        type="button"
        onClick={onBack}
        className="inline-flex items-center gap-1 text-sm text-foreground/70 hover:text-foreground transition"
      >
        <ChevronLeft size={16} /> Back to library
      </button>

      <section
        className={`relative overflow-hidden rounded-2xl border border-foreground/10 bg-linear-to-br ${gradient} min-h-80 md:min-h-95 shadow-2xl`}
      >
        <div className="absolute inset-0 bg-linear-to-r from-black/80 via-black/40 to-transparent" />
        <div className="absolute inset-0 bg-linear-to-t from-black/80 via-transparent to-transparent" />

        <div className="relative z-10 h-full flex flex-col justify-end p-6 md:p-10 max-w-3xl">
          <div className="flex items-center gap-2 flex-wrap">
            {content.access_type === "premium" ? (
              <Badge tone="premium">
                <Crown size={10} /> Premium • {content.required_coins} coins
              </Badge>
            ) : (
              <Badge tone="free">Free</Badge>
            )}
            {content.age_rating && (
              <Badge tone="rating">{content.age_rating}</Badge>
            )}
            <Badge>{content.status}</Badge>
          </div>

          <h1 className="mt-3 text-3xl md:text-5xl font-extrabold text-white drop-shadow-lg leading-tight">
            {content.title}
          </h1>

          <div className="mt-3 flex items-center gap-3 text-sm text-white/80">
            <ContentTypeIcon type={content.content_type} className="text-white" />
            <span className="capitalize">{content.content_type}</span>
            {year && <span>• {year}</span>}
            {content.language && <span>• {content.language}</span>}
            {content.country && <span>• {content.country}</span>}
          </div>

          {genreNames.length > 0 && (
            <p className="mt-2 text-xs uppercase tracking-widest text-white/60 font-semibold">
              {genreNames.join(" • ")}
            </p>
          )}

          {(content.description || content.short_description) && (
            <p className="mt-4 text-sm md:text-base text-white/80 line-clamp-3 max-w-2xl">
              {content.description || content.short_description}
            </p>
          )}
        </div>
      </section>

      <section className="space-y-3">
        <div className="flex items-end justify-between px-1">
          <h2 className="text-lg md:text-xl font-bold text-foreground">
            Seasons
          </h2>
          <span className="text-xs text-foreground/40">
            {seasons.length} season{seasons.length === 1 ? "" : "s"}
          </span>
        </div>

        {seasons.length === 0 ? (
          <div className="rounded-xl border border-foreground/10 bg-background/40 p-6 text-center text-sm text-foreground/60">
            No seasons for this content.
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
            {seasons.map((s) => (
              <SeasonCard
                key={s.season_id}
                season={s}
                isActive={selectedSeason?.season_id === s.season_id}
                onClick={() => onSeasonClick(s.season_id)}
              />
            ))}
          </div>
        )}
      </section>

      <section className="space-y-3">
        <div className="flex items-end justify-between px-1">
          <h2 className="text-lg md:text-xl font-bold text-foreground">
            Episodes
            {selectedSeason
              ? ` — Season ${selectedSeason.season_number}`
              : ""}
          </h2>
          {selectedSeason?.episodes && (
            <span className="text-xs text-foreground/40">
              {selectedSeason.episodes.length} episode
              {selectedSeason.episodes.length === 1 ? "" : "s"}
            </span>
          )}
        </div>

        {seasonLoading ? (
          <div className="rounded-xl border border-foreground/10 bg-background/40 p-6 text-center text-sm text-foreground/60">
            Loading episodes…
          </div>
        ) : !selectedSeason ? (
          <div className="rounded-xl border border-foreground/10 bg-background/40 p-6 text-center text-sm text-foreground/60">
            Select a season to view its episodes.
          </div>
        ) : (selectedSeason.episodes || []).length === 0 ? (
          <div className="rounded-xl border border-foreground/10 bg-background/40 p-6 text-center text-sm text-foreground/60">
            No episodes for this season.
          </div>
        ) : (
          <ul className="space-y-2">
            {selectedSeason.episodes.map((ep) => (
              <EpisodeRow key={ep.episode_id} episode={ep} />
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
