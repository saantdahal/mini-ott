import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import '../../app/routes/router_configuration.dart';

/// Shortcut identifiers — the contract shared between Dart, Android drawable
/// resource names (`ic_shortcut_<type>.xml`), and the iOS SF Symbol mapping in
/// `AppDelegate.swift`. Add a new entry here, register a drawable, and add a
/// symbol mapping on iOS to introduce a new shortcut.
class QuickActionType {
  const QuickActionType._();

  static const String home = 'home';
  static const String search = 'search';
  static const String live = 'live';
}

/// Manages OS home-screen quick actions (long-press app icon).
///
/// Lifecycle:
/// 1. [register] is called once at app startup. It tells the OS about the
///    shortcut items and wires the action callback. Cold-start shortcuts
///    arrive immediately and are queued — they do **not** navigate yet.
/// 2. Splash, after determining auth state, calls [consumePending] to read
///    the queued path and [activate] to switch the service to live mode.
///    Splash then navigates to the path itself (bypassing `/dashboard`),
///    so the user goes splash → target with no login flash.
/// 3. Subsequent shortcut taps (warm starts) navigate via the router
///    immediately.
class QuickActionService {
  QuickActionService._();

  static const MethodChannel _iosBridge = MethodChannel(
    'miniott/quick_actions',
  );

  static final QuickActions _quickActions = const QuickActions();

  static GoRouter? _router;
  static String? _pendingPath;
  static bool _registered = false;
  static bool _active = false;

  /// Take and clear any queued cold-start path. Splash calls this to find
  /// out where the user wanted to go.
  static String? consumePending() {
    final path = _pendingPath;
    _pendingPath = null;
    return path;
  }

  /// Switch to live mode — subsequent shortcut taps navigate immediately
  /// via the router. Splash calls this once auth has resolved.
  static void activate() {
    _active = true;
  }

  /// Register OS shortcut items and wire the action callback. Idempotent.
  static Future<void> register({required GoRouter router}) async {
    _router = router;
    if (_registered) return;
    _registered = true;

    await _quickActions.setShortcutItems(const <ShortcutItem>[
      ShortcutItem(
        type: QuickActionType.home,
        localizedTitle: 'Home',
        icon: 'ic_shortcut_home',
      ),
      ShortcutItem(
        type: QuickActionType.search,
        localizedTitle: 'Search',
        icon: 'ic_shortcut_search',
      ),
      ShortcutItem(
        type: QuickActionType.live,
        localizedTitle: 'Live',
        icon: 'ic_shortcut_live',
      ),
    ]);

    // iOS only: replace the (missing) template-image icons with SF Symbols.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _iosBridge.invokeMethod<void>('applySfSymbols');
      } on PlatformException catch (_) {
        // sceneDidBecomeActive will retry.
      } on MissingPluginException catch (_) {
        // Channel not registered — should not happen in release builds.
      }
    }

    // Wire the callback. A cold-start shortcut arrives here within the next
    // few event-loop turns and is queued in [_pendingPath] because [_active]
    // is still false.
    _quickActions.initialize(_handle);
  }

  static void _handle(String type) {
    final path = _pathFor(type);
    if (path == null) return;

    if (!_active || _router == null) {
      _pendingPath = path;
      return;
    }
    _router!.go(path);
  }

  static String? _pathFor(String type) {
    switch (type) {
      case QuickActionType.home:
        return AppRoutes.dashboard;
      case QuickActionType.search:
        return AppRoutes.search;
      case QuickActionType.live:
        return AppRoutes.ott;
    }
    return null;
  }
}
