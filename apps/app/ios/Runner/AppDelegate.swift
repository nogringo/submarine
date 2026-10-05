import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    FlutterMethodChannel(
      name: "submarine/clipboard",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    ).setMethodCallHandler { call, result in
      guard call.method == "copy", let args = call.arguments as? [String: Any],
        let text = args["text"] as? String
      else { return result(FlutterMethodNotImplemented) }
      var options: [UIPasteboard.OptionsKey: Any] = [:]
      // iOS suspends the app in the background, before a timer of its own could clear the copy.
      if let clearAfter = args["clearAfter"] as? Int {
        options[.expirationDate] = Date(timeIntervalSinceNow: Double(clearAfter) / 1000)
      }
      UIPasteboard.general.setItems([[UTType.utf8PlainText.identifier: text]], options: options)
      result(nil)
    }
  }
}
