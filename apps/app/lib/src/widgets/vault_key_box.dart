import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart' show Nip19;

import '../context.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import 'copy_button.dart';

/// The key of [vault], as an nsec, to copy.
class VaultKeyBox extends StatelessWidget {
  const VaultKeyBox({super.key, required this.vault});

  final VaultController vault;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nsec = Nip19.encodePrivateKey(vault.record.privateKey);
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
            child: SelectableText(
              nsec,
              style: monoStyle.copyWith(fontSize: 14, height: 1.4),
            ),
          ),
          CopyButton(value: nsec),
        ],
      ),
    );
  }
}
