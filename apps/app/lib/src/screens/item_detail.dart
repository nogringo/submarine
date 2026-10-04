import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../items/item_fields.dart';
import '../vaults/vaults.dart';
import '../widgets/item_icon.dart';
import '../widgets/vault_avatar.dart';

/// Wide layout: the selected item, next to the list.
class ItemDetailPane extends StatelessWidget {
  const ItemDetailPane({
    super.key,
    required this.vaultId,
    required this.itemId,
  });

  final String vaultId;
  final String itemId;

  @override
  Widget build(BuildContext context) =>
      _ItemOrMissing(vaultId: vaultId, itemId: itemId);
}

/// Narrow layout: the item on a screen of its own.
class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key, required this.vaultId, required this.itemId});

  final String vaultId;
  final String itemId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: _ItemOrMissing(vaultId: vaultId, itemId: itemId),
  );
}

/// Wide layout, when no item is selected.
class NoItemSelected extends StatelessWidget {
  const NoItemSelected({super.key});

  @override
  Widget build(BuildContext context) =>
      _Placeholder(icon: Icons.key_rounded, text: context.l10n.selectItem);
}

class _ItemOrMissing extends StatelessWidget {
  const _ItemOrMissing({required this.vaultId, required this.itemId});

  final String vaultId;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final vaults = Vaults.of(context);
    if (vaults.findItem(vaultId, itemId) case final entry?) {
      return ItemDetail(entry: entry);
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
  const ItemDetail({super.key, required this.entry});

  final VaultItem entry;

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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
