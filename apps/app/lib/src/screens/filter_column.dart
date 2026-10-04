import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../context.dart';
import '../items/item_filter.dart';
import '../router.dart';
import '../theme/theme.dart';
import '../vaults/vaults.dart';
import '../widgets/sync_status.dart';

/// Desktop layout: the filters of the selected vault, with their counts, and
/// its sync at the bottom.
class FilterColumn extends StatelessWidget {
  const FilterColumn({super.key, required this.vaultId, required this.filter});

  final String vaultId;
  final ItemFilter filter;

  @override
  Widget build(BuildContext context) {
    final vaults = Vaults.of(context);
    final selection = vaults.select(vaultId);
    final everything = [
      for (final vault in selection)
        for (final item in vault.items) item.cipher,
    ];
    int count(ItemFilter filter) => everything.where(filter.matches).length;
    Widget tile(ItemFilter option) => _FilterTile(
      filter: option,
      count: count(option),
      selected: option == filter,
      onTap: () => context.go(vaultPath(vaultId, filter: option)),
    );
    // Only the types the vault holds, and the one selected even if emptied.
    final types = [
      for (final option in ItemFilter.values)
        if (option.type != null && (count(option) > 0 || option == filter))
          option,
    ];
    final vault = selection.firstOrNull;
    return ColoredBox(
      color: context.palette.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 16, 14),
            child: Text(
              vaultId == allVaultsId || vault == null
                  ? context.l10n.allVaults
                  : vault.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                tile(ItemFilter.all),
                tile(ItemFilter.favorites),
                if (types.isNotEmpty) ...[
                  const _FilterDivider(),
                  for (final type in types) tile(type),
                ],
                const _FilterDivider(),
                tile(ItemFilter.trash),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SyncCard(vaults: selection),
          ),
        ],
      ),
    );
  }
}

class _FilterDivider extends StatelessWidget {
  const _FilterDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(),
  );
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.filter,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final ItemFilter filter;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? palette.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(filter.icon, size: 22, color: palette.text),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    filter.label(context.l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: monoStyle.copyWith(fontSize: 13, color: palette.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
