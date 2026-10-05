import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  /// The launch screen, over the app while it is not active, for the app switcher to show instead.
  private var cover: UIWindow?

  // FlutterSceneDelegate forwards these events to Flutter from methods its header leaves out, which
  // Swift would replace rather than override.
  override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self, selector: #selector(willDeactivate), name: UIScene.willDeactivateNotification, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(didActivate), name: UIScene.didActivateNotification, object: nil)
  }

  @objc private func willDeactivate(_ notification: Notification) {
    guard let scene = notification.object as? UIWindowScene else { return }
    if cover == nil {
      let window = UIWindow(windowScene: scene)
      window.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil)
        .instantiateInitialViewController()
      window.windowLevel = .alert + 1
      cover = window
    }
    cover?.isHidden = false
  }

  @objc private func didActivate(_ notification: Notification) {
    cover?.isHidden = true
  }
}
