import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Name of the view showing the items of every vault at once.
  ///
  /// In en, this message translates to:
  /// **'All vaults'**
  String get allVaults;

  /// Title of the drawer listing the vaults, and tooltip of the button opening it.
  ///
  /// In en, this message translates to:
  /// **'Vaults'**
  String get vaults;

  /// Button and dialog title to add a vault to this device.
  ///
  /// In en, this message translates to:
  /// **'Add a vault'**
  String get addVault;

  /// Choice and dialog title to create a new vault with a new key.
  ///
  /// In en, this message translates to:
  /// **'Create a vault'**
  String get createVault;

  /// Explains the choice to create a vault.
  ///
  /// In en, this message translates to:
  /// **'A new, empty vault with its own key.'**
  String get createVaultDescription;

  /// Choice to open an existing vault by entering its key.
  ///
  /// In en, this message translates to:
  /// **'Open a vault with its key'**
  String get openVault;

  /// Explains the choice to open a vault with its key.
  ///
  /// In en, this message translates to:
  /// **'From another device, or shared with you.'**
  String get openVaultDescription;

  /// Title of the dialog opening a vault with its key.
  ///
  /// In en, this message translates to:
  /// **'Open a vault'**
  String get openVaultTitle;

  /// Label of the field naming a vault.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get vaultName;

  /// Help under the vault name field: the name is local to the device.
  ///
  /// In en, this message translates to:
  /// **'Only on this device. Someone you share the vault with names it their own way.'**
  String get vaultNameHelper;

  /// Error when the vault name is empty.
  ///
  /// In en, this message translates to:
  /// **'Give the vault a name.'**
  String get vaultNameRequired;

  /// Label above the color choices of a vault.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get vaultColor;

  /// Accessibility label of one color choice, numbered from 1.
  ///
  /// In en, this message translates to:
  /// **'Color {number}'**
  String vaultColorOption(int number);

  /// Label of the field where the vault key (an nsec) is entered.
  ///
  /// In en, this message translates to:
  /// **'Vault key'**
  String get vaultKey;

  /// Error when the entered text is not a vault key.
  ///
  /// In en, this message translates to:
  /// **'This is not a vault key. It starts with nsec1.'**
  String get vaultKeyInvalid;

  /// Error when the entered key belongs to a vault already on this device, named name.
  ///
  /// In en, this message translates to:
  /// **'This vault is already open, as {name}.'**
  String vaultAlreadyOpen(String name);

  /// Error when the vault could not be written to the device's secure storage.
  ///
  /// In en, this message translates to:
  /// **'The vault could not be saved on this device.'**
  String get vaultSaveFailed;

  /// Title of the dialog showing the key of a vault just created.
  ///
  /// In en, this message translates to:
  /// **'Save the vault key'**
  String get saveVaultKeyTitle;

  /// Asks to keep the key of a vault just created somewhere safe.
  ///
  /// In en, this message translates to:
  /// **'Anyone who has this key can open the vault. Keep it somewhere safe: you need it to open the vault on another device, or to share it.'**
  String get saveVaultKeyBody;

  /// Button closing a dialog without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button confirming the creation of a vault.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Button confirming the opening of a vault with its key.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Button closing the dialog that shows a new vault key.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Tagline under the Submarine wordmark on the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'A password manager built on Nostr.'**
  String get welcomeTagline;

  /// Number of items in a vault, under its name in the drawer.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// Tooltip of the button fetching changes from the relays now.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// Sync status while a vault is fetched from its relays for the first time.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncing;

  /// Sync status of a vault that never reached a relay.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get syncNever;

  /// Sync status when no relay answers.
  ///
  /// In en, this message translates to:
  /// **'Relays unreachable'**
  String get syncFailed;

  /// Sync status when the last sync was less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get syncedJustNow;

  /// Sync status when the last sync was minutes ago.
  ///
  /// In en, this message translates to:
  /// **'Synced {minutes} min ago'**
  String syncedMinutesAgo(int minutes);

  /// Sync status when the last sync was hours ago.
  ///
  /// In en, this message translates to:
  /// **'Synced {hours} h ago'**
  String syncedHoursAgo(int hours);

  /// Sync status when the last sync was more than a day ago.
  ///
  /// In en, this message translates to:
  /// **'Synced on {date}'**
  String syncedOn(DateTime date);

  /// Shown in place of the list when a synced vault has no items.
  ///
  /// In en, this message translates to:
  /// **'No items in this vault yet.'**
  String get noItems;

  /// Shown in place of the list while a vault was never synced.
  ///
  /// In en, this message translates to:
  /// **'Looking for items on the relays'**
  String get lookingForItems;

  /// Shown in the item pane of the wide layout when no item is selected.
  ///
  /// In en, this message translates to:
  /// **'Select an item to see it here.'**
  String get selectItem;

  /// Shown when the item asked for is not in the vault, for example deleted on another device.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer in the vault.'**
  String get itemNotFound;

  /// Item type: a login with a username and a password.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get typeLogin;

  /// Item type: a note.
  ///
  /// In en, this message translates to:
  /// **'Secure note'**
  String get typeSecureNote;

  /// Item type: a payment card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get typeCard;

  /// Item type: a person's identity details.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get typeIdentity;

  /// Item type: an SSH key pair.
  ///
  /// In en, this message translates to:
  /// **'SSH key'**
  String get typeSshKey;

  /// Item type: a bank account.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get typeBankAccount;

  /// Item type: a driver's license.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license'**
  String get typeDriversLicense;

  /// Item type: a passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get typePassport;

  /// Item type unknown to this version of the app.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get typeUnknown;

  /// Tooltip of the button copying a value.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Tooltip of the copy button right after copying.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// Tooltip of the button showing a hidden value.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// Tooltip of the button hiding a shown value.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// Tooltip of the button opening a login's website in the browser.
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get openWebsite;

  /// Field label: the username of a login or an identity.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Field label: the password of a login.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Field label: the current two-step verification code (TOTP) of a login.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// Shown in place of the verification code when its key cannot be read.
  ///
  /// In en, this message translates to:
  /// **'This verification key cannot be read.'**
  String get totpInvalid;

  /// Field label: a website of a login.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Field label: a passkey saved with a login.
  ///
  /// In en, this message translates to:
  /// **'Passkey'**
  String get passkey;

  /// Value of a passkey field: when the passkey was created.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String passkeyCreated(DateTime date);

  /// Field label: the notes of an item.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Title of the custom fields of an item.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get customFields;

  /// Title of the list of passwords an item used before.
  ///
  /// In en, this message translates to:
  /// **'Password history'**
  String get passwordHistory;

  /// When an item was last updated and created, at the bottom of its details.
  ///
  /// In en, this message translates to:
  /// **'Updated {updated}, created {created}'**
  String itemDates(DateTime updated, DateTime created);

  /// Value of a checked boolean custom field.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Value of an unchecked boolean custom field.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Value of a custom field linked to another field of the item, named field.
  ///
  /// In en, this message translates to:
  /// **'Linked to {field}'**
  String linkedTo(String field);

  /// Field label: the name on a payment card.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get cardholderName;

  /// Field label: the brand of a payment card, like Visa.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get cardBrand;

  /// Field label: the number of a payment card.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get cardNumber;

  /// Field label: the expiration month and year of a payment card.
  ///
  /// In en, this message translates to:
  /// **'Expiration'**
  String get cardExpiration;

  /// Field label: the expiration month of a payment card.
  ///
  /// In en, this message translates to:
  /// **'Expiration month'**
  String get cardExpMonth;

  /// Field label: the expiration year of a payment card.
  ///
  /// In en, this message translates to:
  /// **'Expiration year'**
  String get cardExpYear;

  /// Field label: the security code (CVV) of a payment card.
  ///
  /// In en, this message translates to:
  /// **'Security code'**
  String get cardCode;

  /// Field label: a person's full name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fullName;

  /// Field label: a person's title, like Mr or Ms.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get identityTitle;

  /// Field label: a person's first name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// Field label: a person's middle name.
  ///
  /// In en, this message translates to:
  /// **'Middle name'**
  String get middleName;

  /// Field label: a person's last name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// Field label: the company of an identity.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// Field label: an email address.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Field label: a phone number.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Field label: a postal address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Field label: the city of an address.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Field label: the state or region of an address.
  ///
  /// In en, this message translates to:
  /// **'State or region'**
  String get state;

  /// Field label: the postal code of an address.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// Field label: the country of an address.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Field label: a social security number.
  ///
  /// In en, this message translates to:
  /// **'Social security number'**
  String get ssn;

  /// Field label: a passport number.
  ///
  /// In en, this message translates to:
  /// **'Passport number'**
  String get passportNumber;

  /// Field label: a driver's license number.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get licenseNumber;

  /// Field label: the private part of an SSH key.
  ///
  /// In en, this message translates to:
  /// **'Private key'**
  String get privateKey;

  /// Field label: the public part of an SSH key.
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get publicKey;

  /// Field label: the fingerprint of an SSH key.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// Field label: the name of a bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankName;

  /// Field label: the name on a bank account.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get accountHolder;

  /// Field label: the type of a bank account.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// Field label: the number of a bank account.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// Field label: the routing number of a bank account.
  ///
  /// In en, this message translates to:
  /// **'Routing number'**
  String get routingNumber;

  /// Field label: the branch number of a bank account.
  ///
  /// In en, this message translates to:
  /// **'Branch number'**
  String get branchNumber;

  /// Field label: the PIN of a bank account.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// Field label: the SWIFT code of a bank.
  ///
  /// In en, this message translates to:
  /// **'SWIFT code'**
  String get swiftCode;

  /// Field label: the IBAN of a bank account.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// Field label: the phone number of a bank.
  ///
  /// In en, this message translates to:
  /// **'Bank phone'**
  String get bankPhone;

  /// Bank account type: checking account.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get accountTypeChecking;

  /// Bank account type: savings account.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get accountTypeSavings;

  /// Bank account type: certificate of deposit.
  ///
  /// In en, this message translates to:
  /// **'Certificate of deposit'**
  String get accountTypeCertificateOfDeposit;

  /// Bank account type: line of credit.
  ///
  /// In en, this message translates to:
  /// **'Line of credit'**
  String get accountTypeLineOfCredit;

  /// Bank account type: brokerage account.
  ///
  /// In en, this message translates to:
  /// **'Brokerage'**
  String get accountTypeInvestmentBrokerage;

  /// Bank account type: money market account.
  ///
  /// In en, this message translates to:
  /// **'Money market'**
  String get accountTypeMoneyMarket;

  /// Bank account type: any other type.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// Field label: a person's date of birth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// Field label: the country that issued a document.
  ///
  /// In en, this message translates to:
  /// **'Issuing country'**
  String get issuingCountry;

  /// Field label: the state or region that issued a document.
  ///
  /// In en, this message translates to:
  /// **'Issuing state or region'**
  String get issuingState;

  /// Field label: when a document was issued.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get issueDate;

  /// Field label: when a document expires.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get expirationDate;

  /// Field label: the authority that issued a document.
  ///
  /// In en, this message translates to:
  /// **'Issuing authority'**
  String get issuingAuthority;

  /// Field label: the class of a driver's license.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get licenseClass;

  /// Field label: the surname on a passport.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// Field label: the given name on a passport.
  ///
  /// In en, this message translates to:
  /// **'Given name'**
  String get givenName;

  /// Field label: the sex on a passport.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// Field label: the place of birth on a passport.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get birthPlace;

  /// Field label: the nationality on a passport.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// Field label: the type of a passport.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get passportType;

  /// Field label: the national identification number on a passport.
  ///
  /// In en, this message translates to:
  /// **'National ID number'**
  String get nationalId;

  /// Filter: every item outside the trash.
  ///
  /// In en, this message translates to:
  /// **'All items'**
  String get filterAllItems;

  /// Filter: the items marked as favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// Filter: the logins.
  ///
  /// In en, this message translates to:
  /// **'Logins'**
  String get filterLogins;

  /// Filter: the secure notes.
  ///
  /// In en, this message translates to:
  /// **'Secure notes'**
  String get filterSecureNotes;

  /// Filter: the payment cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get filterCards;

  /// Filter: the identities.
  ///
  /// In en, this message translates to:
  /// **'Identities'**
  String get filterIdentities;

  /// Filter: the SSH keys.
  ///
  /// In en, this message translates to:
  /// **'SSH keys'**
  String get filterSshKeys;

  /// Filter: the bank accounts.
  ///
  /// In en, this message translates to:
  /// **'Bank accounts'**
  String get filterBankAccounts;

  /// Filter: the driver's licenses.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s licenses'**
  String get filterDriversLicenses;

  /// Filter: the passports.
  ///
  /// In en, this message translates to:
  /// **'Passports'**
  String get filterPassports;

  /// Filter: the items in the trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get filterTrash;

  /// Shown in place of the list when a filter matches no item.
  ///
  /// In en, this message translates to:
  /// **'No items here.'**
  String get noItemsHere;

  /// Placeholder of the search box above the items, with the number of items listed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Search} =1{Search 1 item} other{Search {count} items}}'**
  String searchItems(int count);

  /// Tooltip of the button emptying the search box.
  ///
  /// In en, this message translates to:
  /// **'Clear the search'**
  String get clearSearch;

  /// Shown in place of the list when the search matches no item.
  ///
  /// In en, this message translates to:
  /// **'No items match your search.'**
  String get noSearchResults;

  /// Sync status when changes saved on this device have reached no relay yet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change not sent yet} other{{count} changes not sent yet}}'**
  String changesNotSent(int count);

  /// Button adding an item to a vault.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// Title of the form creating a login.
  ///
  /// In en, this message translates to:
  /// **'New login'**
  String get newLogin;

  /// Title of the form editing an item.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// Button opening the form that edits an item.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button saving an item.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Shown in the item form when saving failed.
  ///
  /// In en, this message translates to:
  /// **'The item could not be saved.'**
  String get itemSaveFailed;

  /// Label of the vault an item is created in.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vault;

  /// Label of an item's name in the item form.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get itemName;

  /// Error when saving an item without a name.
  ///
  /// In en, this message translates to:
  /// **'Give the item a name.'**
  String get itemNameRequired;

  /// Label of the TOTP secret of a login in the item form.
  ///
  /// In en, this message translates to:
  /// **'Authenticator key'**
  String get authenticatorKey;

  /// Placeholder of the authenticator key field.
  ///
  /// In en, this message translates to:
  /// **'Base32 secret or otpauth:// URI'**
  String get authenticatorKeyHint;

  /// Button adding a website field to a login in the item form.
  ///
  /// In en, this message translates to:
  /// **'Add a website'**
  String get addWebsite;

  /// Switch marking an item as favorite in the item form.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// Tooltip of the star of an item that is not a favorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// Tooltip of the star of a favorite item.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// Title of the dialog shown when leaving the item form with changes not saved.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get discardChanges;

  /// Button of that dialog that stays in the item form.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// Button of that dialog that leaves the item form and loses the changes.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
