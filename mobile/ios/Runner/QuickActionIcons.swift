import Flutter
import UIKit

/// Replaces the icons of `UIApplicationShortcutItem`s registered by Flutter's
/// `quick_actions` plugin with SF Symbols. The plugin only supports template
/// image names on iOS, so this lets us ship system-rendered icons without
/// bundling any PNG/PDF assets.
///
/// Keep the `type` keys in `symbols` in sync with `QuickActionType` in
/// `lib/core/services/quick_action_service.dart`.
enum QuickActionIcons {
  private static let channelName = "miniott/quick_actions"

  private static let symbols: [String: String] = [
    "home": "house.fill",
    "search": "magnifyingglass",
    "live": "dot.radiowaves.left.and.right",
  ]

  static func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "applySfSymbols":
        applySfSymbols()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  static func applySfSymbols() {
    guard #available(iOS 13.0, *) else { return }

    let app = UIApplication.shared
    let current = app.shortcutItems ?? []
    guard !current.isEmpty else { return }

    var didChange = false
    let updated: [UIApplicationShortcutItem] = current.map { item in
      guard let symbol = symbols[item.type] else { return item }
      didChange = true
      return UIApplicationShortcutItem(
        type: item.type,
        localizedTitle: item.localizedTitle,
        localizedSubtitle: item.localizedSubtitle,
        icon: UIApplicationShortcutIcon(systemImageName: symbol),
        userInfo: item.userInfo
      )
    }

    if didChange {
      app.shortcutItems = updated
    }
  }
}
