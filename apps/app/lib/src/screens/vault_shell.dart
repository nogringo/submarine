import 'package:flutter/material.dart';

import '../context.dart';
import '../items/item_filter.dart';
import 'filter_column.dart';
import 'item_list.dart';
import 'vault_navigation.dart';

/// Wide layout: the vaults, the filters on a desktop, the items and the routed
/// [child] side by side, the list keeping its scroll as items get selected.
/// Narrow layout: the routed screen alone.
class VaultShell extends StatelessWidget {
  const VaultShell({
    super.key,
    required this.vaultId,
    required this.filter,
    required this.itemId,
    required this.child,
  });

  final String vaultId;
  final ItemFilter filter;
  final String? itemId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.isWide) return child;
    final showsFilters = context.showsFilters;
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VaultRail(selectedVaultId: vaultId),
            const VerticalDivider(width: 1),
            if (showsFilters) ...[
              SizedBox(
                width: 240,
                child: FilterColumn(vaultId: vaultId, filter: filter),
              ),
              const VerticalDivider(width: 1),
            ],
            SizedBox(
              width: 340,
              child: ItemListPane(
                vaultId: vaultId,
                filter: filter,
                selectedItemId: itemId,
                titledByFilter: showsFilters,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
