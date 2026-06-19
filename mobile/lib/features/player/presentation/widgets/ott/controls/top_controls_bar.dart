import 'package:flutter/material.dart';

import '../../../providers/player_ui_controller.dart';
import '../theme/ott_player_tokens.dart';

class TopControlsBar extends StatelessWidget {
  const TopControlsBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.orientationMode,
    required this.onBack,
    required this.onSettings,
    required this.onLock,
    required this.onToggleOrientation,
  });

  final String title;
  final String? subtitle;
  final OrientationMode orientationMode;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback onLock;
  final VoidCallback onToggleOrientation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: OttPlayerTokens.topScrim),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: OttPlayerTokens.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleOrientation,
                icon: Icon(
                  orientationMode == OrientationMode.landscape
                      ? Icons.stay_current_portrait_rounded
                      : Icons.stay_current_landscape_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: onLock,
                icon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: onSettings,
                icon: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
