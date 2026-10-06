import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/item_filter.dart';
import '../items/item_menu.dart';
import '../lock/app_lock.dart';
import '../router.dart';
import '../vaults/vaults.dart';
import '../widgets/copy_button.dart';
import '../widgets/item_icon.dart';
import '../widgets/no_browser_menu.dart';
import '../widgets/search_field.dart';
import '../widgets/sync_status.dart';
import '../widgets/vault_avatar.dart';
import 'add_vault.dart';
import 'app_navigation.dart';
import 'filter_chips.dart';
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
        _FilterHeader(vaultId: vaultId, filter: filter)
      else
        _Header(vaultId: vaultId, filter: filter),
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
    floatingActionButton: FloatingActionButton(
      tooltip: context.l10n.newItem,
      backgroundColor: context.palette.accent,
      foregroundColor: context.palette.onAccent,
      onPressed: () => _newItem(context, vaultId, filter, _pickTypeInSheet),
      child: const Icon(Icons.add_rounded),
    ),
    bottomNavigationBar: const AppNavigationBar(current: AppDestination.vaults),
    body: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(vaultId: vaultId, filter: filter, withDrawer: true),
          Expanded(
            child: _Items(vaultId: vaultId, filter: filter),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.vaultId,
    required this.filter,
    this.withDrawer = false,
  });

  final String vaultId;
  final ItemFilter filter;

  /// Whether the vault's avatar opens the drawer of the vaults, and a floating
  /// button adds an item.
  final bool withDrawer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lock = AppLock.of(context);
    final selection = Vaults.of(context).select(vaultId);
    final all = vaultId == allVaultsId;
    final vault = selection.firstOrNull;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                all || vault == null ? l10n.allVaults : vault.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
            if (!withDrawer && !all && vault != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.settings_outlined,
                size: 18,
                color: context.palette.muted,
              ),
            ],
          ],
        ),
        SyncStatusText(vaults: selection),
      ],
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        withDrawer ? 12 : 20,
        16,
        withDrawer ? 8 : 16,
        12,
      ),
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
            // The drawer has the settings on a phone, the filter column on a
            // desktop.
            child: withDrawer || all || vault == null
                ? title
                : Tooltip(
                    message: l10n.vaultSettings,
                    child: InkWell(
                      onTap: () =>
                          context.push(vaultSettingsPath(vault.pubkey)),
                      borderRadius: BorderRadius.circular(10),
                      child: title,
                    ),
                  ),
          ),
          SyncButton(vaults: selection),
          // The rail has the lock in the wide layout.
          if (withDrawer && lock.enabled)
            IconButton(
              tooltip: l10n.lock,
              onPressed: lock.lock,
              icon: const Icon(Icons.lock_outline_rounded),
            ),
          if (!withDrawer) ...[
            const SizedBox(width: 4),
            _NewItemButton(vaultId: vaultId, filter: filter),
          ],
        ],
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({required this.vaultId, required this.filter});

  final String vaultId;
  final ItemFilter filter;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
    child: Row(
      children: [
        Expanded(
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
        ),
        _NewItemButton(vaultId: vaultId, filter: filter),
      ],
    ),
  );
}

class _NewItemButton extends StatelessWidget {
  const _NewItemButton({required this.vaultId, required this.filter});

  final String vaultId;
  final ItemFilter filter;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: () => _newItem(context, vaultId, filter, _pickTypeInMenu),
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    icon: const Icon(Icons.add_rounded, size: 20),
    label: Text(context.l10n.newItem),
  );
}

/// Opens the form of a new item of the type [filter] lists, or else of the
/// type [pick] asks for.
Future<void> _newItem(
  BuildContext context,
  String vaultId,
  ItemFilter filter,
  Future<CipherType?> Function(BuildContext context) pick,
) async {
  final type = formTypes.containsKey(filter.type)
      ? filter.type
      : await pick(context);
  if (type != null && context.mounted) {
    context.go(newItemPath(vaultId, filter, type));
  }
}

/// Asks for the type of a new item in a menu under [button], aligned on its
/// right edge.
Future<CipherType?> _pickTypeInMenu(BuildContext button) {
  const width = 200.0;
  final overlay =
      Navigator.of(button).overlay!.context.findRenderObject()! as RenderBox;
  final box = button.findRenderObject()! as RenderBox;
  final bounds = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  return showMenu<CipherType>(
    context: button,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(bounds.right - width, bounds.bottom + 4, width, 0),
      Offset.zero & overlay.size,
    ),
    constraints: const BoxConstraints(minWidth: width, maxWidth: 280),
    items: [
      for (final type in formTypes.keys)
        PopupMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(itemTypeIcon(type), size: 20, color: button.palette.muted),
              const SizedBox(width: 12),
              Flexible(child: Text(itemTypeLabel(button.l10n, type))),
            ],
          ),
        ),
    ],
  );
}

/// Asks for the type of a new item in a sheet, on a phone.
Future<CipherType?> _pickTypeInSheet(BuildContext context) =>
    showModalBottomSheet<CipherType>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                context.l10n.newItem,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final type in formTypes.keys)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: Icon(itemTypeIcon(type), color: context.palette.muted),
                title: Text(itemTypeLabel(context.l10n, type)),
                onTap: () => Navigator.pop(context, type),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

class _Items extends StatefulWidget {
  const _Items({
    required this.vaultId,
    required this.filter,
    this.selectedItemId,
  });

  final String vaultId;
  final ItemFilter filter;
  final String? selectedItemId;

  @override
  State<_Items> createState() => _ItemsState();
}

/// Keeps the search as items get selected, and from a vault or a filter to
/// another.
class _ItemsState extends State<_Items> {
  var _query = '';

  // Not the row's context, which goes away once its item leaves the list.
  Future<void> _run(ItemAction action, VaultItem entry) => runItemAction(
    context,
    action,
    vaultId: widget.vaultId,
    filter: widget.filter,
    entry: entry,
    close: entry.item.id == widget.selectedItemId,
  );

  @override
  Widget build(BuildContext context) {
    final vaults = Vaults.of(context);
    final items = vaults.itemsOf(widget.vaultId, widget.filter);
    final found = searchItems([
      for (final entry in items) entry.item,
    ], _query).toSet();
    final shown = [
      for (final entry in items)
        if (found.contains(entry.item)) entry,
    ];
    // A badge tells the vaults apart, which a single vault does not need.
    final showVault = widget.vaultId == allVaultsId && vaults.all.length > 1;
    final showCopy = !context.showsFilters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SearchField(
            hint: context.l10n.searchItems(items.length),
            showsShortcut: context.isWide,
            onChanged: (query) => setState(() => _query = query),
          ),
        ),
        if (!context.showsFilters) ...[
          FilterChips(
            vaultId: widget.vaultId,
            filter: widget.filter,
            selectedItemId: widget.selectedItemId,
          ),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: shown.isEmpty
              ? _Empty(
                  vaultId: widget.vaultId,
                  filter: widget.filter,
                  searched: items.isNotEmpty,
                )
              : NoBrowserMenu(
                  child: ListView.builder(
                    // Clear of the floating button on a phone.
                    padding: EdgeInsets.fromLTRB(
                      8,
                      0,
                      8,
                      context.isWide ? 16 : 88,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: shown.length,
                    itemBuilder: (context, index) {
                      final entry = shown[index];
                      return _ItemRow(
                        entry: entry,
                        showVault: showVault,
                        showCopy: showCopy,
                        selected: entry.item.id == widget.selectedItemId,
                        onTap: () => context.go(
                          vaultPath(
                            widget.vaultId,
                            filter: widget.filter,
                            itemId: entry.item.id,
                          ),
                        ),
                        onAction: (action) => _run(action, entry),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.entry,
    required this.showVault,
    required this.showCopy,
    required this.selected,
    required this.onTap,
    required this.onAction,
  });

  final VaultItem entry;
  final bool showVault;

  /// Whether the row copies the password of a login, or the number of a card.
  final bool showCopy;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<ItemAction> onAction;

  /// Opens the menu of the item where the pointer clicked, or over the row
  /// after a long press.
  Future<void> _openMenu(BuildContext context, [Offset? pointer]) async {
    final cipher = entry.item.cipher;
    final actions = ItemAction.available(cipher);
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final row = context.findRenderObject()! as RenderBox;
    final anchor = pointer != null
        ? pointer & Size.zero
        : row.localToGlobal(Offset.zero) & row.size;
    final action = await showMenu<ItemAction>(
      context: context,
      position: RelativeRect.fromRect(
        anchor.shift(-overlay.localToGlobal(Offset.zero)),
        Offset.zero & overlay.size,
      ),
      items: [
        for (final (index, action) in actions.indexed) ...[
          if (index > 0 && action.copies != actions[index - 1].copies)
            const PopupMenuDivider(),
          itemMenuItem(context, action, cipher),
        ],
      ],
    );
    if (action != null) onAction(action);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final cipher = entry.item.cipher;
    final subtitle = cipher.subtitle;
    final copy = showCopy ? ItemAction.rowCopy(cipher) : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? palette.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onSecondaryTapUp: (details) =>
              _openMenu(context, details.globalPosition),
          onLongPress: () => _openMenu(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 8, showCopy ? 4 : 10, 8),
            child: ConstrainedBox(
              // As high as a copy button, in every row.
              constraints: BoxConstraints(minHeight: showCopy ? 48 : 0),
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
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (copy != null)
                    CopyButton(
                      value: copy.copiedFrom(cipher)!,
                      sensitive: true,
                      tooltip: copy == ItemAction.copyNumber
                          ? l10n.copyNumber
                          : l10n.copyPassword,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.vaultId,
    required this.filter,
    required this.searched,
  });

  final String vaultId;
  final ItemFilter filter;

  /// Whether there are items, but none the search matches.
  final bool searched;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final selection = Vaults.of(context).select(vaultId);
    final notOpened = selection.any(
      (vault) => vault.locked && !vault.unlocking,
    );
    if (!searched && !notOpened && selection.any((vault) => !vault.loaded)) {
      return const SizedBox.shrink();
    }
    final neverSynced = selection.any((vault) => vault.lastSync == null);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          searched
              ? l10n.noSearchResults
              : notOpened
              ? l10n.signerDidNotOpenVault
              : neverSynced
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
