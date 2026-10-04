import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../items/item_fields.dart';
import '../items/item_filter.dart';
import '../router.dart';
import '../vaults/vaults.dart';
import '../widgets/item_icon.dart';
import '../widgets/vault_avatar.dart';

/// Wide layout: the selected item, next to the list.
class ItemDetailPane extends StatelessWidget {
  const ItemDetailPane({
    super.key,
    required this.vaultId,
    required this.filter,
    required this.itemId,
  });

  final String vaultId;
  final ItemFilter filter;
  final String itemId;

  @override
  Widget build(BuildContext context) => ItemOrMissing(
    vaultId: vaultId,
    itemId: itemId,
    builder: (entry) => ItemDetail(
      entry: entry,
      actions: ItemActions(vaultId: vaultId, filter: filter, entry: entry),
    ),
  );
}

/// Narrow layout: the item on a screen of its own.
class ItemScreen extends StatelessWidget {
  const ItemScreen({
    super.key,
    required this.vaultId,
    required this.filter,
    required this.itemId,
  });

  final String vaultId;
  final ItemFilter filter;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final entry = Vaults.of(context).findItem(vaultId, itemId);
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (entry != null)
            ItemActions(vaultId: vaultId, filter: filter, entry: entry),
          const SizedBox(width: 12),
        ],
      ),
      body: ItemOrMissing(
        vaultId: vaultId,
        itemId: itemId,
        builder: (entry) => ItemDetail(entry: entry),
      ),
    );
  }
}

/// Wide layout, when no item is selected.
class NoItemSelected extends StatelessWidget {
  const NoItemSelected({super.key});

  @override
  Widget build(BuildContext context) =>
      _Placeholder(icon: Icons.key_rounded, text: context.l10n.selectItem);
}

/// What [builder] makes of the item, or why there is none.
class ItemOrMissing extends StatelessWidget {
  const ItemOrMissing({
    super.key,
    required this.vaultId,
    required this.itemId,
    required this.builder,
  });

  final String vaultId;
  final String itemId;
  final Widget Function(VaultItem entry) builder;

  @override
  Widget build(BuildContext context) {
    final vaults = Vaults.of(context);
    if (vaults.findItem(vaultId, itemId) case final entry?) {
      return builder(entry);
    }
    // Not read from the cache yet, rather than gone.
    if (vaults.select(vaultId).any((vault) => !vault.loaded)) {
      return const SizedBox.shrink();
    }
    return _Placeholder(
      icon: Icons.search_off_rounded,
      text: context.l10n.itemNotFound,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: palette.line),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDetail extends StatelessWidget {
  const ItemDetail({super.key, required this.entry, this.actions});

  final VaultItem entry;

  /// Above the item, unless an app bar holds them.
  final ItemActions? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cipher = entry.item.cipher;
    final fields = typeFields(l10n, cipher);
    final notes = cipher.notes;
    final custom = customFields(l10n, cipher);
    final updated = cipher.revisionDate;
    final created = cipher.creationDate;
    const gap = SizedBox(height: 16);
    return SingleChildScrollView(
      // Clear of the system navigation bar, the app drawing edge to edge.
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        32 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (actions case final actions? when actions.isAvailable)
                Align(alignment: Alignment.centerRight, child: actions),
              _Header(entry: entry),
              const SizedBox(height: 20),
              if (fields.isNotEmpty) ...[_Fields(rows: fields), gap],
              if (notes != null && notes.trim().isNotEmpty) ...[
                _Fields(rows: [FieldRow(l10n.notes, notes)]),
                gap,
              ],
              if (custom.isNotEmpty) ...[
                _SectionTitle(l10n.customFields),
                _Fields(rows: custom),
                gap,
              ],
              if (cipher.passwordHistory.isNotEmpty) ...[
                _PasswordHistory(entries: cipher.passwordHistory),
                gap,
              ],
              if (updated != null && created != null)
                Text(
                  l10n.itemDates(updated.toLocal(), created.toLocal()),
                  style: TextStyle(fontSize: 13, color: context.palette.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marks the item as a favorite, and opens the form that edits a login. None
/// for an item in the trash.
class ItemActions extends StatefulWidget {
  const ItemActions({
    super.key,
    required this.vaultId,
    required this.filter,
    required this.entry,
  });

  final String vaultId;
  final ItemFilter filter;
  final VaultItem entry;

  bool get isAvailable => !entry.item.cipher.isDeleted;

  @override
  State<ItemActions> createState() => _ItemActionsState();
}

class _ItemActionsState extends State<ItemActions> {
  /// A second write before the first one ends would fork the item.
  var _saving = false;

  Future<void> _toggleFavorite() async {
    final VaultItem(:vault, :item) = widget.entry;
    setState(() => _saving = true);
    try {
      await vault.updateItem(
        item,
        Cipher.fromJson(item.current.data)..favorite = !item.cipher.favorite,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAvailable) return const SizedBox.shrink();
    final l10n = context.l10n;
    final cipher = widget.entry.item.cipher;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: cipher.favorite
              ? l10n.removeFromFavorites
              : l10n.addToFavorites,
          onPressed: _saving ? null : _toggleFavorite,
          icon: cipher.favorite
              ? Icon(Icons.star_rounded, color: context.palette.signal)
              : const Icon(Icons.star_outline_rounded),
        ),
        if (cipher.type == CipherType.login) ...[
          const SizedBox(width: 4),
          OutlinedButton.icon(
            onPressed: () => context.go(
              editItemPath(widget.vaultId, widget.filter, widget.entry.item.id),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(l10n.edit),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.entry});

  final VaultItem entry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cipher = entry.item.cipher;
    final meta = TextStyle(fontSize: 14, color: palette.muted);
    return Row(
      children: [
        ItemIcon(cipher: cipher, size: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                cipher.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        itemTypeIcon(cipher.type),
                        size: 16,
                        color: palette.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        itemTypeLabel(context.l10n, cipher.type),
                        style: meta,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VaultBadge(vault: entry.vault),
                      const SizedBox(width: 6),
                      Text(entry.vault.name, style: meta),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({required this.rows});

  final List<FieldRow> rows;

  @override
  Widget build(BuildContext context) =>
      FieldCard(children: [for (final row in rows) FieldTile(row: row)]);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.palette.muted,
      ),
    ),
  );
}

class _PasswordHistory extends StatefulWidget {
  const _PasswordHistory({required this.entries});

  final List<PasswordHistory> entries;

  @override
  State<_PasswordHistory> createState() => _PasswordHistoryState();
}

class _PasswordHistoryState extends State<_PasswordHistory> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final format = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();
    return FieldCard(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: palette.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.passwordHistory,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  '${widget.entries.length}',
                  style: TextStyle(color: palette.muted),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.expand_more_rounded, color: palette.muted),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final entry in widget.entries)
            FieldTile(
              row: FieldRow(
                switch (entry.lastUsedDate) {
                  final date? => format.format(date.toLocal()),
                  null => '',
                },
                entry.password,
                FieldKind.password,
              ),
            ),
      ],
    );
  }
}
