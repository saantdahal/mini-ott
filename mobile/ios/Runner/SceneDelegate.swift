import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    // Safety net: if Flutter set shortcuts before our method-channel call
    // fired (e.g. fast cold-launch), re-stamp them with SF Symbols.
    QuickActionIcons.applySfSymbols()
  }
}
