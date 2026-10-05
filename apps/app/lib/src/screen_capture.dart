import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'secure_storage.dart';

/// Whether screenshots, recordings and screen sharing may show the app on this
/// Android device, as Bitwarden offers it. Blocked unless allowed.
class ScreenCapture extends ChangeNotifier {
  ScreenCapture._(this._allowed);

  static const _key = 'screenCapture';
  static const _channel = MethodChannel('submarine/screen_capture');

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<ScreenCapture> load() async {
    final allowed = await secureStorage.read(key: _key) == 'true';
    // Android starts the app with the capture blocked.
    if (allowed && supported) await _channel.invokeMethod<void>('allow', true);
    return ScreenCapture._(allowed);
  }

  static ScreenCapture of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ScreenCaptureScope>()!
      .notifier!;

  bool get allowed => _allowed;
  bool _allowed;

  Future<void> setAllowed(bool allowed) async {
    _allowed = allowed;
    notifyListeners();
    await _channel.invokeMethod<void>('allow', allowed);
    await secureStorage.write(key: _key, value: '$allowed');
  }
}

class ScreenCaptureScope extends InheritedNotifier<ScreenCapture> {
  const ScreenCaptureScope({
    super.key,
    required ScreenCapture screenCapture,
    required super.child,
  }) : super(notifier: screenCapture);
}
