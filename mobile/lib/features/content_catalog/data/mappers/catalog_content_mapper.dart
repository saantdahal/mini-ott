import '../../../../app/flavor/app_flavor.dart';
import '../../../content_details/domain/entities/title_detail.dart';
import '../../../home/domain/entities/content_entity.dart';
import '../../../search/domain/entities/search_result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/hls_playback_entity.dart';
import '../../domain/entities/season_entity.dart';
import '../models/content_catalog_dtos.dart';

class CatalogContentMapper {
  CatalogContentMapper._();

  static String mediaUrl(String? key) {
    if (key == null || key.isEmpty) return '';
    if (key.startsWith('http://') || key.startsWith('https://')) return key;
    final base = AppFlavorConfig.mediaCdnBaseUrl.trim();
    if (base.isEmpty) return '';
    final cleanBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final path = key.startsWith('/') ? key.substring(1) : key;
    return '$cleanBase/$path';
  }

  static CategoryEntity toCategoryEntity(CategoryDto dto) {
    return CategoryEntity(id: dto.categoryId, name: dto.name);
  }

  static GenreEntity toGenreEntity(GenreDto dto) {
    return GenreEntity(id: dto.genreId, name: dto.name);
  }

  static List<String> genreNames(ContentApiDto dto) {
    final g = dto.genres;
    if (g == null || g.isEmpty) return const [];
    return g.map((e) => e.name).toList();
  }

  static List<ContentCategory> toCategories(ContentApiDto dto) {
    final c = dto.categories;
    if (c == null || c.isEmpty) return const [];
    return c
        .map(
          (e) => ContentCategory(
            categoryId: e.categoryId,
            name: e.name,
            description: e.description,
            sortOrder: e.sortOrder,
          ),
        )
        .toList();
  }

  static ContentEntity toContentEntity(ContentApiDto dto) {
    final genres = genreNames(dto);
    final categories = toCategories(dto);
    final thumb = mediaUrl(dto.thumbnailKey);
    final posterKey = dto.posterKey;
    final poster = mediaUrl(
      (posterKey != null && posterKey.isNotEmpty)
          ? posterKey
          : dto.thumbnailKey,
    );
    final access = dto.accessType ?? '';
    final ct = (dto.contentType ?? '').toLowerCase();
    final isSeries = dto.isSeries == true || ct == 'series';
    final epCount = dto.totalEpisodes ?? 0;
    final dur = formatDuration(dto.durationSeconds);

    String? subtitle;
    if (isSeries && epCount > 0) {
      subtitle = '$epCount Episode${epCount == 1 ? '' : 's'}';
    } else if (dur.isNotEmpty) {
      subtitle = dur;
    } else if (genres.isNotEmpty) {
      subtitle = genres.take(2).join(' • ');
    }

    String? chip;
    if (isSeries && epCount > 0) {
      chip = '$epCount Episodes';
    } else if (ct.isNotEmpty) {
      chip = ct[0].toUpperCase() + ct.substring(1);
    }

    return ContentEntity(
      id: dto.contentId,
      title: dto.title,
      description: (dto.description ?? dto.shortDescription ?? '').trim(),
      thumbnailUrl: thumb,
      posterUrl: poster.isNotEmpty ? poster : thumb,
      genres: genres,
      categories: categories,
      rating: 0,
      accessType: access,
      isWatching: false,
      watchingProgress: '',
      contentType: dto.contentType ?? '',
      ageRating: dto.ageRating ?? '',
      cardSubtitle: subtitle,
      freeBannerText: access == 'free' ? 'FREE' : null,
      episodeChip: chip,
      showPremiumLock: access == 'premium',
    );
  }

  static SearchResult toSearchResult(ContentApiDto dto) {
    final genres = genreNames(dto);
    final pk = dto.posterKey;
    final poster = mediaUrl(
      (pk != null && pk.isNotEmpty) ? pk : dto.thumbnailKey,
    );
    final access = dto.accessType ?? '';
    final dur = formatDuration(dto.durationSeconds);
    return SearchResult(
      id: dto.contentId,
      title: dto.title,
      description: (dto.description ?? dto.shortDescription ?? '').trim(),
      posterUrl: poster,
      contentType: dto.contentType ?? '',
      genres: genres,
      rating: 0,
      duration: dur.isEmpty ? '—' : dur,
      isTrendingTag: false,
      isPremiumTag: access == 'premium',
    );
  }

  static String formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return '${seconds}s';
  }

  static TitleDetail toTitleDetail(ContentApiDto dto) {
    final genres = genreNames(dto);
    final pk = dto.posterKey;
    final bn = dto.bannerKey;
    final hero = mediaUrl(
      (pk != null && pk.isNotEmpty)
          ? pk
          : ((bn != null && bn.isNotEmpty) ? bn : dto.thumbnailKey),
    );
    final synopsisRaw = (dto.description ?? dto.shortDescription ?? '').trim();
    final synopsis = synopsisRaw.isNotEmpty
        ? synopsisRaw
        : 'No synopsis available.';

    final isSeries = dto.isSeries == true;
    final seasons = [...?dto.seasons]
      ..sort((a, b) => (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0));
    final seasonIds = seasons.map((s) => s.seasonId).toList();
    final seasonTitlesById = <String, String>{};
    for (final s in seasons) {
      final id = s.seasonId;
      if (id.isEmpty) continue;
      final apiTitle = (s.title ?? '').trim();
      final num = s.seasonNumber;
      seasonTitlesById[id] = apiTitle.isNotEmpty
          ? apiTitle
          : (num != null ? 'Season $num' : id);
    }

    final episodesBySeasonId = <String, List<TitleEpisode>>{};
    final flatEpisodes = [...?dto.episodes];

    if (flatEpisodes.isNotEmpty) {
      for (final ep in flatEpisodes) {
        final sid =
            ep.seasonId ?? (seasonIds.isNotEmpty ? seasonIds.first : 'library');
        episodesBySeasonId.putIfAbsent(sid, () => []).add(_mapEpisode(ep));
      }
      for (final e in episodesBySeasonId.values) {
        e.sort((a, b) => a.index.compareTo(b.index));
      }
    } else if (!isSeries) {
      episodesBySeasonId['library'] = [
        TitleEpisode(
          index: 1,
          title: dto.title,
          duration: formatDuration(dto.durationSeconds).isEmpty
              ? 'Feature'
              : formatDuration(dto.durationSeconds),
          thumbnailUrl: mediaUrl(dto.thumbnailKey).isEmpty
              ? hero
              : mediaUrl(dto.thumbnailKey),
          isFree: (dto.accessType ?? 'free') == 'free',
          coinCost: dto.requiredCoins,
          streamManifestKey: dto.streamManifestKey,
        ),
      ];
    }

    final totalEp = dto.totalEpisodes ?? flatEpisodes.length;
    final label = isSeries ? '$totalEp Episodes' : 'Feature film';

    return TitleDetail(
      id: dto.contentId,
      title: dto.title,
      heroImageUrl: hero.isEmpty ? mediaUrl(dto.thumbnailKey) : hero,
      genres: genres.isEmpty ? const ['General'] : genres,
      starRating: 4,
      episodeCountLabel: label,
      isSeries: isSeries,
      synopsis: synopsis,
      cast: const [],
      seasonIds: seasonIds.isNotEmpty ? seasonIds : const ['library'],
      seasonTitlesById: seasonTitlesById,
      episodesBySeasonId: episodesBySeasonId.isNotEmpty
          ? episodesBySeasonId
          : {'library': const <TitleEpisode>[]},
      unlockCoinCost: dto.requiredCoins ?? 0,
      totalEpisodesForUnlock: totalEp > 0 ? totalEp : 1,
      streamManifestKey: dto.streamManifestKey,
      videoUploadId: dto.videoUploadId,
    );
  }

  static TitleEpisode _mapEpisode(EpisodeApiDto ep) {
    final free = (ep.accessType ?? 'free') == 'free';
    return TitleEpisode(
      index: ep.episodeNumber ?? 0,
      title: ep.title ?? 'Episode',
      duration: formatDuration(ep.durationSeconds).isEmpty
          ? '—'
          : formatDuration(ep.durationSeconds),
      thumbnailUrl: mediaUrl(ep.thumbnailKey),
      isFree: free,
      coinCost: free ? null : ep.requiredCoins,
      episodeId: ep.episodeId.isEmpty ? null : ep.episodeId,
      streamManifestKey: ep.streamManifestKey,
      videoUploadId: ep.videoUploadId,
    );
  }

  static HlsPlaybackEntity toHlsEntity(HlsPlaybackDataDto? dto) {
    if (dto == null) {
      return const HlsPlaybackEntity();
    }
    return HlsPlaybackEntity(
      manifestUrl: dto.manifestUrl,
      baseUrl: dto.baseUrl,
      expiresInSeconds: dto.expiresIn,
      phase: dto.phase,
    );
  }

  static SeasonEntity toSeasonEntity(SeasonApiDto dto) {
    final thumb = mediaUrl(dto.thumbnailKey);
    return SeasonEntity(
      id: dto.seasonId,
      contentId: dto.contentId ?? '',
      seasonNumber: dto.seasonNumber ?? 0,
      title: dto.title,
      description: dto.description,
      thumbnailUrl: thumb.isEmpty ? null : thumb,
      releaseDate: dto.releaseDate,
      status: dto.status,
    );
  }

  static EpisodeEntity toEpisodeEntity(EpisodeApiDto dto) {
    final thumb = mediaUrl(dto.thumbnailKey);
    final banner = mediaUrl(dto.bannerKey);
    return EpisodeEntity(
      id: dto.episodeId,
      contentId: dto.contentId ?? '',
      seasonId: dto.seasonId,
      episodeNumber: dto.episodeNumber ?? 0,
      title: (dto.title ?? '').trim().isEmpty ? 'Episode' : dto.title!,
      description: dto.description,
      shortDescription: dto.shortDescription,
      thumbnailUrl: thumb.isEmpty ? null : thumb,
      bannerUrl: banner.isEmpty ? null : banner,
      streamManifestKey: dto.streamManifestKey,
      durationSeconds: dto.durationSeconds,
      accessType: dto.accessType,
      requiredCoins: dto.requiredCoins,
      status: dto.status,
      releaseDate: dto.releaseDate,
    );
  }
}
