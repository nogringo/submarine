import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../vaults/vault_controller.dart';
import 'vault_avatar.dart';

IconData itemTypeIcon(CipherType type) => switch (type) {
  CipherType.login => Icons.language_rounded,
  CipherType.secureNote => Icons.sticky_note_2_outlined,
  CipherType.card => Icons.credit_card_rounded,
  CipherType.identity => Icons.badge_outlined,
  CipherType.sshKey => Icons.terminal_rounded,
  CipherType.bankAccount => Icons.account_balance_outlined,
  CipherType.driversLicense => Icons.directions_car_outlined,
  CipherType.passport => Icons.menu_book_rounded,
  _ => Icons.lock_outline_rounded,
};

String itemTypeLabel(AppLocalizations l10n, CipherType type) => switch (type) {
  CipherType.login => l10n.typeLogin,
  CipherType.secureNote => l10n.typeSecureNote,
  CipherType.card => l10n.typeCard,
  CipherType.identity => l10n.typeIdentity,
  CipherType.sshKey => l10n.typeSshKey,
  CipherType.bankAccount => l10n.typeBankAccount,
  CipherType.driversLicense => l10n.typeDriversLicense,
  CipherType.passport => l10n.typePassport,
  _ => l10n.typeUnknown,
};

/// A login's initial, the type's icon for the rest. [vault] adds its badge.
class ItemIcon extends StatelessWidget {
  const ItemIcon({
    super.key,
    required this.cipher,
    this.vault,
    this.size = 40,
    this.highlighted = false,
  });

  final Cipher cipher;
  final VaultController? vault;
  final double size;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = highlighted ? palette.onAccent : palette.text;
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? palette.accent : palette.raised,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: cipher.type == CipherType.login && cipher.name.trim().isNotEmpty
          ? Text(
              initialOf(cipher.name),
              style: TextStyle(
                color: foreground,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            )
          : Icon(
              itemTypeIcon(cipher.type),
              color: foreground,
              size: size * 0.5,
            ),
    );
    final vault = this.vault;
    if (vault == null) return tile;
    // Overflows the tile: items line up whether they show a badge or not.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        Positioned(right: -4, bottom: -4, child: VaultBadge(vault: vault)),
      ],
    );
  }
}
