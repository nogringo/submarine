import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../context.dart';

/// Copies [value], and shows a check for a moment rather than a toast.
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.value, this.sensitive = false});

  final String value;

  /// Whether Android hides [value] in the preview it shows of a copy.
  final bool sensitive;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  Timer? _reset;

  Future<void> _copy() async {
    await copyText(widget.value, sensitive: widget.sensitive);
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

const _clipboard = MethodChannel('submarine/clipboard');

/// [Clipboard.setData] cannot mark a copy as sensitive, which Android needs to
/// keep it out of its preview.
Future<void> copyText(String text, {required bool sensitive}) async {
  if (sensitive && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await _clipboard.invokeMethod<void>('copySensitive', text);
  } else {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
