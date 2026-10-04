import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../context.dart';
import '../theme/theme.dart';

/// A search box that Ctrl+F, or ⌘F on Apple devices, focuses from anywhere on
/// its screen, and Escape clears.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.showsShortcut = false,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  /// Whether the empty box shows its keyboard shortcut.
  final bool showsShortcut;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  static bool get _apple => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => true,
    _ => false,
  };

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    final shortcut = SingleActivator(
      LogicalKeyboardKey.keyF,
      control: !_apple,
      meta: _apple,
    );
    // Not under a dialog, nor under a screen pushed over the list.
    if (!shortcut.accepts(event, HardwareKeyboard.instance) ||
        !(ModalRoute.isCurrentOf(context) ?? true)) {
      return false;
    }
    _focus.requestFocus();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    return true;
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Actions(
      actions: {
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (_) {
            _clear();
            _focus.unfocus();
            return null;
          },
        ),
      },
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => TextField(
          controller: _controller,
          focusNode: _focus,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hint,
            fillColor: palette.surface,
            prefixIcon: Icon(Icons.search_rounded, color: palette.muted),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    tooltip: context.l10n.clearSearch,
                    onPressed: _clear,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  )
                : widget.showsShortcut
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Center(
                      widthFactor: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: palette.line),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _apple ? '⌘F' : 'Ctrl+F',
                          style: monoStyle.copyWith(
                            fontSize: 12,
                            color: palette.muted,
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
