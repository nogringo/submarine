import 'dart:js_interop';

/// What the core tells the open popups, through the background, which sets it
/// as `coreEvents`.
@JS('coreEvents')
external _CoreEvents get _js;

extension type _CoreEvents._(JSObject _) implements JSObject {
  external void emit(String type);
}

/// Tells the popups that what they show of the vaults changed: their sync or
/// their items.
void emitVaultsChanged() => _js.emit('vaultsChanged');
