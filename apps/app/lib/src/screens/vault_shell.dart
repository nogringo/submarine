import 'package:flutter/material.dart';

import '../context.dart';
import 'item_list.dart';
import 'vault_navigation.dart';

/// Wide layout: the vaults, the items and the routed [child] side by side,
/// the list keeping its scroll as items get selected. Narrow layout: the
/// routed screen alone.
class VaultShell extends StatelessWidget {
  const VaultShell({
    super.key,
    required this.vaultId,
    required this.itemId,
    required this.child,
  });

  final String vaultId;
  final String? itemId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.isWide) return child;
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VaultRail(selectedVaultId: vaultId),
            const VerticalDivider(width: 1),
            SizedBox(
              width: 340,
              child: ItemListPane(vaultId: vaultId, selectedItemId: itemId),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
