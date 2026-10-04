// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get allVaults => 'All vaults';

  @override
  String get vaults => 'Vaults';

  @override
  String get addVault => 'Add a vault';

  @override
  String get createVault => 'Create a vault';

  @override
  String get createVaultDescription => 'A new, empty vault with its own key.';

  @override
  String get openVault => 'Open a vault with its key';

  @override
  String get openVaultDescription => 'From another device, or shared with you.';

  @override
  String get openVaultTitle => 'Open a vault';

  @override
  String get vaultName => 'Name';

  @override
  String get vaultNameHelper =>
      'Only on this device. Someone you share the vault with names it their own way.';

  @override
  String get vaultNameRequired => 'Give the vault a name.';

  @override
  String get vaultColor => 'Color';

  @override
  String vaultColorOption(int number) {
    return 'Color $number';
  }

  @override
  String get vaultKey => 'Vault key';

  @override
  String get vaultKeyInvalid =>
      'This is not a vault key. It starts with nsec1.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'This vault is already open, as $name.';
  }

  @override
  String get vaultSaveFailed => 'The vault could not be saved on this device.';

  @override
  String get saveVaultKeyTitle => 'Save the vault key';

  @override
  String get saveVaultKeyBody =>
      'Anyone who has this key can open the vault. Keep it somewhere safe: you need it to open the vault on another device, or to share it.';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get open => 'Open';

  @override
  String get done => 'Done';

  @override
  String get welcomeTagline => 'A password manager built on Nostr.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing';

  @override
  String get syncNever => 'Never synced';

  @override
  String get syncFailed => 'Relays unreachable';

  @override
  String get syncedJustNow => 'Synced just now';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Synced $minutes min ago';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Synced $hours h ago';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Synced on $dateString';
  }

  @override
  String get noItems => 'No items in this vault yet.';

  @override
  String get lookingForItems => 'Looking for items on the relays';

  @override
  String get selectItem => 'Select an item to see it here.';

  @override
  String get itemNotFound => 'This item is no longer in the vault.';

  @override
  String get typeLogin => 'Login';

  @override
  String get typeSecureNote => 'Secure note';

  @override
  String get typeCard => 'Card';

  @override
  String get typeIdentity => 'Identity';

  @override
  String get typeSshKey => 'SSH key';

  @override
  String get typeBankAccount => 'Bank account';

  @override
  String get typeDriversLicense => 'Driver\'s license';

  @override
  String get typePassport => 'Passport';

  @override
  String get typeUnknown => 'Item';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get openWebsite => 'Open website';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get totpInvalid => 'This verification key cannot be read.';

  @override
  String get website => 'Website';

  @override
  String get passkey => 'Passkey';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Created on $dateString';
  }

  @override
  String get notes => 'Notes';

  @override
  String get customFields => 'Custom fields';

  @override
  String get passwordHistory => 'Password history';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Updated $updatedString, created $createdString';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String linkedTo(String field) {
    return 'Linked to $field';
  }

  @override
  String get cardholderName => 'Cardholder name';

  @override
  String get cardBrand => 'Brand';

  @override
  String get cardNumber => 'Number';

  @override
  String get cardExpiration => 'Expiration';

  @override
  String get cardExpMonth => 'Expiration month';

  @override
  String get cardExpYear => 'Expiration year';

  @override
  String get cardCode => 'Security code';

  @override
  String get fullName => 'Name';

  @override
  String get identityTitle => 'Title';

  @override
  String get firstName => 'First name';

  @override
  String get middleName => 'Middle name';

  @override
  String get lastName => 'Last name';

  @override
  String get company => 'Company';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get state => 'State or region';

  @override
  String get postalCode => 'Postal code';

  @override
  String get country => 'Country';

  @override
  String get ssn => 'Social security number';

  @override
  String get passportNumber => 'Passport number';

  @override
  String get licenseNumber => 'License number';

  @override
  String get privateKey => 'Private key';

  @override
  String get publicKey => 'Public key';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get bankName => 'Bank';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get accountType => 'Account type';

  @override
  String get accountNumber => 'Account number';

  @override
  String get routingNumber => 'Routing number';

  @override
  String get branchNumber => 'Branch number';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'SWIFT code';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Bank phone';

  @override
  String get accountTypeChecking => 'Checking';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeCertificateOfDeposit => 'Certificate of deposit';

  @override
  String get accountTypeLineOfCredit => 'Line of credit';

  @override
  String get accountTypeInvestmentBrokerage => 'Brokerage';

  @override
  String get accountTypeMoneyMarket => 'Money market';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get issuingCountry => 'Issuing country';

  @override
  String get issuingState => 'Issuing state or region';

  @override
  String get issueDate => 'Issue date';

  @override
  String get expirationDate => 'Expiration date';

  @override
  String get issuingAuthority => 'Issuing authority';

  @override
  String get licenseClass => 'Class';

  @override
  String get surname => 'Surname';

  @override
  String get givenName => 'Given name';

  @override
  String get sex => 'Sex';

  @override
  String get birthPlace => 'Place of birth';

  @override
  String get nationality => 'Nationality';

  @override
  String get passportType => 'Type';

  @override
  String get nationalId => 'National ID number';

  @override
  String get filterAllItems => 'All items';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get filterLogins => 'Logins';

  @override
  String get filterSecureNotes => 'Secure notes';

  @override
  String get filterCards => 'Cards';

  @override
  String get filterIdentities => 'Identities';

  @override
  String get filterSshKeys => 'SSH keys';

  @override
  String get filterBankAccounts => 'Bank accounts';

  @override
  String get filterDriversLicenses => 'Driver\'s licenses';

  @override
  String get filterPassports => 'Passports';

  @override
  String get filterTrash => 'Trash';

  @override
  String get noItemsHere => 'No items here.';

  @override
  String searchItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Search $count items',
      one: 'Search 1 item',
      zero: 'Search',
    );
    return '$_temp0';
  }

  @override
  String get clearSearch => 'Clear the search';

  @override
  String get noSearchResults => 'No items match your search.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes not sent yet',
      one: '1 change not sent yet',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'New item';

  @override
  String get newLogin => 'New login';

  @override
  String get editItem => 'Edit item';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get itemSaveFailed => 'The item could not be saved.';

  @override
  String get vault => 'Vault';

  @override
  String get itemName => 'Name';

  @override
  String get itemNameRequired => 'Give the item a name.';

  @override
  String get authenticatorKey => 'Authenticator key';

  @override
  String get authenticatorKeyHint => 'Base32 secret or otpauth:// URI';

  @override
  String get addWebsite => 'Add a website';

  @override
  String get favorite => 'Favorite';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';
}
