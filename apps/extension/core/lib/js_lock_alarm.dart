import 'dart:js_interop';

import 'auto_lock.dart';

/// The browser's alarms, which the background sets as `extensionLockAlarm`.
@JS('extensionLockAlarm')
external _ExtensionLockAlarm get _js;

extension type _ExtensionLockAlarm._(JSObject _) implements JSObject {
  external void schedule(double when);
  external void cancel();
}

class JsLockAlarm implements LockAlarm {
  const JsLockAlarm();

  @override
  void schedule(DateTime when) =>
      _js.schedule(when.millisecondsSinceEpoch.toDouble());

  @override
  void cancel() => _js.cancel();
}
