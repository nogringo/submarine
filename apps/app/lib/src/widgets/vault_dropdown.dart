import 'package:flutter/material.dart';

import '../context.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import 'vault_avatar.dart';

/// Picks one of the vaults of this device.
class VaultDropdown extends StatelessWidget {
  const VaultDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final VaultController value;
  final ValueChanged<VaultController> onChanged;

  @override
  Widget build(BuildContext context) =>
      DropdownButtonFormField<VaultController>(
        initialValue: value,
        borderRadius: BorderRadius.circular(12),
        decoration: InputDecoration(labelText: context.l10n.vault),
        items: [
          for (final vault in Vaults.of(context).all)
            DropdownMenuItem(
              value: vault,
              child: Row(
                children: [
                  VaultAvatar(vault: vault, size: 24),
                  const SizedBox(width: 12),
                  Text(vault.name),
                ],
              ),
            ),
        ],
        onChanged: (vault) {
          if (vault != null) onChanged(vault);
        },
      );
}
