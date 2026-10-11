import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:submarine_extension_core/core.dart';

void main() {
  globalContext['submarineCore'] = createJSInteropWrapper(_JsCore(Core({})));
}

@JSExport()
class _JsCore {
  _JsCore(this._core);

  final Core _core;

  JSPromise<JSString> call(String method, String args) =>
      _core.handle(method, args).then((reply) => reply.toJS).toJS;
}
