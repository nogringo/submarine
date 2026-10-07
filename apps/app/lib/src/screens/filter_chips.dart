import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../context.dart';
import '../items/item_filter.dart';
import '../router.dart';
import '../vaults/vaults.dart';
import '../widgets/select_chip.dart';

/// Below a desktop width: the filters of the selected vault, as chips above
/// its items.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.vaultId,
    required this.filter,
    required this.selectedItemId,
  });

  final String vaultId;
  final ItemFilter filter;
  final String? selectedItemId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vaults = Vaults.of(context);
    final everything = [
      for (final vault in vaults.select(vaultId))
        for (final item in vault.items) item.cipher,
    ];
    final options = [
      ItemFilter.all,
      ItemFilter.favorites,
      ...ItemFilter.typesFor(everything, filter),
      ItemFilter.trash,
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          return SelectChip(
            label: option == ItemFilter.all
                ? l10n.filterAllShort
                : option.label(l10n),
            selected: option == filter,
            onTap: () => context.go(
              vaultPathKeeping(
                vaults,
                vaultId,
                filter: option,
                itemId: selectedItemId,
              ),
            ),
          );
        },
      ),
    );
  }
}
