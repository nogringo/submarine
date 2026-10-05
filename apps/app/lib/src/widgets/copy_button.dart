import 'dart:async';

import 'package:flutter/material.dart';

import '../clipboard.dart';
import '../context.dart';

/// Copies [value], and shows a check for a moment rather than a toast.
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.value, this.sensitive = false});

  final String value;

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
    final copied = _reset != null;
    return IconButton(
      tooltip: copied ? context.l10n.copied : context.l10n.copy,
      onPressed: _copy,
      icon: copied
          ? Icon(Icons.check_rounded, color: context.palette.signal)
          : const Icon(Icons.content_copy_rounded, size: 20),
    );
  }
}
