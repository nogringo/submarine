import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'secure_storage.dart';

/// How long a copied password stays in the clipboard, as Bitwarden offers it.
enum ClipboardTimeout {
  never(null),
  tenSeconds(Duration(seconds: 10)),
  twentySeconds(Duration(seconds: 20)),
  thirtySeconds(Duration(seconds: 30)),
  oneMinute(Duration(minutes: 1)),
  twoMinutes(Duration(minutes: 2)),
  fiveMinutes(Duration(minutes: 5));

  const ClipboardTimeout(this.delay);

  final Duration? delay;
}

/// Copies for the app, and clears copied passwords after the [timeout] picked
/// on this device.
class AppClipboard extends ChangeNotifier {
  AppClipboard._(this._timeout);

  static const _key = 'clipboard';
  static const _channel = MethodChannel('submarine/clipboard');

  static Future<AppClipboard> load() async {
    final name = await secureStorage.read(key: _key);
    return AppClipboard._(
      ClipboardTimeout.values.asNameMap()[name] ??
          ClipboardTimeout.thirtySeconds,
    );
  }

  static AppClipboard of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppClipboardScope>()!
      .notifier!;

  /// Where the platform copies, and clears the copy itself.
  static bool get _native =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS => true,
        _ => false,
      };

  ClipboardTimeout get timeout => _timeout;
  ClipboardTimeout _timeout;

  Timer? _pendingClear;

  Future<void> setTimeout(ClipboardTimeout timeout) async {
    _timeout = timeout;
    notifyListeners();
    await secureStorage.write(key: _key, value: timeout.name);
  }

  /// Copies [text]. A [sensitive] copy stays out of the preview Android shows
  /// of a copy, and leaves the clipboard after [timeout] unless the app copies
  /// something else first.
  Future<void> copy(String text, {required bool sensitive}) async {
    final clearAfter = sensitive ? timeout.delay : null;
    if (_native) {
      return _channel.invokeMethod<void>('copy', {
        'text': text,
        'sensitive': sensitive,
        'clearAfter': clearAfter?.inMilliseconds,
      });
    }
    _pendingClear?.cancel();
    _pendingClear = clearAfter == null
        ? null
        : Timer(clearAfter, () => _clear(text));
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _clear(String copied) async {
    // Reading the clipboard asks the user for it on the web.
    if (!kIsWeb) {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != copied) return;
    }
    try {
      await Clipboard.setData(const ClipboardData(text: ''));
    } on PlatformException {
      // The web writes only to a page that has the focus.
    }
  }

  @override
  void dispose() {
    _pendingClear?.cancel();
    super.dispose();
  }
}

class AppClipboardScope extends InheritedNotifier<AppClipboard> {
  const AppClipboardScope({
    super.key,
    required AppClipboard clipboard,
    required super.child,
  }) : super(notifier: clipboard);
}
