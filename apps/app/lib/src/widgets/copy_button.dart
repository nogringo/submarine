import 'dart:async';

import 'package:flutter/material.dart';

import '../clipboard.dart';
import '../context.dart';
import 'spoken_status.dart';

/// Copies [value], then shows a check for a moment and tells screen readers,
/// rather than a toast.
class CopyButton extends StatefulWidget {
  const CopyButton({
    super.key,
    required this.value,
    this.sensitive = false,
    this.tooltip,
  });

  final String value;

  /// Says what the button copies, where the field it sits in does not.
  final String? tooltip;

  /// Whether [value] is a secret, which Android hides in the preview it shows
  /// of a copy, and the clipboard drops after a while.
  final bool sensitive;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  Timer? _reset;

  Future<void> _copy() async {
    await AppClipboard.of(context)
        .copy(widget.value, sensitive: widget.sensitive);
    _reset?.cancel();
    if (!mounted) return;
    setState(() {
      _reset = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _reset = null);
      });
    });
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final copied = _reset != null;
    return SpokenStatus(
      message: copied ? l10n.copied : null,
      child: IconButton(
        tooltip: copied ? l10n.copied : widget.tooltip ?? l10n.copy,
        onPressed: _copy,
        icon: copied
            ? Icon(Icons.check_rounded, color: context.palette.signal)
            : const Icon(Icons.content_copy_rounded, size: 20),
      ),
    );
  }
}
