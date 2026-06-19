import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../content_details/domain/entities/title_detail.dart';
import '../theme/ott_player_tokens.dart';
import '_sheet_chrome.dart';

/// Renders the episodes passed to the player as a route arg. Uses
/// `ListView.builder` + `cached_network_image` so opening the sheet on a
/// long season is cheap.
class EpisodeListSheet extends StatelessWidget {
  const EpisodeListSheet({
    super.key,
    required this.episodes,
    required this.currentIndex,
    required this.onPick,
  });

  final List<TitleEpisode> episodes;
  final int currentIndex;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return PlayerSheetScaffold(
      title: 'Episodes',
      subtitle: '${episodes.length} in this season',
      child: SizedBox(
        height: 240,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: episodes.length,
          itemBuilder: (context, i) {
            final ep = episodes[i];
            final isCurrent = i == currentIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                color: isCurrent
                    ? OttPlayerTokens.accent.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isCurrent
                      ? null
                      : () {
                          Navigator.of(context).maybePop();
                          onPick(i);
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 110,
                            height: 64,
                            child: ep.thumbnailUrl.isEmpty
                                ? const ColoredBox(
                                    color: Colors.white10,
                                    child: Icon(
                                      Icons.movie_outlined,
                                      color: Colors.white30,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: ep.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => const ColoredBox(
                                      color: Colors.white10,
                                    ),
                                    errorWidget: (_, _, _) => const ColoredBox(
                                      color: Colors.white10,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'E${ep.index} · ${ep.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight:
                                      isCurrent
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ep.duration,
                                style: const TextStyle(
                                  color: OttPlayerTokens.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.play_circle_rounded,
                              color: OttPlayerTokens.accentSoft,
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
