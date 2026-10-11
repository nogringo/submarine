import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/js_crypto.dart';
import 'package:submarine_extension_core/js_storage.dart';
import 'package:submarine_extension_core/vaults.dart';

void main() {
  final vaults = Vaults(const JsStorage(), const JsEventSignerFactory());
  final core = Core({
    'vaults': (_) => vaults.list(),
    'addVault': (args) => vaults.add(
      key: args['key'] as String,
      password: args['password'] as String?,
      name: args['name'] as String,
      color: args['color'] as int,
    ),
  });
  globalContext['submarineCore'] = createJSInteropWrapper(_JsCore(core));
}

@JSExport()
class _JsCore {
  _JsCore(this._core);

  final Core _core;

  JSPromise<JSString> call(String method, String args) =>
      _core.handle(method, args).then((reply) => reply.toJS).toJS;
}
