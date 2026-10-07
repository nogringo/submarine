import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// [key] pressed with Ctrl, or with ⌘ on Apple devices.
class CommandShortcut {
  const CommandShortcut(this.key);

  final LogicalKeyboardKey key;

  static bool get _apple => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => true,
    _ => false,
  };

  bool accepts(KeyEvent event) => SingleActivator(
    key,
    control: !_apple,
    meta: _apple,
  ).accepts(event, HardwareKeyboard.instance);

  /// As Ctrl+F, or ⌘F on Apple devices.
  String get label => '${_apple ? '⌘' : 'Ctrl+'}${key.keyLabel}';
}
