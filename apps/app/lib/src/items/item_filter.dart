import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../widgets/item_icon.dart';

/// The lists of the filter column. An item in the trash leaves every list but
/// the trash. Submarine does not support the archive: an archived item, from
/// Bitwarden for instance, shows like any other.
enum ItemFilter {
  all('items'),
  favorites('favorites'),
  logins('logins', CipherType.login),
  cards('cards', CipherType.card),
  identities('identities', CipherType.identity),
  secureNotes('notes', CipherType.secureNote),
  sshKeys('ssh-keys', CipherType.sshKey),
  bankAccounts('bank-accounts', CipherType.bankAccount),
  driversLicenses('drivers-licenses', CipherType.driversLicense),
  passports('passports', CipherType.passport),
  trash('trash');

  const ItemFilter(this.slug, [this.type]);

  /// Names the filter in the URL.
  final String slug;

  /// The type a type filter keeps, null for the other filters.
  final CipherType? type;

  static ItemFilter? fromSlug(String slug) =>
      values.where((filter) => filter.slug == slug).firstOrNull;

  /// The type filters worth offering for [ciphers]: those of the types they
  /// hold, and [selected] even if emptied.
  static List<ItemFilter> typesFor(List<Cipher> ciphers, ItemFilter selected) =>
      [
        for (final filter in values)
          if (filter.type != null &&
              (filter == selected || ciphers.any(filter.matches)))
            filter,
      ];

  bool matches(Cipher cipher) => switch (this) {
    trash => cipher.isDeleted,
    _ when cipher.isDeleted => false,
    all => true,
    favorites => cipher.favorite,
    _ => cipher.type == type,
  };

  String label(AppLocalizations l10n) => switch (this) {
    all => l10n.filterAllItems,
    favorites => l10n.filterFavorites,
    logins => l10n.filterLogins,
    cards => l10n.filterCards,
    identities => l10n.filterIdentities,
    secureNotes => l10n.filterSecureNotes,
    sshKeys => l10n.filterSshKeys,
    bankAccounts => l10n.filterBankAccounts,
    driversLicenses => l10n.filterDriversLicenses,
    passports => l10n.filterPassports,
    trash => l10n.filterTrash,
  };

  IconData get icon => switch (this) {
    all => Icons.grid_view_rounded,
    favorites => Icons.star_outline_rounded,
    trash => Icons.delete_outline_rounded,
    _ => itemTypeIcon(type!),
  };
}
