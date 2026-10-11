import 'dart:js_interop';

import 'vaults.dart';

/// The extension's `storage.local`, which the background sets as
/// `extensionStorage`.
@JS('extensionStorage')
external _ExtensionStorage get _js;

extension type _ExtensionStorage._(JSObject _) implements JSObject {
  external JSPromise<JSString?> get(String key);
  external JSPromise<JSAny?> set(String key, String value);
}

class JsStorage implements KeyValueStore {
  const JsStorage();

  @override
  Future<String?> read(String key) async => (await _js.get(key).toDart)?.toDart;

  @override
  Future<void> write(String key, String value) => _js.set(key, value).toDart;
}
