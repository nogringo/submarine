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

  /// Title of the drawer listing the vaults, of their section in the settings, and tooltip of the button opening the drawer.
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

  /// Choice to open an existing vault, with its key or a signer holding it.
  ///
  /// In en, this message translates to:
  /// **'Open a vault'**
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

  /// Help under the vault name field, and under the name and color section of the vault settings: the name is local to the device.
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

  /// The vault key (an nsec): label of the field where it is entered, and title of the vault settings section and row showing it.
  ///
  /// In en, this message translates to:
  /// **'Vault key'**
  String get vaultKey;

  /// Error when the entered text is not a vault key.
  ///
  /// In en, this message translates to:
  /// **'This is neither a vault key nor a bunker address.'**
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

  /// Subtitle of the vault settings screen, and tooltip of the buttons opening it.
  ///
  /// In en, this message translates to:
  /// **'Vault settings'**
  String get vaultSettings;

  /// Title of the vault settings section renaming and recoloring the vault.
  ///
  /// In en, this message translates to:
  /// **'Name and color'**
  String get vaultNameAndColor;

  /// Row of the vault settings showing the vault's public key (an npub).
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get vaultPublicKey;

  /// Explains the vault key, in the vault settings row that shows it.
  ///
  /// In en, this message translates to:
  /// **'Anyone who has it can open this vault. Enter it on another device to open the vault there, or give it to someone to share the vault with them.'**
  String get vaultKeyDescription;

  /// Under the vault key field: what it accepts.
  ///
  /// In en, this message translates to:
  /// **'An nsec, a key in hex, an ncryptsec or a bunker:// address.'**
  String get vaultKeyHelper;

  /// Label of the field shown for a vault key encrypted with a password (an ncryptsec, NIP-49).
  ///
  /// In en, this message translates to:
  /// **'Key password'**
  String get vaultKeyPassword;

  /// Error when the password does not decrypt the ncryptsec.
  ///
  /// In en, this message translates to:
  /// **'This password does not open the key.'**
  String get vaultKeyPasswordWrong;

  /// Shown while an ncryptsec is decrypted with its password, which takes a moment.
  ///
  /// In en, this message translates to:
  /// **'Decrypting the key'**
  String get vaultKeyDecrypting;

  /// Above the buttons opening a vault through a signer that holds its key.
  ///
  /// In en, this message translates to:
  /// **'Or keep the key outside Submarine'**
  String get keepKeyOutside;

  /// A Nostr browser extension holding the vault key (NIP-07): button of the open vault dialog, and name of the signer in the vault settings.
  ///
  /// In en, this message translates to:
  /// **'Browser extension'**
  String get browserExtension;

  /// An Android app holding the vault key, such as Amber (NIP-55): button of the open vault dialog, and name of the signer in the vault settings.
  ///
  /// In en, this message translates to:
  /// **'Signer app'**
  String get signerApp;

  /// A remote signer reached through relays (NIP-46): name of the signer in the vault settings.
  ///
  /// In en, this message translates to:
  /// **'Bunker'**
  String get bunker;

  /// Button of the open vault dialog showing a nostrconnect:// code for a bunker or a signer app to scan, and title of that dialog. A protocol name, not translated.
  ///
  /// In en, this message translates to:
  /// **'Nostr Connect'**
  String get nostrConnect;

  /// Explains the Nostr Connect dialog.
  ///
  /// In en, this message translates to:
  /// **'Scan this code with your bunker or signer app, or paste the address into it.'**
  String get nostrConnectBody;

  /// Error when the browser has no NIP-07 extension.
  ///
  /// In en, this message translates to:
  /// **'No Nostr extension in this browser.'**
  String get noBrowserExtension;

  /// Error when no NIP-55 signer app is installed.
  ///
  /// In en, this message translates to:
  /// **'No signer app, such as Amber, on this device.'**
  String get noSignerApp;

  /// Error when the extension or the signer app refused to give the vault's public key.
  ///
  /// In en, this message translates to:
  /// **'The request was refused.'**
  String get signerRefused;

  /// Shown while the dialog waits for a bunker, an extension or a signer app.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an answer'**
  String get waitingForAnswer;

  /// Error when a bunker:// address cannot be used.
  ///
  /// In en, this message translates to:
  /// **'This bunker address lacks a relay or a secret.'**
  String get bunkerUrlInvalid;

  /// Error when a bunker never answered the connection.
  ///
  /// In en, this message translates to:
  /// **'The bunker did not answer.'**
  String get bunkerNoAnswer;

  /// Shown when a bunker sends a page where the user approves the app.
  ///
  /// In en, this message translates to:
  /// **'The bunker asks you to approve Submarine on its page.'**
  String get bunkerApproval;

  /// Button opening the approval page a bunker sent.
  ///
  /// In en, this message translates to:
  /// **'Open the page'**
  String get openApprovalPage;

  /// Error when no bunker or signer app answered the Nostr Connect code.
  ///
  /// In en, this message translates to:
  /// **'Nothing connected in time.'**
  String get nothingConnected;

  /// Tooltip of the button dropping the signer chosen in the open vault dialog.
  ///
  /// In en, this message translates to:
  /// **'Use another key'**
  String get useAnotherKey;

  /// In the vault settings, under the name of the signer holding the vault key.
  ///
  /// In en, this message translates to:
  /// **'Holds the vault key, which never enters Submarine. On another device, open the vault the same way.'**
  String get vaultSignerDescription;

  /// Switch in the settings of a vault held by a signer: the signer then opens the vault each time the app starts.
  ///
  /// In en, this message translates to:
  /// **'Ask the signer at each launch'**
  String get askSignerAtStart;

  /// Under the switch asking the signer at each launch.
  ///
  /// In en, this message translates to:
  /// **'Off, a key kept on this device reads the vault even when the signer is out of reach. On, the vault stays closed until the signer opens it.'**
  String get askSignerAtStartDescription;

  /// Error under the switch asking the signer at each launch, when the signer did not do what it was asked.
  ///
  /// In en, this message translates to:
  /// **'The signer refused or failed.'**
  String get askSignerFailed;

  /// Bar at the bottom of a narrow screen, and tooltip of the rail button, while a signer waits on the user to approve requests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request waits for your signer} other{{count} requests wait for your signer}}'**
  String signerWaiting(int count);

  /// Title of the dialog or sheet listing what the signers wait on the user for.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your signer'**
  String get signerRequestsTitle;

  /// Under the title of the dialog or sheet listing what the signers wait on the user for.
  ///
  /// In en, this message translates to:
  /// **'Approve these requests in your signer, or cancel them.'**
  String get signerRequestsDescription;

  /// Request to a signer: decrypt the key that opens a vault set to ask the signer at each launch.
  ///
  /// In en, this message translates to:
  /// **'Open the vault'**
  String get requestOpenVault;

  /// Request to a signer: encrypt the key of the vault on this device, once the vault asks the signer at each launch.
  ///
  /// In en, this message translates to:
  /// **'Lock the vault behind the signer'**
  String get requestLockVault;

  /// Requests to a signer: decrypt versions of items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Decrypt a version of an item} other{Decrypt {count} versions of items}}'**
  String requestDecryptVersions(int count);

  /// Requests to a signer: sign versions of items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save a version of an item} other{Save {count} versions of items}}'**
  String requestSaveVersions(int count);

  /// Requests to a signer: sign deletion requests, one per version of an item.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete a version of an item for good} other{Delete {count} versions of items for good}}'**
  String requestDeleteVersions(int count);

  /// Request to a signer: sign the relay list of a vault.
  ///
  /// In en, this message translates to:
  /// **'Save the relay list'**
  String get requestSaveRelays;

  /// Request to a signer: decrypt the private relays of a vault.
  ///
  /// In en, this message translates to:
  /// **'Read the private relays'**
  String get requestReadRelays;

  /// Request to a signer: encrypt the private relays of a vault.
  ///
  /// In en, this message translates to:
  /// **'Encrypt the private relays'**
  String get requestEncryptRelays;

  /// Requests to a signer: sign relay authentications (NIP-42).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sign in to a relay} other{Sign in to {count} relays}}'**
  String requestRelayAuth(int count);

  /// Requests to a signer the app does not name, with their NIP-46 method.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Other request ({method})} other{{count} other requests ({method})}}'**
  String requestOther(int count, String method);

  /// Button cancelling every request the signers wait on the user for.
  ///
  /// In en, this message translates to:
  /// **'Cancel all'**
  String get cancelAll;

  /// Button closing the dialog or sheet listing what the signers wait on the user for.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Title of the vault settings section about syncing with the relays.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Under the sync status in the vault settings, once every change reached the relays.
  ///
  /// In en, this message translates to:
  /// **'Every change is on your relays.'**
  String get syncAllSent;

  /// Title of the vault settings section listing the relays the vault lives on.
  ///
  /// In en, this message translates to:
  /// **'Relays'**
  String get relays;

  /// Under the title of the relays section of the vault settings.
  ///
  /// In en, this message translates to:
  /// **'This vault is copied to each of these relays. They only see encrypted data and its public key.'**
  String get relaysDescription;

  /// Status of a relay this device has a connection to.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get relayConnected;

  /// Status of a relay this device has no connection to right now.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get relayNotConnected;

  /// Under a relay of the vault settings that is encrypted in the vault's relay list.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get relayPrivate;

  /// Tooltip of the button removing a relay from the vault.
  ///
  /// In en, this message translates to:
  /// **'Remove this relay'**
  String get removeRelay;

  /// Row of the vault settings opening the dialog that adds a relay, and title of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Add a relay'**
  String get addRelay;

  /// Field of the relay to add, a wss:// URL.
  ///
  /// In en, this message translates to:
  /// **'Relay address'**
  String get relayAddress;

  /// Error when the relay address is not a websocket URL.
  ///
  /// In en, this message translates to:
  /// **'This is not a relay address.'**
  String get relayAddressInvalid;

  /// Error when the relay to add is already one of the vault.
  ///
  /// In en, this message translates to:
  /// **'This relay is already in the list.'**
  String get relayAlreadyListed;

  /// Switch of the add relay dialog: on, the relay is encrypted in the vault's relay list.
  ///
  /// In en, this message translates to:
  /// **'Keep private'**
  String get relayKeepPrivate;

  /// Under the Keep private switch of the add relay dialog.
  ///
  /// In en, this message translates to:
  /// **'Encrypted in the vault\'s relay list: only those who have the vault key know the vault is on it.'**
  String get relayKeepPrivateDescription;

  /// Error when changing the relays of a vault failed.
  ///
  /// In en, this message translates to:
  /// **'The relays could not be saved.'**
  String get relaysSaveFailed;

  /// Under the relays of a vault that never synced, while they cannot be changed.
  ///
  /// In en, this message translates to:
  /// **'You can change the relays once the vault has synced.'**
  String get relaysWaitForSync;

  /// Status of a relay added to the draft of the vault's relays, not saved yet.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get relayAdded;

  /// Status of a relay removed from the draft of the vault's relays, not saved yet.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get relayRemoved;

  /// Tooltip of the button undoing the removal of a relay from the draft.
  ///
  /// In en, this message translates to:
  /// **'Keep this relay'**
  String get keepRelay;

  /// Under the relays when the draft has none left, which cannot be saved.
  ///
  /// In en, this message translates to:
  /// **'The vault needs at least one relay.'**
  String get relaysNeedOne;

  /// Button confirming the addition of a relay or a custom field.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

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

  /// Tooltip of the button fetching changes from the relays now, and that button in the vault settings.
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

  /// Sync status when the signer did not open a vault that asks it at each launch.
  ///
  /// In en, this message translates to:
  /// **'Signer did not open the vault'**
  String get signerDidNotOpen;

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

  /// Shown in place of the list when the signer did not open a vault that asks it at each launch.
  ///
  /// In en, this message translates to:
  /// **'The signer did not open this vault. Sync to ask it again.'**
  String get signerDidNotOpenVault;

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

  /// Chip listing every item, where the filters are chips above the items.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAllShort;

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

  /// Title of the form creating a payment card.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get newCard;

  /// Title of the form creating a secure note.
  ///
  /// In en, this message translates to:
  /// **'New secure note'**
  String get newSecureNote;

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

  /// Button opening the dialog that adds a custom field to an item, and title of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Add a field'**
  String get addField;

  /// Choice of the menu adding a field to a login: a custom field of a type and a label of choice.
  ///
  /// In en, this message translates to:
  /// **'Custom field'**
  String get customField;

  /// Title of the dialog renaming or deleting a custom field.
  ///
  /// In en, this message translates to:
  /// **'Edit the field'**
  String get editField;

  /// Label of the type of the custom field being added.
  ///
  /// In en, this message translates to:
  /// **'Field type'**
  String get fieldType;

  /// Type of custom field: plain text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldTypeText;

  /// Type of custom field: text hidden until shown.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get fieldTypeHidden;

  /// Type of custom field: checked or not.
  ///
  /// In en, this message translates to:
  /// **'Checkbox'**
  String get fieldTypeCheckbox;

  /// Type of custom field: stands for another field of the item.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get fieldTypeLinked;

  /// Under the type of custom field when it is text.
  ///
  /// In en, this message translates to:
  /// **'Use text fields for data like security questions.'**
  String get textFieldHelp;

  /// Under the type of custom field when it is hidden.
  ///
  /// In en, this message translates to:
  /// **'Use hidden fields for sensitive data like a password.'**
  String get hiddenFieldHelp;

  /// Under the type of custom field when it is a checkbox.
  ///
  /// In en, this message translates to:
  /// **'Use checkboxes to fill a checkbox of a form, like remember my email.'**
  String get checkboxFieldHelp;

  /// Under the type of custom field when it is linked.
  ///
  /// In en, this message translates to:
  /// **'Use a linked field when autofill has trouble with a specific website.'**
  String get linkedFieldHelp;

  /// Label of the name of a custom field in the dialog adding or renaming it.
  ///
  /// In en, this message translates to:
  /// **'Field label'**
  String get fieldLabel;

  /// Under the label of a linked custom field being added: what the label must match on the website.
  ///
  /// In en, this message translates to:
  /// **'Enter the HTML id, name, aria-label or placeholder of the field.'**
  String get linkedFieldLabelHelp;

  /// Tooltip of the button renaming or deleting the custom field named field.
  ///
  /// In en, this message translates to:
  /// **'Edit {field}'**
  String editFieldNamed(String field);

  /// Tooltip of the button deleting the custom field named field.
  ///
  /// In en, this message translates to:
  /// **'Delete {field}'**
  String deleteFieldNamed(String field);

  /// Tooltip of the handle dragging the custom field named field up or down.
  ///
  /// In en, this message translates to:
  /// **'Move {field}'**
  String reorderField(String field);

  /// Card brand for a card of none of the listed brands.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cardBrandOther;

  /// Placeholder of the expiration year of a card in the item form.
  ///
  /// In en, this message translates to:
  /// **'YYYY'**
  String get cardExpYearHint;

  /// Choice of a dropdown in the item form that leaves the value empty.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

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

  /// Tooltip of the button opening the menu of an item's other actions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// Menu action copying the username of a login.
  ///
  /// In en, this message translates to:
  /// **'Copy username'**
  String get copyUsername;

  /// Menu action copying the password of a login, and tooltip of the copy button of its row.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get copyPassword;

  /// Menu action copying the current TOTP code of a login.
  ///
  /// In en, this message translates to:
  /// **'Copy verification code'**
  String get copyTotp;

  /// Menu action copying the number of a payment card, and tooltip of the copy button of its row.
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get copyNumber;

  /// Menu action moving an item to the trash.
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get moveToTrash;

  /// Button taking an item out of the trash.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Menu action deleting an item in the trash for good.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// Title of the dialog confirming that an item in the trash is deleted for good.
  ///
  /// In en, this message translates to:
  /// **'Delete this item permanently?'**
  String get deleteItemTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'It is erased from this device and from your relays. This cannot be undone.'**
  String get deleteItemBody;

  /// Button of that dialog that deletes the item for good.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Tooltip of the button next to the password field that opens the generator.
  ///
  /// In en, this message translates to:
  /// **'Generate a password'**
  String get generatePassword;

  /// Tooltip of the button next to the username field that opens the generator.
  ///
  /// In en, this message translates to:
  /// **'Generate a username'**
  String get generateUsername;

  /// Title of the sheet generating a password or a passphrase.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generator;

  /// Choice in the generator for words joined by a separator, rather than a password.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get passphrase;

  /// Tooltip of the button generating another value with the same options.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// Label of the length of a generated password.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get passwordLength;

  /// Label above the character sets a generated password takes its characters from.
  ///
  /// In en, this message translates to:
  /// **'Include'**
  String get includeCharacters;

  /// Accessibility label of the A-Z choice of the generator.
  ///
  /// In en, this message translates to:
  /// **'Uppercase letters'**
  String get uppercaseLetters;

  /// Accessibility label of the a-z choice of the generator.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters'**
  String get lowercaseLetters;

  /// Accessibility label of the 0-9 choice of the generator.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// Accessibility label of the !@#$%^&* choice of the generator.
  ///
  /// In en, this message translates to:
  /// **'Special characters'**
  String get specialCharacters;

  /// Label of the fewest digits a generated password has.
  ///
  /// In en, this message translates to:
  /// **'Minimum digits'**
  String get minNumbers;

  /// Label of the fewest special characters a generated password has.
  ///
  /// In en, this message translates to:
  /// **'Minimum special characters'**
  String get minSpecial;

  /// Switch leaving out I, O, l, 0 and 1, easily mistaken for one another.
  ///
  /// In en, this message translates to:
  /// **'Avoid ambiguous characters'**
  String get avoidAmbiguous;

  /// Label of the number of words of a generated passphrase.
  ///
  /// In en, this message translates to:
  /// **'Number of words'**
  String get numberOfWords;

  /// Label of the character between the words of a generated passphrase.
  ///
  /// In en, this message translates to:
  /// **'Word separator'**
  String get wordSeparator;

  /// Switch capitalizing the first letter of each word of a passphrase.
  ///
  /// In en, this message translates to:
  /// **'Capitalize'**
  String get capitalize;

  /// Switch adding a digit at the end of one word of a passphrase.
  ///
  /// In en, this message translates to:
  /// **'Include a number'**
  String get includeNumber;

  /// Button of the generator that puts the password in the password field.
  ///
  /// In en, this message translates to:
  /// **'Use this password'**
  String get usePassword;

  /// Button of the generator that puts the passphrase in the password field.
  ///
  /// In en, this message translates to:
  /// **'Use this passphrase'**
  String get usePassphrase;

  /// Button of the generator that puts the username in the username field.
  ///
  /// In en, this message translates to:
  /// **'Use this username'**
  String get useUsername;

  /// Switch capitalizing the first letter of a generated username.
  ///
  /// In en, this message translates to:
  /// **'Capitalize'**
  String get usernameCapitalize;

  /// Switch adding 4 digits at the end of a generated username.
  ///
  /// In en, this message translates to:
  /// **'Include a number'**
  String get usernameIncludeNumber;

  /// Tooltip of the button lowering a number by one.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// Tooltip of the button raising a number by one.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// Title of the app settings, and tooltip of the button opening them.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Section of the settings about locking the app.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Switch of the settings that turns the app lock on: the app then locks, and unlocks with the device's biometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get unlockWithBiometrics;

  /// Explains the lock switch: the device's code is a fallback, and nothing is encrypted with a master password.
  ///
  /// In en, this message translates to:
  /// **'Or with the code or password of this device. Vault keys stay in its secure storage.'**
  String get unlockWithBiometricsDescription;

  /// Why the lock cannot be turned on: the device has no code, password or biometrics.
  ///
  /// In en, this message translates to:
  /// **'Set up a screen lock on this device first.'**
  String get lockNeedsScreenLock;

  /// Setting choosing how long the app may go unused before it locks.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get lockAfter;

  /// Lock delay: the app locks as soon as it leaves the screen.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get lockImmediately;

  /// Lock delay: the app locks only when it starts again.
  ///
  /// In en, this message translates to:
  /// **'On app restart'**
  String get lockOnRestart;

  /// A lock or clipboard delay in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minutes(int count);

  /// A lock delay in hours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String hours(int count);

  /// Setting choosing how long a copied password, code or vault key stays in the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Clear copied passwords after'**
  String get clearClipboardAfter;

  /// Clipboard delay: copied passwords stay in the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// A clipboard delay in seconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String seconds(int count);

  /// Switch of the settings, on Android only, that stops blocking screenshots, recordings and screen sharing of the app.
  ///
  /// In en, this message translates to:
  /// **'Allow screen capture'**
  String get allowScreenCapture;

  /// Explains the screen capture switch: what turning it on exposes.
  ///
  /// In en, this message translates to:
  /// **'Lets screenshots, recordings and screen sharing show your passwords.'**
  String get allowScreenCaptureDescription;

  /// Tooltip of the button locking the app now.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// Button of the lock screen asking the device to check the user.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Line under the wordmark on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Your vaults are locked.'**
  String get vaultsLocked;

  /// Reason shown in the system dialog of biometrics when unlocking. The title of the dialog on macOS: no final period.
  ///
  /// In en, this message translates to:
  /// **'Unlock your vaults'**
  String get unlockReason;

  /// Reason shown in the system dialog of biometrics when turning the lock on. The title of the dialog on macOS: no final period.
  ///
  /// In en, this message translates to:
  /// **'Turn on the lock'**
  String get enableLockReason;

  /// Error when the device refuses to check the user for a while.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authLockedOut;

  /// Error when the device check failed for another reason.
  ///
  /// In en, this message translates to:
  /// **'This device could not check it\'s you.'**
  String get authFailed;

  /// Label of the bottom bar tab listing the items of the vaults.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vaultTab;

  /// Line under the wordmark when the device's secure storage failed to open at launch.
  ///
  /// In en, this message translates to:
  /// **'Your vaults could not be read.'**
  String get storageReadFailed;

  /// Explanation under storageReadFailed.
  ///
  /// In en, this message translates to:
  /// **'The secure storage of this device refused to open them. Nothing was erased: try again. Your items stay on the relays, and a vault\'s key opens it on any device.'**
  String get storageReadFailedBody;

  /// Button reading the device's secure storage again after it failed.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Section of the settings about the look of the app.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Setting choosing between the light and the dark theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Theme option: light or dark as the system is.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme option: always light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option: always dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Section of the settings about Bitwarden files.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get importExport;

  /// Settings row, and title of the dialog importing a Bitwarden export.
  ///
  /// In en, this message translates to:
  /// **'Import from Bitwarden'**
  String get importFromBitwarden;

  /// Explains the import row: the file it takes.
  ///
  /// In en, this message translates to:
  /// **'A JSON export from Bitwarden.'**
  String get importFromBitwardenDescription;

  /// Button picking a Bitwarden export, then importing its items.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// Error when the picked file could not be opened.
  ///
  /// In en, this message translates to:
  /// **'The file could not be read.'**
  String get importReadFailed;

  /// Error when the picked file is not a Bitwarden JSON export.
  ///
  /// In en, this message translates to:
  /// **'This file is not a JSON export from Bitwarden.'**
  String get importNotBitwarden;

  /// Error when the picked Bitwarden export is restricted to its Bitwarden account, with how to get one Submarine opens. ".json" is the name of the format in Bitwarden.
  ///
  /// In en, this message translates to:
  /// **'This export is restricted to your Bitwarden account, and only Bitwarden opens it. Export your vault from Bitwarden again, password protected or in the .json format.'**
  String get importEncrypted;

  /// Error when the picked Bitwarden export holds no items.
  ///
  /// In en, this message translates to:
  /// **'This export has no items.'**
  String get importEmpty;

  /// What the picked export holds, before importing it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item found in {file}.} other{{count} items found in {file}.}}'**
  String importFound(int count, String file);

  /// Shown while importing.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} items imported'**
  String importProgress(int done, int total);

  /// Shown once the import is done.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item imported into {vault}.} other{{count} items imported into {vault}.}}'**
  String importDone(int count, String vault);

  /// Shown when saving an item failed during the import. The items saved before stay in the vault.
  ///
  /// In en, this message translates to:
  /// **'The import stopped: {done} of {total} items were saved.'**
  String importFailed(int done, int total);

  /// Settings row, and title of the dialog exporting a vault.
  ///
  /// In en, this message translates to:
  /// **'Export a vault'**
  String get exportVault;

  /// Explains the export row.
  ///
  /// In en, this message translates to:
  /// **'A Bitwarden JSON file, protected by a password or not encrypted.'**
  String get exportVaultDescription;

  /// Button exporting a vault to a file.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// How many items the export holds, in the export dialog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{This vault has no items to export.} =1{1 item. The trash is left out.} other{{count} items. The trash is left out.}}'**
  String exportCount(int count);

  /// Warning of the export dialog.
  ///
  /// In en, this message translates to:
  /// **'The file is not encrypted. Do not send it by email, and delete it once you are done with it.'**
  String get exportWarning;

  /// Error when writing the export file failed.
  ///
  /// In en, this message translates to:
  /// **'The file could not be saved.'**
  String get exportFailed;

  /// Shown when the picked Bitwarden export is password protected.
  ///
  /// In en, this message translates to:
  /// **'This export is protected by a password. Enter it to open the file.'**
  String get importPasswordBody;

  /// Field of the password protecting an export file, as Bitwarden names it.
  ///
  /// In en, this message translates to:
  /// **'File password'**
  String get filePassword;

  /// Error when the password does not decrypt the export.
  ///
  /// In en, this message translates to:
  /// **'This password does not open the file.'**
  String get wrongFilePassword;

  /// Switch of the export dialog: on, the file is encrypted with a password.
  ///
  /// In en, this message translates to:
  /// **'Protect with a password'**
  String get exportProtect;

  /// Second field of the file password, to catch a typo.
  ///
  /// In en, this message translates to:
  /// **'Confirm the file password'**
  String get confirmFilePassword;

  /// Under the file password fields of the export dialog.
  ///
  /// In en, this message translates to:
  /// **'Submarine and Bitwarden ask for it to import the file. It cannot be recovered.'**
  String get filePasswordHelper;

  /// Error when the file password is empty.
  ///
  /// In en, this message translates to:
  /// **'Choose a password.'**
  String get filePasswordRequired;

  /// Error when the confirmation differs from the file password.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get filePasswordMismatch;

  /// Setting of the password that encrypts the vault keys on this device and unlocks the app.
  ///
  /// In en, this message translates to:
  /// **'Lock password'**
  String get lockPassword;

  /// Explains the lock password setting.
  ///
  /// In en, this message translates to:
  /// **'Encrypts the vault keys on this device, and unlocks the app. It cannot be recovered.'**
  String get lockPasswordDescription;

  /// Button of the settings opening the dialog that sets the lock password.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get setLockPassword;

  /// Button of the settings opening the dialog that changes the lock password.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLockPassword;

  /// Button of the settings opening the dialog that removes the lock password, and button confirming it.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLockPassword;

  /// Title of the dialog setting the lock password.
  ///
  /// In en, this message translates to:
  /// **'Set a lock password'**
  String get setLockPasswordTitle;

  /// Title of the dialog changing the lock password.
  ///
  /// In en, this message translates to:
  /// **'Change the lock password'**
  String get changeLockPasswordTitle;

  /// Title of the dialog removing the lock password.
  ///
  /// In en, this message translates to:
  /// **'Remove the lock password'**
  String get removeLockPasswordTitle;

  /// Explains what removing the lock password does.
  ///
  /// In en, this message translates to:
  /// **'The app no longer asks for it. The vault keys on this device then rest on its secure storage only.'**
  String get removeLockPasswordBody;

  /// Field of the lock password in use, asked before changing or removing it.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentLockPassword;

  /// Field of the lock password replacing the current one.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newLockPassword;

  /// Second field of a new lock password, to catch a typo.
  ///
  /// In en, this message translates to:
  /// **'Confirm the password'**
  String get confirmLockPassword;

  /// Under the fields of a new lock password.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters. Forgetting it removes the vaults from this device.'**
  String lockPasswordHelper(int count);

  /// Error when a new lock password is too short.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters.'**
  String lockPasswordTooShort(int count);

  /// Error when the confirmation differs from the new lock password.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get lockPasswordMismatch;

  /// Error when the typed password does not open the key of the device.
  ///
  /// In en, this message translates to:
  /// **'This is not the lock password.'**
  String get wrongLockPassword;

  /// Button filling the new lock password with a generated passphrase, shown in clear.
  ///
  /// In en, this message translates to:
  /// **'Generate a passphrase'**
  String get generatePassphrase;

  /// Explains the biometrics switch while a lock password is set.
  ///
  /// In en, this message translates to:
  /// **'Instead of typing the lock password, which keeps working.'**
  String get unlockWithBiometricsWithPassword;

  /// Button of the lock screen for a forgotten lock password.
  ///
  /// In en, this message translates to:
  /// **'Forgot the password?'**
  String get forgotLockPassword;

  /// Title of the dialog confirming that a forgotten lock password removes the vaults from the device.
  ///
  /// In en, this message translates to:
  /// **'Remove the vaults from this device?'**
  String get forgetVaultsTitle;

  /// Body of the dialog confirming that a forgotten lock password removes the vaults.
  ///
  /// In en, this message translates to:
  /// **'Without the lock password, they cannot be decrypted here. Your items stay on the relays: open each vault again with its key or its signer.'**
  String get forgetVaultsBody;

  /// Button confirming that the vaults leave the device, for a forgotten lock password.
  ///
  /// In en, this message translates to:
  /// **'Remove the vaults'**
  String get forgetVaults;
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
