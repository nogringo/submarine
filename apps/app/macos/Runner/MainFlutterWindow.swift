import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    FlutterMethodChannel(
      name: "submarine/clipboard",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    ).setMethodCallHandler { call, result in
      guard call.method == "copy", let args = call.arguments as? [String: Any],
        let text = args["text"] as? String
      else { return result(FlutterMethodNotImplemented) }
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(text, forType: .string)
      if let clearAfter = args["clearAfter"] as? Int {
        // A copy made since, here or in another app, changes the count.
        let copied = pasteboard.changeCount
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(clearAfter)) {
          if pasteboard.changeCount == copied { pasteboard.clearContents() }
        }
      }
      result(nil)
    }

    super.awakeFromNib()
  }
}
