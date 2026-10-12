import 'dart:js_interop';

/// Keeps the background awake or lets it sleep again, as the background sets
/// it as `extensionKeepAwake`: a timer of the core does not keep it awake.
@JS('extensionKeepAwake')
external void keepAwake(bool awake);
