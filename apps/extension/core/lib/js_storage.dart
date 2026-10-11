import 'dart:js_interop';

import 'vaults.dart';

/// The extension's `storage.local`, which the background sets as
/// `extensionStorage`.
@JS('extensionStorage')
external _ExtensionStorage get _local;

/// Its `storage.session`, set as `extensionSessionStorage`.
@JS('extensionSessionStorage')
external _ExtensionStorage get _session;

extension type _ExtensionStorage._(JSObject _) implements JSObject {
  external JSPromise<JSString?> get(String key);
  external JSPromise<JSAny?> set(String key, String value);
  external JSPromise<JSAny?> remove(String key);
}

class JsStorage implements KeyValueStore {
  const JsStorage.local() : _inSession = false;

  const JsStorage.session() : _inSession = true;

  final bool _inSession;

  // Read at each call: Firefox runs the core before the background sets them.
  _ExtensionStorage get _js => _inSession ? _session : _local;

  @override
  Future<String?> read(String key) async => (await _js.get(key).toDart)?.toDart;

  @override
  Future<void> write(String key, String value) => _js.set(key, value).toDart;

  @override
  Future<void> remove(String key) => _js.remove(key).toDart;
}
