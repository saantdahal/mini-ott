import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/shared/widgets/back_button.dart';

import '../../../../app/routes/router_configuration.dart';
import '../../../content_catalog/di/content_catalog_di.dart';
import '../../../player/presentation/args/video_playback_args.dart';
import '../../../content_catalog/data/mappers/catalog_content_mapper.dart';
import '../../../player/domain/network_playback_args.dart';
import '../../domain/entities/title_detail.dart';
import '../widgets/title_detail_cast_strip.dart';
import '../widgets/title_detail_episode_tile.dart';
import '../widgets/title_detail_unlock_card.dart';

class TitleDetailScreen extends ConsumerStatefulWidget {
  const TitleDetailScreen({super.key, required this.contentId});

  final String contentId;

  @override
  ConsumerState<TitleDetailScreen> createState() => _TitleDetailScreenState();
}

class _TitleDetailScreenState extends ConsumerState<TitleDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _synopsisExpanded = false;
  bool _showScrollTop = false;
  String? _seasonId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final v = _scrollController.offset > 320;
      if (v != _showScrollTop) {
        setState(() => _showScrollTop = v);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _seasonDropdownValue(TitleDetail detail) {
    final ids = detail.seasonIds;
    if (ids.isEmpty) return 'library';
    if (_seasonId != null && ids.contains(_seasonId)) return _seasonId!;
    return ids.first;
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(titleDetailProvider(widget.contentId));
    final colorScheme = Theme.of(context).colorScheme;

    return asyncDetail.when(
      data: (detail) => _buildContent(context, detail, colorScheme),
      loading: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(child: Text('Error loading content')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TitleDetail detail,
    ColorScheme colorScheme,
  ) {
    final mq = MediaQuery.of(context);
    final expandedH = (mq.size.height * 0.44).clamp(280.0, 420.0);
    final synopsis = detail.synopsis;
    final synopsisShort = synopsis.length > 160
        ? '${synopsis.substring(0, 160)}…'
        : synopsis;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: _showScrollTop
          ? FloatingActionButton.small(
              heroTag: 'title_detail_top_${widget.contentId}',
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                );
              },
              child: const Icon(Icons.arrow_upward_rounded),
            )
          : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedH,
            backgroundColor: colorScheme.surface,
            leading: CustomIconButton(icon: Icons.arrow_back_ios_rounded),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: detail.heroImageUrl,
                    fit: BoxFit.fill,
                    placeholder: (context, url) =>
                        ColoredBox(color: colorScheme.surfaceContainerHighest),
                    errorWidget: (context, url, error) => ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.movie_outlined,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.scrim.withValues(alpha: 0.15),
                          colorScheme.scrim.withValues(alpha: 0.35),
                          colorScheme.scrim.withValues(alpha: 0.92),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18.w,
                    right: 18.w,
                    bottom: 20.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          detail.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 26.sp,
                            height: 1.05,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ...detail.genres
                                .take(3)
                                .map(
                                  (g) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      g.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: colorScheme.tertiary,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  detail.starRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  detail.episodeCountLabel,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: colorScheme.surface.withValues(alpha: 0.0),
                          child: InkWell(
                            onTap: () => _onWatchNow(context, detail),
                            borderRadius: BorderRadius.circular(14.r),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primaryContainer,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: colorScheme.onPrimary,
                                      size: 26.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Watch Now',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _iconAction(Icons.bookmark_add_rounded, () {}),
                      SizedBox(width: 10.w),
                      _iconAction(Icons.share_rounded, () {}),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _synopsisExpanded ? synopsis : synopsisShort,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                          height: 1.45,
                        ),
                      ),
                      if (synopsis.length > 160) ...[
                        SizedBox(height: 6.h),
                        GestureDetector(
                          onTap: () => setState(
                            () => _synopsisExpanded = !_synopsisExpanded,
                          ),
                          child: Text(
                            _synopsisExpanded ? 'See less' : 'See more',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 28.h),
                  TitleDetailCastStrip(cast: detail.cast),
                  if (detail.isSeries) ...[
                    SizedBox(height: 28.h),
                    Row(
                      children: [
                        Text(
                          'SEASON',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.sp,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _seasonDropdownValue(detail),
                                  dropdownColor:
                                      colorScheme.surfaceContainerHigh,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 22.sp,
                                  ),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                  ),
                                  selectedItemBuilder: (context) {
                                    return detail.seasonIds.map((id) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _seasonLabel(detail, id),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList();
                                  },
                                  items: detail.seasonIds
                                      .map(
                                        (id) => DropdownMenuItem(
                                          value: id,
                                          child: Text(
                                            _seasonLabel(detail, id),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _seasonId = v);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ...detail
                        .episodesForSeason(_seasonDropdownValue(detail))
                        .map(
                          (e) => TitleDetailEpisodeTile(
                            episode: e,
                            onPlayTap: _episodePlayTap(context, detail, e),
                          ),
                        ),
                  ],
                  if (detail.isSeries) ...[
                    SizedBox(height: 10.h),
                    TitleDetailUnlockCard(
                      coinCost: detail.unlockCoinCost,
                      totalEpisodes: detail.totalEpisodesForUnlock,
                      onUnlock: () => context.go(AppRoutes.coins),
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _episodePlayTap(
    BuildContext context,
    TitleDetail detail,
    TitleEpisode e,
  ) {
    final seasonId = _seasonDropdownValue(detail);
    final playlist = detail.episodesForSeason(seasonId);
    final index = playlist.indexWhere((ep) => ep.episodeId == e.episodeId);
    return () => _openPlayback(
      context,
      contentId: detail.id,
      displayTitle: e.codeLabel,
      hasManifestKey: e.hasManifestKey,
      episodeId: e.episodeId,
      uploadId: e.videoUploadId,
      episodeLabel: e.codeLabel,
      playlist: playlist,
      currentIndex: index < 0 ? 0 : index,
    );
  }

  void _openPlayback(
    BuildContext context, {
    required String contentId,
    required String displayTitle,
    required bool hasManifestKey,
    String? episodeId,
    String? uploadId,
    String? episodeLabel,
    List<TitleEpisode>? playlist,
    int currentIndex = 0,
  }) {
    context.push(
      AppRoutes.player,
      extra: VideoUploadPlaybackArgs(
        contentId: contentId,
        displayTitle: displayTitle,
        hasManifestKey: hasManifestKey,
        episodeId: episodeId,
        uploadId: uploadId,
        episodeLabel: episodeLabel,
        playlist: playlist,
        currentIndex: currentIndex,
      ),
    );
  }

  void _onWatchNow(BuildContext context, TitleDetail detail) {
    // Pick a "best" episode/manifest signal: for movies, the content's own
    // manifest; for series, the first episode that has a manifest, or just
    // episode 1 if none do (the player will surface "no video" gracefully).
    bool hasManifestKey = detail.hasManifestKey;
    String? episodeId;
    String? uploadId = detail.videoUploadId;
    if (!hasManifestKey) {
      for (final sid in detail.seasonIds) {
        for (final ep in detail.episodesForSeason(sid)) {
          if (ep.hasManifestKey) {
            hasManifestKey = true;
            episodeId = ep.episodeId;
            uploadId = ep.videoUploadId;
            break;
          }
          if (uploadId == null && (ep.videoUploadId?.isNotEmpty ?? false)) {
            episodeId = ep.episodeId;
            uploadId = ep.videoUploadId;
          }
        }
        if (hasManifestKey) break;
      }
    }
    // Resolve the playlist for the active season so the player can offer the
    // episode list / next-episode autoplay.
    final activeSeasonId = _seasonDropdownValue(detail);
    final playlist = detail.episodesForSeason(activeSeasonId);
    final episodeIndex = episodeId == null
        ? 0
        : playlist.indexWhere((ep) => ep.episodeId == episodeId);

    // If we have a raw manifest key, prefer opening the player with a direct
    // network URL (no API call). This uses the configured media CDN base.
    if (hasManifestKey) {
      String? manifestKey;
      if (episodeId != null && episodeId.isNotEmpty) {
        for (final sid in detail.seasonIds) {
          for (final ep in detail.episodesForSeason(sid)) {
            if (ep.episodeId == episodeId) {
              manifestKey = ep.streamManifestKey;
              break;
            }
          }
          if (manifestKey != null) break;
        }
      }
      manifestKey ??= detail.streamManifestKey;
      final url = CatalogContentMapper.mediaUrl(manifestKey);
      if (url.isNotEmpty) {
        // Movies (no playlist) take the direct-URL path; series fall through
        // to the upload-aware path so the player gets the episode queue.
        if (!detail.isSeries || playlist.length <= 1) {
          context.push(
            AppRoutes.player,
            extra: NetworkPlaybackArgs(
              url: url,
              displayTitle: detail.title,
              progressKey: 'content:${detail.id}',
            ),
          );
          return;
        }
      }
    }

    _openPlayback(
      context,
      contentId: detail.id,
      displayTitle: detail.title,
      hasManifestKey: hasManifestKey,
      episodeId: episodeId,
      uploadId: uploadId,
      episodeLabel: episodeId == null
          ? null
          : (episodeIndex >= 0 && episodeIndex < playlist.length
              ? playlist[episodeIndex].codeLabel
              : null),
      playlist: detail.isSeries ? playlist : null,
      currentIndex: episodeIndex < 0 ? 0 : episodeIndex,
    );
  }

  String _seasonLabel(TitleDetail detail, String id) {
    final t = detail.seasonTitlesById[id];
    if (t != null && t.isNotEmpty) return t;
    if (id == 'library') return 'Library';
    final i = detail.seasonIds.indexOf(id);
    if (i >= 0) return 'Season ${i + 1}';
    return id;
  }

  Widget _iconAction(IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          width: 52.w,
          height: 52.w,
          child: Icon(icon, color: colorScheme.onSurface, size: 22.sp),
        ),
      ),
    );
  }
}
