import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../clipboard.dart';
import '../context.dart';
import '../router.dart';
import '../vaults/vaults.dart';
import 'item_filter.dart';

/// What the item's own actions, and the menu of its row, do to an item.
enum ItemAction {
  copyUsername,
  copyPassword,
  copyTotp,
  copyNumber,
  favorite,
  edit,
  trash,
  restore,
  delete;

  static const _copies = [copyUsername, copyPassword, copyTotp, copyNumber];

  /// The copies of what [cipher] holds, then the changes. In the trash:
  /// restore the item, or delete it for good. Only a login has a form to edit
  /// it.
  static List<ItemAction> available(Cipher cipher) => [
    for (final copy in _copies)
      if (copy.copiedFrom(cipher) != null) copy,
    ...cipher.isDeleted
        ? const [restore, delete]
        : [favorite, if (cipher.type == CipherType.login) edit, trash],
  ];

  /// What the copy button of [cipher]'s row copies: the secret a login or a
  /// card is opened for.
  static ItemAction? rowCopy(Cipher cipher) => [
    copyPassword,
    copyNumber,
  ].where((copy) => copy.copiedFrom(cipher) != null).firstOrNull;

  bool get copies => _copies.contains(this);

  /// What this action copies from [cipher], the current code for the TOTP
  /// key. Null when there is nothing to copy.
  String? copiedFrom(Cipher cipher) {
    final login = cipher.login;
    final value = switch (this) {
      copyUsername => login?.username,
      copyPassword => login?.password,
      copyTotp => _totpCode(login?.totp),
      copyNumber => cipher.card?.number,
      _ => null,
    };
    return value == null || value.trim().isEmpty ? null : value;
  }
}

String? _totpCode(String? key) {
  if (key == null || key.trim().isEmpty) return null;
  try {
    return generateTotp(key).code;
  } on FormatException {
    return null;
  }
}

PopupMenuItem<ItemAction> itemMenuItem(
  BuildContext context,
  ItemAction action,
  Cipher cipher,
) {
  final l10n = context.l10n;
  final (icon, text, color) = switch (action) {
    ItemAction.copyUsername => (
      Icons.person_outline_rounded,
      l10n.copyUsername,
      null,
    ),
    ItemAction.copyPassword => (
      Icons.password_rounded,
      l10n.copyPassword,
      null,
    ),
    ItemAction.copyTotp => (Icons.timer_outlined, l10n.copyTotp, null),
    ItemAction.copyNumber => (Icons.credit_card_rounded, l10n.copyNumber, null),
    ItemAction.favorite when cipher.favorite => (
      Icons.star_rounded,
      l10n.removeFromFavorites,
      null,
    ),
    ItemAction.favorite => (
      Icons.star_outline_rounded,
      l10n.addToFavorites,
      null,
    ),
    ItemAction.edit => (Icons.edit_rounded, l10n.edit, null),
    ItemAction.trash => (Icons.delete_outline_rounded, l10n.moveToTrash, null),
    ItemAction.restore => (
      Icons.restore_from_trash_rounded,
      l10n.restore,
      null,
    ),
    ItemAction.delete => (
      Icons.delete_forever_outlined,
      l10n.deletePermanently,
      context.palette.danger,
    ),
  };
  return PopupMenuItem(
    value: action,
    child: Row(
      children: [
        Icon(icon, size: 20, color: color ?? context.palette.muted),
        const SizedBox(width: 12),
        Flexible(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    ),
  );
}

/// Runs [action] on [entry], listed from [vaultId] and [filter]. The item
/// leaves that list once in the trash or out of it, which closes the item if
/// [close].
Future<void> runItemAction(
  BuildContext context,
  ItemAction action, {
  required String vaultId,
  required ItemFilter filter,
  required VaultItem entry,
  required bool close,
}) async {
  final VaultItem(:vault, :item) = entry;
  if (!action.copies && vault.isSaving(item)) return;
  switch (action) {
    case ItemAction.copyUsername ||
        ItemAction.copyPassword ||
        ItemAction.copyTotp ||
        ItemAction.copyNumber:
      if (action.copiedFrom(item.cipher) case final value?) {
        await AppClipboard.of(context)
            .copy(value, sensitive: action != ItemAction.copyUsername);
      }
      return;
    case ItemAction.favorite:
      await vault.updateItem(
        item,
        Cipher.fromJson(item.current.data)..favorite = !item.cipher.favorite,
      );
      return;
    case ItemAction.edit:
      context.go(editItemPath(vaultId, filter, item.id));
      return;
    case ItemAction.trash:
      await vault.trashItem(item);
    case ItemAction.restore:
      await vault.restoreItem(item);
    case ItemAction.delete:
      if (!await _confirmDelete(context)) return;
      await vault.deleteItem(item);
  }
  if (close && context.mounted) context.go(vaultPath(vaultId, filter: filter));
}

Future<bool> _confirmDelete(BuildContext context) async {
  final l10n = context.l10n;
  final colors = Theme.of(context).colorScheme;
  final delete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteItemTitle),
      content: Text(l10n.deleteItemBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return delete ?? false;
}
