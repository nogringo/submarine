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
  String get openVault => 'Open a vault';

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
      'This is neither a vault key nor a bunker address.';

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
  String get vaultSettings => 'Vault settings';

  @override
  String get vaultNameAndColor => 'Name and color';

  @override
  String get vaultPublicKey => 'Public key';

  @override
  String get vaultKeyDescription =>
      'Anyone who has it can open this vault. Enter it on another device to open the vault there, or give it to someone to share the vault with them.';

  @override
  String get vaultKeyHelper =>
      'An nsec, a key in hex, an ncryptsec or a bunker:// address.';

  @override
  String get vaultKeyPassword => 'Key password';

  @override
  String get vaultKeyPasswordWrong => 'This password does not open the key.';

  @override
  String get vaultKeyDecrypting => 'Decrypting the key';

  @override
  String get keepKeyOutside => 'Or keep the key outside Submarine';

  @override
  String get browserExtension => 'Browser extension';

  @override
  String get signerApp => 'Signer app';

  @override
  String get bunker => 'Bunker';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Scan this code with your bunker or signer app, or paste the address into it.';

  @override
  String get noBrowserExtension => 'No Nostr extension in this browser.';

  @override
  String get noSignerApp => 'No signer app, such as Amber, on this device.';

  @override
  String get signerRefused => 'The request was refused.';

  @override
  String get waitingForAnswer => 'Waiting for an answer';

  @override
  String get bunkerUrlInvalid =>
      'This bunker address lacks a relay or a secret.';

  @override
  String get bunkerNoAnswer => 'The bunker did not answer.';

  @override
  String get bunkerApproval =>
      'The bunker asks you to approve Submarine on its page.';

  @override
  String get openApprovalPage => 'Open the page';

  @override
  String get nothingConnected => 'Nothing connected in time.';

  @override
  String get useAnotherKey => 'Use another key';

  @override
  String get vaultSignerDescription =>
      'Holds the vault key, which never enters Submarine. On another device, open the vault the same way.';

  @override
  String get askSignerAtStart => 'Ask the signer at each launch';

  @override
  String get askSignerAtStartDescription =>
      'Off, a key kept on this device reads the vault even when the signer is out of reach. On, the vault stays closed until the signer opens it.';

  @override
  String get askSignerFailed => 'The signer refused or failed.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests wait for your signer',
      one: '1 request waits for your signer',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'Waiting for your signer';

  @override
  String get signerRequestsDescription =>
      'Approve these requests in your signer, or cancel them.';

  @override
  String get requestOpenVault => 'Open the vault';

  @override
  String get requestLockVault => 'Lock the vault behind the signer';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Decrypt $count versions of items',
      one: 'Decrypt a version of an item',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count versions of items',
      one: 'Save a version of an item',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count versions of items for good',
      one: 'Delete a version of an item for good',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Save the relay list';

  @override
  String get requestReadRelays => 'Read the private relays';

  @override
  String get requestEncryptRelays => 'Encrypt the private relays';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sign in to $count relays',
      one: 'Sign in to a relay',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other requests ($method)',
      one: 'Other request ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Cancel all';

  @override
  String get close => 'Close';

  @override
  String get sync => 'Sync';

  @override
  String get syncAllSent => 'Every change is on your relays.';

  @override
  String get relays => 'Relays';

  @override
  String get relaysDescription =>
      'This vault is copied to each of these relays. They only see encrypted data and its public key.';

  @override
  String get relayConnected => 'Connected';

  @override
  String get relayNotConnected => 'Not connected';

  @override
  String get relayPrivate => 'Private';

  @override
  String get removeRelay => 'Remove this relay';

  @override
  String get addRelay => 'Add a relay';

  @override
  String get relayAddress => 'Relay address';

  @override
  String get relayAddressInvalid => 'This is not a relay address.';

  @override
  String get relayAlreadyListed => 'This relay is already in the list.';

  @override
  String get relayKeepPrivate => 'Keep private';

  @override
  String get relayKeepPrivateDescription =>
      'Encrypted in the vault\'s relay list: only those who have the vault key know the vault is on it.';

  @override
  String get relaysSaveFailed => 'The relays could not be saved.';

  @override
  String get relaysWaitForSync =>
      'You can change the relays once the vault has synced.';

  @override
  String get relayAdded => 'New';

  @override
  String get relayRemoved => 'Removed';

  @override
  String get keepRelay => 'Keep this relay';

  @override
  String get relaysNeedOne => 'The vault needs at least one relay.';

  @override
  String get add => 'Add';

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
  String get signerDidNotOpen => 'Signer did not open the vault';

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
  String get signerDidNotOpenVault =>
      'The signer did not open this vault. Sync to ask it again.';

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
  String get filterAllShort => 'All';

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
  String get newCard => 'New card';

  @override
  String get newSecureNote => 'New secure note';

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
  String get addField => 'Add a field';

  @override
  String get customField => 'Custom field';

  @override
  String get editField => 'Edit the field';

  @override
  String get fieldType => 'Field type';

  @override
  String get fieldTypeText => 'Text';

  @override
  String get fieldTypeHidden => 'Hidden';

  @override
  String get fieldTypeCheckbox => 'Checkbox';

  @override
  String get fieldTypeLinked => 'Linked';

  @override
  String get textFieldHelp =>
      'Use text fields for data like security questions.';

  @override
  String get hiddenFieldHelp =>
      'Use hidden fields for sensitive data like a password.';

  @override
  String get checkboxFieldHelp =>
      'Use checkboxes to fill a checkbox of a form, like remember my email.';

  @override
  String get linkedFieldHelp =>
      'Use a linked field when autofill has trouble with a specific website.';

  @override
  String get fieldLabel => 'Field label';

  @override
  String get linkedFieldLabelHelp =>
      'Enter the HTML id, name, aria-label or placeholder of the field.';

  @override
  String editFieldNamed(String field) {
    return 'Edit $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return 'Delete $field';
  }

  @override
  String reorderField(String field) {
    return 'Move $field';
  }

  @override
  String get cardBrandOther => 'Other';

  @override
  String get cardExpYearHint => 'YYYY';

  @override
  String get notSet => 'Not set';

  @override
  String get favorite => 'Favorite';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get discardChanges => 'Discard your changes?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get moreActions => 'More actions';

  @override
  String get copyUsername => 'Copy username';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get copyTotp => 'Copy verification code';

  @override
  String get copyNumber => 'Copy number';

  @override
  String get moveToTrash => 'Move to trash';

  @override
  String get restore => 'Restore';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get deleteItemTitle => 'Delete this item permanently?';

  @override
  String get deleteItemBody =>
      'It is erased from this device and from your relays. This cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get generatePassword => 'Generate a password';

  @override
  String get generateUsername => 'Generate a username';

  @override
  String get generator => 'Generator';

  @override
  String get passphrase => 'Passphrase';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get passwordLength => 'Length';

  @override
  String get includeCharacters => 'Include';

  @override
  String get uppercaseLetters => 'Uppercase letters';

  @override
  String get lowercaseLetters => 'Lowercase letters';

  @override
  String get digits => 'Digits';

  @override
  String get specialCharacters => 'Special characters';

  @override
  String get minNumbers => 'Minimum digits';

  @override
  String get minSpecial => 'Minimum special characters';

  @override
  String get avoidAmbiguous => 'Avoid ambiguous characters';

  @override
  String get numberOfWords => 'Number of words';

  @override
  String get wordSeparator => 'Word separator';

  @override
  String get capitalize => 'Capitalize';

  @override
  String get includeNumber => 'Include a number';

  @override
  String get usePassword => 'Use this password';

  @override
  String get usePassphrase => 'Use this passphrase';

  @override
  String get useUsername => 'Use this username';

  @override
  String get usernameCapitalize => 'Capitalize';

  @override
  String get usernameIncludeNumber => 'Include a number';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get settings => 'Settings';

  @override
  String get security => 'Security';

  @override
  String get unlockWithBiometrics => 'Unlock with biometrics';

  @override
  String get unlockWithBiometricsDescription =>
      'Or with the code or password of this device. Vault keys stay in its secure storage.';

  @override
  String get lockNeedsScreenLock =>
      'Set up a screen lock on this device first.';

  @override
  String get lockUnavailable => 'Not available on this system.';

  @override
  String get lockAfter => 'Lock after';

  @override
  String get lockImmediately => 'Immediately';

  @override
  String get lockOnRestart => 'On app restart';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'Clear copied passwords after';

  @override
  String get never => 'Never';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Allow screen capture';

  @override
  String get allowScreenCaptureDescription =>
      'Lets screenshots, recordings and screen sharing show your passwords.';

  @override
  String get lock => 'Lock';

  @override
  String get unlock => 'Unlock';

  @override
  String get vaultsLocked => 'Your vaults are locked.';

  @override
  String get unlockReason => 'Unlock your vaults';

  @override
  String get enableLockReason => 'Turn on the lock';

  @override
  String get authLockedOut => 'Too many attempts. Try again later.';

  @override
  String get authFailed => 'This device could not check it\'s you.';

  @override
  String get vaultTab => 'Vault';

  @override
  String get storageReadFailed => 'Your vaults could not be read.';

  @override
  String get storageReadFailedBody =>
      'The secure storage of this device refused to open them. Nothing was erased: try again. Your items stay on the relays, and a vault\'s key opens it on any device.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get importExport => 'Import and export';

  @override
  String get importFromBitwarden => 'Import from Bitwarden';

  @override
  String get importFromBitwardenDescription => 'A JSON export from Bitwarden.';

  @override
  String get importButton => 'Import';

  @override
  String get importReadFailed => 'The file could not be read.';

  @override
  String get importNotBitwarden =>
      'This file is not a JSON export from Bitwarden.';

  @override
  String get importEncrypted =>
      'This export is restricted to your Bitwarden account, and only Bitwarden opens it. Export your vault from Bitwarden again, password protected or in the .json format.';

  @override
  String get importEmpty => 'This export has no items.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items found in $file.',
      one: '1 item found in $file.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done of $total items imported';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items imported into $vault.',
      one: '1 item imported into $vault.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'The import stopped: $done of $total items were saved.';
  }

  @override
  String get exportVault => 'Export a vault';

  @override
  String get exportVaultDescription =>
      'A Bitwarden JSON file, protected by a password or not encrypted.';

  @override
  String get exportButton => 'Export';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items. The trash is left out.',
      one: '1 item. The trash is left out.',
      zero: 'This vault has no items to export.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'The file is not encrypted. Do not send it by email, and delete it once you are done with it.';

  @override
  String get exportFailed => 'The file could not be saved.';

  @override
  String get importPasswordBody =>
      'This export is protected by a password. Enter it to open the file.';

  @override
  String get filePassword => 'File password';

  @override
  String get wrongFilePassword => 'This password does not open the file.';

  @override
  String get exportProtect => 'Protect with a password';

  @override
  String get confirmFilePassword => 'Confirm the file password';

  @override
  String get filePasswordHelper =>
      'Submarine and Bitwarden ask for it to import the file. It cannot be recovered.';

  @override
  String get filePasswordRequired => 'Choose a password.';

  @override
  String get filePasswordMismatch => 'The passwords do not match.';
}
