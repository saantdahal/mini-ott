import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/playback_source.dart';
import '../../domain/network_playback_args.dart';
import '../args/video_playback_args.dart';
import '../providers/playback_notifier.dart';
import '../widgets/ott/ott_player_view.dart';
import '../widgets/player_controls_config.dart';
import '../widgets/player_message.dart';
import '../widgets/player_scaffold.dart';

const _playerOrientations = [
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];

const _defaultOrientations = [
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
];

void _enterImmersiveMode() {
  unawaited(SystemChrome.setPreferredOrientations(_playerOrientations));
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
}

void _exitImmersiveMode() {
  unawaited(SystemChrome.setPreferredOrientations(_defaultOrientations));
  unawaited(
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    ),
  );
}

class NetworkVideoPlayerScreen extends StatefulWidget {
  const NetworkVideoPlayerScreen({super.key, required this.args});

  final NetworkPlaybackArgs args;

  @override
  State<NetworkVideoPlayerScreen> createState() =>
      _NetworkVideoPlayerScreenState();
}

class _NetworkVideoPlayerScreenState extends State<NetworkVideoPlayerScreen> {
  BetterPlayerController? _controller;
  final GlobalKey _playerKey = GlobalKey();
  String? _invalidReason;
  String? _errorReason;
  bool _isRetrying = false;
  bool _initialized = false;
  Timer? _initWatchdog;
  String? _lastException;

  @override
  void initState() {
    super.initState();
    _enterImmersiveMode();
    _initializePlayer(widget.args.url);
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _initialized = true;
        _initWatchdog?.cancel();
        if (_errorReason != null) {
          setState(() => _errorReason = null);
        }
      case BetterPlayerEventType.exception:
        _lastException = event.parameters?['exception']?.toString();
        if (_initialized) return;
        _initWatchdog?.cancel();
        _initWatchdog = Timer(const Duration(seconds: 8), () {
          if (!mounted || _initialized) return;
          setState(() {
            _errorReason = _lastException == null
                ? 'We could not play this video. Please check your connection and try again.'
                : 'Playback failed: $_lastException';
            _controller?.dispose();
            _controller = null;
          });
        });
      default:
        break;
    }
  }

  void _initializePlayer(String url) {
    if (url.isEmpty) {
      setState(() {
        _invalidReason = 'No playable stream available for this content.';
      });
      return;
    }

    _initWatchdog?.cancel();
    _initialized = false;
    _lastException = null;
    setState(() {
      _errorReason = null;
      _isRetrying = false;
      _controller?.dispose();
      _controller = null;
      _invalidReason = null;
    });

    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      setState(() {
        _invalidReason = 'Invalid playback URL: $url';
      });
      return;
    }

    final lower = url.toLowerCase();
    final looksHls =
        lower.contains('.m3u8') ||
        lower.contains('/hls') ||
        lower.contains('m3u8?');

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      videoFormat: looksHls ? BetterPlayerVideoFormat.hls : null,
      useAsmsTracks: looksHls,
      useAsmsSubtitles: looksHls,
      useAsmsAudioTracks: looksHls,
    );

    setState(() {
      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          aspectRatio: 16 / 9,
          fit: BoxFit.contain,
          handleLifecycle: true,
          allowedScreenSleep: false,
          expandToFill: true,
          controlsConfiguration: buildPlayerControlsConfiguration(),
          errorBuilder: (context, errorMessage) => PlayerInlineError(
            message: errorMessage,
            onRetry: () => _initializePlayer(widget.args.url),
          ),
          eventListener: _onPlayerEvent,
        ),
        betterPlayerDataSource: dataSource,
      );
    });
  }

  @override
  void dispose() {
    _initWatchdog?.cancel();
    _controller?.dispose();
    _exitImmersiveMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reason = _invalidReason;
    if (reason != null) {
      return PlayerScaffold(
        title: widget.args.displayTitle,
        child: PlayerMessage(
          icon: Icons.error_outline,
          iconColor: colorScheme.error,
          title: 'Invalid URL',
          body: reason,
        ),
      );
    }

    if (_errorReason != null && _controller == null) {
      return PlayerScaffold(
        title: widget.args.displayTitle,
        child: PlayerMessage(
          icon: Icons.warning_amber_rounded,
          iconColor: colorScheme.tertiary,
          title: 'Playback Error',
          body: _errorReason!,
          action: ElevatedButton.icon(
            onPressed: _isRetrying
                ? null
                : () => _initializePlayer(widget.args.url),
            icon: const Icon(Icons.refresh),
            label: Text(_isRetrying ? 'Retrying...' : 'Try Again'),
          ),
        ),
      );
    }

    if (_controller == null) {
      return PlayerScaffold(
        title: widget.args.displayTitle,
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return PlayerScaffold(
      title: widget.args.displayTitle,
      immersive: true,
      child: OttPlayerView(
        controller: _controller!,
        playerKey: _playerKey,
        title: widget.args.displayTitle,
        subtitle: widget.args.episodeLabel,
        progressKey: widget.args.progressKey ?? 'url:${widget.args.url}',
      ),
    );
  }
}

class VideoUploadPlayerScreen extends ConsumerStatefulWidget {
  const VideoUploadPlayerScreen({super.key, required this.args});

  final VideoUploadPlaybackArgs args;

  @override
  ConsumerState<VideoUploadPlayerScreen> createState() =>
      _VideoUploadPlayerScreenState();
}

class _VideoUploadPlayerScreenState
    extends ConsumerState<VideoUploadPlayerScreen> {
  BetterPlayerController? _controller;
  PlaybackSource? _activeSource;
  final GlobalKey _playerKey = GlobalKey();

  /// Active arguments. Starts as `widget.args` and is mutated when the user
  /// jumps to a different episode from inside the player. Mutating in place
  /// (instead of `pushReplacement`) avoids briefly disposing the screen,
  /// which would otherwise flip the device back to portrait between episodes.
  late VideoUploadPlaybackArgs _currentArgs;

  @override
  void initState() {
    super.initState();
    _currentArgs = widget.args;
    _enterImmersiveMode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    ref
        .read(playbackNotifierProvider.notifier)
        .load(
          contentId: _currentArgs.contentId,
          title: _currentArgs.displayTitle,
          hasManifestKey: _currentArgs.hasManifestKey,
          episodeId: _currentArgs.episodeId,
          uploadId: _currentArgs.uploadId,
        );
  }

  void _ensureController(PlaybackSource source) {
    if (identical(source, _activeSource) && _controller != null) return;
    _controller?.dispose();
    final dataSource = switch (source) {
      HlsSource(manifestUrl: final url) => BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        videoFormat: BetterPlayerVideoFormat.hls,
        useAsmsTracks: true,
        useAsmsSubtitles: true,
        useAsmsAudioTracks: true,
      ),
      Mp4Source(url: final url) => BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        useAsmsTracks: false,
        useAsmsSubtitles: false,
        useAsmsAudioTracks: false,
      ),
    };
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        handleLifecycle: true,
        allowedScreenSleep: false,
        expandToFill: true,
        controlsConfiguration: buildPlayerControlsConfiguration(),
        errorBuilder: (context, errorMessage) =>
            PlayerInlineError(message: errorMessage, onRetry: _load),
      ),
      betterPlayerDataSource: dataSource,
    );
    _activeSource = source;
  }

  void _onPickEpisode(int newIndex) {
    final pl = _currentArgs.playlist;
    if (pl == null || newIndex < 0 || newIndex >= pl.length) return;
    if (newIndex == _currentArgs.currentIndex) return;
    final ep = pl[newIndex];
    setState(() {
      _currentArgs = VideoUploadPlaybackArgs(
        contentId: _currentArgs.contentId,
        displayTitle: ep.codeLabel,
        hasManifestKey: ep.hasManifestKey,
        episodeId: ep.episodeId,
        uploadId: ep.videoUploadId,
        episodeLabel: ep.codeLabel,
        playlist: pl,
        currentIndex: newIndex,
      );
    });
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _exitImmersiveMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(playbackNotifierProvider);

    return switch (state) {
      PlaybackIdle() || PlaybackLoading() => PlayerScaffold(
        title: _currentArgs.displayTitle,
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      ),
      PlaybackReady(:final source) => Builder(
        builder: (_) {
          _ensureController(source);
          return PlayerScaffold(
            title: _currentArgs.displayTitle,
            immersive: true,
            child: OttPlayerView(
              controller: _controller!,
              playerKey: _playerKey,
              title: _currentArgs.displayTitle,
              subtitle: _currentArgs.episodeLabel,
              progressKey: _currentArgs.progressKey,
              playlist: _currentArgs.playlist,
              currentIndex: _currentArgs.currentIndex,
              onPickEpisode: _onPickEpisode,
            ),
          );
        },
      ),
      PlaybackNoVideo() => PlayerScaffold(
        title: _currentArgs.displayTitle,
        child: const Center(child: Text('No video available')),
      ),
      PlaybackError(:final message) => PlayerScaffold(
        title: _currentArgs.displayTitle,
        child: PlayerMessage(
          icon: Icons.warning_amber_rounded,
          iconColor: colorScheme.tertiary,
          title: 'Playback Error',
          body: message,
          action: ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ),
      ),
    };
  }
}
