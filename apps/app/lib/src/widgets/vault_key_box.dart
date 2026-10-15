import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart' show Nip19;

import '../context.dart';
import '../theme/theme.dart';
import 'copy_button.dart';
import 'selectable_area.dart';

/// A vault key, as an nsec, hidden until asked and copyable either way.
class VaultKeyBox extends StatefulWidget {
  const VaultKeyBox({super.key, required this.privateKey});

  /// In hex.
  final String privateKey;

  @override
  State<VaultKeyBox> createState() => _VaultKeyBoxState();
}

class _VaultKeyBoxState extends State<VaultKeyBox> {
  var _shown = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final nsec = Nip19.encodePrivateKey(widget.privateKey);
    final style = monoStyle.copyWith(fontSize: 14, height: 1.4);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _shown
                ? SelectableArea(child: Text(nsec, style: style))
                : Text(
                    '••••••••••••',
                    semanticsLabel: l10n.hiddenValue,
                    style: style,
                  ),
          ),
          IconButton(
            tooltip: _shown ? l10n.hide : l10n.show,
            onPressed: () => setState(() => _shown = !_shown),
            icon: Icon(
              _shown
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          CopyButton(value: nsec, sensitive: true),
        ],
      ),
    );
  }
}
