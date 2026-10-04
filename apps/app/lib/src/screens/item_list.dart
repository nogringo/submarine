import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../context.dart';
import '../items/item_filter.dart';
import '../router.dart';
import '../vaults/vaults.dart';
import '../widgets/item_icon.dart';
import '../widgets/sync_status.dart';
import '../widgets/vault_avatar.dart';
import 'add_vault.dart';
import 'vault_navigation.dart';

/// Wide layout: the items, between the rail or the filters and the selected
/// item.
class ItemListPane extends StatelessWidget {
  const ItemListPane({
    super.key,
    required this.vaultId,
    required this.filter,
    required this.selectedItemId,
    required this.titledByFilter,
  });

  final String vaultId;
  final ItemFilter filter;
  final String? selectedItemId;

  /// Whether the filter column already names the vault and shows its sync.
  final bool titledByFilter;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (titledByFilter)
        _FilterHeader(filter: filter)
      else
        _Header(vaultId: vaultId),
      Expanded(
        child: _Items(
          vaultId: vaultId,
          filter: filter,
          selectedItemId: selectedItemId,
        ),
      ),
    ],
  );
}

/// Narrow layout: the items on the whole screen, the vaults in a drawer.
class ItemListScreen extends StatelessWidget {
  const ItemListScreen({
    super.key,
    required this.vaultId,
    required this.filter,
  });

  final String vaultId;
  final ItemFilter filter;

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: VaultDrawer(
      selectedVaultId: vaultId,
      onAddVault: () => addVault(context),
    ),
    body: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(vaultId: vaultId, withDrawer: true),
          Expanded(
            child: _Items(vaultId: vaultId, filter: filter),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.vaultId, this.withDrawer = false});

  final String vaultId;

  /// Whether the vault's avatar opens the drawer of the vaults.
  final bool withDrawer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selection = Vaults.of(context).select(vaultId);
    final all = vaultId == allVaultsId;
    final vault = selection.firstOrNull;
    return Padding(
      padding: EdgeInsets.fromLTRB(withDrawer ? 12 : 20, 16, 8, 12),
      child: Row(
        children: [
          if (withDrawer) ...[
            Builder(
              builder: (context) => Tooltip(
                message: l10n.vaults,
                child: InkWell(
                  onTap: Scaffold.of(context).openDrawer,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: all || vault == null
                      ? const AllVaultsAvatar(size: 44)
                      : VaultAvatar(vault: vault, size: 44),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  all || vault == null ? l10n.allVaults : vault.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                SyncStatusText(vaults: selection),
              ],
            ),
          ),
          SyncButton(vaults: selection),
        ],
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({required this.filter});

  final ItemFilter filter;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
    child: Text(
      filter.label(context.l10n),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
    ),
  );
}

class _Items extends StatelessWidget {
  const _Items({
    required this.vaultId,
    required this.filter,
    this.selectedItemId,
  });

  final String vaultId;
  final ItemFilter filter;
  final String? selectedItemId;

  @override
  Widget build(BuildContext context) {
    final vaults = Vaults.of(context);
    final items = vaults.itemsOf(vaultId, filter);
    if (items.isEmpty) return _Empty(vaultId: vaultId, filter: filter);
    // A badge tells the vaults apart, which a single vault does not need.
    final showVault = vaultId == allVaultsId && vaults.all.length > 1;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        return _ItemRow(
          entry: entry,
          showVault: showVault,
          selected: entry.item.id == selectedItemId,
          onTap: () => context.go(
            vaultPath(vaultId, filter: filter, itemId: entry.item.id),
          ),
        );
      },
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.entry,
    required this.showVault,
    required this.selected,
    required this.onTap,
  });

  final VaultItem entry;
  final bool showVault;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cipher = entry.item.cipher;
    final subtitle = cipher.subtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? palette.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                ItemIcon(
                  cipher: cipher,
                  vault: showVault ? entry.vault : null,
                  highlighted: selected,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cipher.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: palette.muted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.vaultId, required this.filter});

  final String vaultId;
  final ItemFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final selection = Vaults.of(context).select(vaultId);
    if (selection.any((vault) => !vault.loaded)) return const SizedBox.shrink();
    final neverSynced = selection.any((vault) => vault.lastSync == null);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          neverSynced
              ? l10n.lookingForItems
              : filter == ItemFilter.all
              ? l10n.noItems
              : l10n.noItemsHere,
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.muted),
        ),
      ),
    );
  }
}
