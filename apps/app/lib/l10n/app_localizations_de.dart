// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get allVaults => 'Alle Tresore';

  @override
  String get vaults => 'Tresore';

  @override
  String get addVault => 'Tresor hinzufügen';

  @override
  String get createVault => 'Tresor erstellen';

  @override
  String get createVaultDescription =>
      'Ein neuer, leerer Tresor mit eigenem Schlüssel.';

  @override
  String get openVault => 'Tresor öffnen';

  @override
  String get openVaultDescription =>
      'Von einem anderen Gerät oder mit dir geteilt.';

  @override
  String get openVaultTitle => 'Tresor öffnen';

  @override
  String get vaultName => 'Name';

  @override
  String get vaultNameHelper =>
      'Nur auf diesem Gerät. Personen, mit denen du den Tresor teilst, benennen ihn selbst.';

  @override
  String get vaultNameRequired => 'Gib dem Tresor einen Namen.';

  @override
  String get vaultColor => 'Farbe';

  @override
  String vaultColorOption(int number) {
    return 'Farbe $number';
  }

  @override
  String get vaultKey => 'Tresorschlüssel';

  @override
  String get vaultKeyInvalid => 'Das ist kein Tresorschlüssel.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Dieser Tresor ist bereits als $name geöffnet.';
  }

  @override
  String get vaultSaveFailed =>
      'Der Tresor konnte nicht auf diesem Gerät gespeichert werden.';

  @override
  String get saveVaultKeyTitle => 'Tresorschlüssel sichern';

  @override
  String get saveVaultKeyBody =>
      'Wer diesen Schlüssel hat, kann den Tresor öffnen. Bewahre ihn sicher auf: Du brauchst ihn, um den Tresor auf einem anderen Gerät zu öffnen oder ihn zu teilen.';

  @override
  String get vaultSettings => 'Tresoreinstellungen';

  @override
  String get vaultNameAndColor => 'Name und Farbe';

  @override
  String get vaultPublicKey => 'Öffentlicher Schlüssel';

  @override
  String get vaultKeyDescription =>
      'Wer ihn hat, kann diesen Tresor öffnen. Gib ihn auf einem anderen Gerät ein, um den Tresor dort zu öffnen, oder teile den Tresor, indem du jemandem den Schlüssel gibst.';

  @override
  String get vaultKeyHelper =>
      'Der Schlüssel, den du beim Erstellen des Tresors gesichert hast oder der mit dir geteilt wurde.';

  @override
  String get vaultKeyPassword => 'Schlüsselpasswort';

  @override
  String get vaultKeyPasswordWrong =>
      'Dieses Passwort passt nicht zum Schlüssel.';

  @override
  String get vaultKeyDecrypting => 'Schlüssel wird entschlüsselt';

  @override
  String get otherWaysToOpen => 'Weitere Möglichkeiten zum Öffnen';

  @override
  String get signersDescription =>
      'Mit einem Signierer, der den Schlüssel außerhalb von Submarine verwahrt. Eine bunker://-Adresse kannst du auch ins Schlüsselfeld eingeben.';

  @override
  String get browserExtension => 'Browser-Erweiterung';

  @override
  String get signerApp => 'Signier-App';

  @override
  String get bunker => 'Bunker';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Scanne diesen Code mit deinem Bunker oder deiner Signier-App oder füge dort die Adresse ein.';

  @override
  String get noBrowserExtension => 'Keine Nostr-Erweiterung in diesem Browser.';

  @override
  String get noSignerApp => 'Keine Signier-App wie Amber auf diesem Gerät.';

  @override
  String get signerRefused => 'Die Anfrage wurde abgelehnt.';

  @override
  String get waitingForAnswer => 'Warten auf Antwort';

  @override
  String get bunkerUrlInvalid =>
      'Dieser Bunker-Adresse fehlt ein Relay oder ein Secret.';

  @override
  String get bunkerNoAnswer => 'Der Bunker hat nicht geantwortet.';

  @override
  String get bunkerApproval =>
      'Der Bunker bittet dich, Submarine auf seiner Seite zu genehmigen.';

  @override
  String get openApprovalPage => 'Seite öffnen';

  @override
  String get nothingConnected => 'Es hat sich nichts rechtzeitig verbunden.';

  @override
  String get useAnotherKey => 'Anderen Schlüssel verwenden';

  @override
  String get vaultSignerDescription =>
      'Verwahrt den Tresorschlüssel, der nie an Submarine übergeben wird. Öffne den Tresor auf einem anderen Gerät auf dieselbe Weise.';

  @override
  String get askSignerAtStart => 'Signierer bei jedem Start fragen';

  @override
  String get askSignerAtStartDescription =>
      'Aus: Ein auf diesem Gerät gespeicherter Schlüssel liest den Tresor, auch wenn der Signierer nicht erreichbar ist. An: Der Tresor bleibt geschlossen, bis der Signierer ihn öffnet.';

  @override
  String get askSignerFailed =>
      'Der Signierer hat abgelehnt oder es gab einen Fehler.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Anfragen warten auf deinen Signierer',
      one: '1 Anfrage wartet auf deinen Signierer',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'Warten auf deinen Signierer';

  @override
  String get signerRequestsDescription =>
      'Bestätige diese Anfragen in deinem Signierer oder brich sie ab.';

  @override
  String get requestOpenVault => 'Tresor öffnen';

  @override
  String get requestLockVault => 'Tresor mit dem Signierer verschließen';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Versionen von Einträgen entschlüsseln',
      one: 'Eine Version eines Eintrags entschlüsseln',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Versionen von Einträgen speichern',
      one: 'Eine Version eines Eintrags speichern',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Versionen von Einträgen dauerhaft löschen',
      one: 'Eine Version eines Eintrags dauerhaft löschen',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Relay-Liste speichern';

  @override
  String get requestReadRelays => 'Private Relays lesen';

  @override
  String get requestEncryptRelays => 'Private Relays verschlüsseln';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bei $count Relays anmelden',
      one: 'Bei einem Relay anmelden',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count andere Anfragen ($method)',
      one: 'Andere Anfrage ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Alle abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get sync => 'Synchronisierung';

  @override
  String get syncAllSent => 'Alle Änderungen sind online gespeichert.';

  @override
  String get relays => 'Relays';

  @override
  String get relaysDescription =>
      'Dieser Tresor wird auf jedes dieser Relays kopiert. Sie sehen nur verschlüsselte Daten und seinen öffentlichen Schlüssel.';

  @override
  String get relayConnected => 'Verbunden';

  @override
  String get relayNotConnected => 'Nicht verbunden';

  @override
  String get relayPrivate => 'Privat';

  @override
  String get removeRelay => 'Dieses Relay entfernen';

  @override
  String get addRelay => 'Relay hinzufügen';

  @override
  String get relayAddress => 'Relay-Adresse';

  @override
  String get relayAddressInvalid => 'Das ist keine Relay-Adresse.';

  @override
  String get relayAlreadyListed => 'Dieses Relay ist bereits in der Liste.';

  @override
  String get relayKeepPrivate => 'Privat halten';

  @override
  String get relayKeepPrivateDescription =>
      'Verschlüsselt in der Relay-Liste des Tresors: Nur wer den Tresorschlüssel hat, weiß, dass der Tresor auf diesem Relay liegt.';

  @override
  String get relaysSaveFailed => 'Die Relays konnten nicht gespeichert werden.';

  @override
  String get relaysWaitForSync =>
      'Du kannst die Relays ändern, sobald der Tresor synchronisiert ist.';

  @override
  String get relayAdded => 'Neu';

  @override
  String get relayRemoved => 'Entfernt';

  @override
  String get keepRelay => 'Relay behalten';

  @override
  String get relaysNeedOne => 'Der Tresor braucht mindestens ein Relay.';

  @override
  String get fileServers => 'Dateiserver';

  @override
  String get fileServersDescription =>
      'Die an diesen Tresor angehängten Dateien werden auf jeden dieser Server kopiert. Sie sehen nur verschlüsselte Dateien.';

  @override
  String get serverPrivate => 'Privat';

  @override
  String get removeServer => 'Diesen Server entfernen';

  @override
  String get keepServer => 'Server behalten';

  @override
  String get addServer => 'Server hinzufügen';

  @override
  String get serverAddress => 'Server-Adresse';

  @override
  String get serverAddressInvalid => 'Das ist keine Server-Adresse.';

  @override
  String get serverAlreadyListed => 'Dieser Server ist bereits in der Liste.';

  @override
  String get serverKeepPrivate => 'Privat halten';

  @override
  String get serverKeepPrivateDescription =>
      'Verschlüsselt in der Serverliste des Tresors: Nur wer den Tresorschlüssel hat, weiß, dass der Tresor diesen Server nutzt.';

  @override
  String get serversSaveFailed =>
      'Die Server konnten nicht gespeichert werden.';

  @override
  String get serversWaitForSync =>
      'Du kannst die Server ändern, sobald der Tresor synchronisiert ist.';

  @override
  String get serverAdded => 'Neu';

  @override
  String get serverRemoved => 'Entfernt';

  @override
  String get serversNeedOne => 'Der Tresor braucht mindestens einen Server.';

  @override
  String get add => 'Hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get open => 'Öffnen';

  @override
  String get done => 'Fertig';

  @override
  String get welcomeTagline =>
      'Deine Passwörter, verschlüsselt und synchronisiert. Ganz ohne Konto.';

  @override
  String get builtOnNostr => 'Basiert auf Nostr';

  @override
  String get builtOnNostrBody =>
      'Deine Tresore liegen auf Nostr-Relays: offenen Servern, die jeder betreiben kann und die nur verschlüsselte Daten sehen. Ein Tresorschlüssel ist ein Nostr-Schlüssel, daher kann ein Nostr-Signierer ihn verwahren.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
      zero: 'Keine Einträge',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get syncing => 'Wird synchronisiert';

  @override
  String get syncNever => 'Nie synchronisiert';

  @override
  String get syncFailed => 'Synchronisierung fehlgeschlagen';

  @override
  String get signerDidNotOpen => 'Der Signierer hat den Tresor nicht geöffnet';

  @override
  String get syncedJustNow => 'Gerade synchronisiert';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Vor $minutes Min. synchronisiert';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Vor $hours Std. synchronisiert';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Am $dateString synchronisiert';
  }

  @override
  String get noItems => 'Noch keine Einträge in diesem Tresor.';

  @override
  String get lookingForItems => 'Suche nach deinen Einträgen';

  @override
  String get signerDidNotOpenVault =>
      'Der Signierer hat diesen Tresor nicht geöffnet. Synchronisiere, um ihn erneut zu fragen.';

  @override
  String get selectItem => 'Wähle einen Eintrag aus, um ihn hier zu sehen.';

  @override
  String get itemNotFound => 'Dieser Eintrag ist nicht mehr im Tresor.';

  @override
  String get typeLogin => 'Zugangsdaten';

  @override
  String get typeSecureNote => 'Sichere Notiz';

  @override
  String get typeCard => 'Karte';

  @override
  String get typeIdentity => 'Identität';

  @override
  String get typeSshKey => 'SSH-Schlüssel';

  @override
  String get typeBankAccount => 'Bankkonto';

  @override
  String get typeDriversLicense => 'Führerschein';

  @override
  String get typePassport => 'Reisepass';

  @override
  String get typeUnknown => 'Eintrag';

  @override
  String get copy => 'Kopieren';

  @override
  String get copied => 'Kopiert';

  @override
  String get show => 'Anzeigen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get hiddenValue => 'Verborgener Wert';

  @override
  String get openWebsite => 'Website öffnen';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get verificationCode => 'Verifizierungscode';

  @override
  String get totpInvalid =>
      'Dieser Authenticator-Schlüssel kann nicht gelesen werden.';

  @override
  String get website => 'Website';

  @override
  String get passkey => 'Passkey';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Erstellt am $dateString';
  }

  @override
  String get notes => 'Notizen';

  @override
  String get customFields => 'Benutzerdefinierte Felder';

  @override
  String get passwordHistory => 'Passwortverlauf';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Geändert am $updatedString, erstellt am $createdString';
  }

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String linkedTo(String field) {
    return 'Verknüpft mit $field';
  }

  @override
  String get cardholderName => 'Name des Karteninhabers';

  @override
  String get cardBrand => 'Marke';

  @override
  String get cardNumber => 'Nummer';

  @override
  String get cardExpiration => 'Ablaufdatum';

  @override
  String get cardExpMonth => 'Ablaufmonat';

  @override
  String get cardExpYear => 'Ablaufjahr';

  @override
  String get cardCode => 'Sicherheitscode';

  @override
  String get fullName => 'Name';

  @override
  String get identityTitle => 'Anrede';

  @override
  String get firstName => 'Vorname';

  @override
  String get middleName => 'Zweiter Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get company => 'Firma';

  @override
  String get email => 'E-Mail';

  @override
  String get phone => 'Telefon';

  @override
  String get address => 'Adresse';

  @override
  String get city => 'Stadt';

  @override
  String get state => 'Bundesland oder Region';

  @override
  String get postalCode => 'Postleitzahl';

  @override
  String get country => 'Land';

  @override
  String get ssn => 'Sozialversicherungsnummer';

  @override
  String get passportNumber => 'Reisepassnummer';

  @override
  String get licenseNumber => 'Führerscheinnummer';

  @override
  String get privateKey => 'Privater Schlüssel';

  @override
  String get publicKey => 'Öffentlicher Schlüssel';

  @override
  String get fingerprint => 'Fingerabdruck';

  @override
  String get bankName => 'Bank';

  @override
  String get accountHolder => 'Kontoinhaber';

  @override
  String get accountType => 'Kontoart';

  @override
  String get accountNumber => 'Kontonummer';

  @override
  String get routingNumber => 'Bankleitzahl';

  @override
  String get branchNumber => 'Filialnummer';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'SWIFT-Code';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Telefon der Bank';

  @override
  String get accountTypeChecking => 'Girokonto';

  @override
  String get accountTypeSavings => 'Sparkonto';

  @override
  String get accountTypeCertificateOfDeposit => 'Festgeldkonto';

  @override
  String get accountTypeLineOfCredit => 'Kreditrahmen';

  @override
  String get accountTypeInvestmentBrokerage => 'Wertpapierdepot';

  @override
  String get accountTypeMoneyMarket => 'Geldmarktkonto';

  @override
  String get accountTypeOther => 'Sonstige';

  @override
  String get dateOfBirth => 'Geburtsdatum';

  @override
  String get issuingCountry => 'Ausstellendes Land';

  @override
  String get issuingState => 'Ausstellendes Bundesland';

  @override
  String get issueDate => 'Ausstellungsdatum';

  @override
  String get expirationDate => 'Ablaufdatum';

  @override
  String get issuingAuthority => 'Ausstellende Behörde';

  @override
  String get licenseClass => 'Klasse';

  @override
  String get surname => 'Nachname';

  @override
  String get givenName => 'Vorname';

  @override
  String get sex => 'Geschlecht';

  @override
  String get birthPlace => 'Geburtsort';

  @override
  String get nationality => 'Staatsangehörigkeit';

  @override
  String get passportType => 'Typ';

  @override
  String get nationalId => 'Nationale Identifikationsnummer';

  @override
  String get filterAllItems => 'Alle Einträge';

  @override
  String get filterAllShort => 'Alle';

  @override
  String get filterFavorites => 'Favoriten';

  @override
  String get filterLogins => 'Zugangsdaten';

  @override
  String get filterSecureNotes => 'Sichere Notizen';

  @override
  String get filterCards => 'Karten';

  @override
  String get filterIdentities => 'Identitäten';

  @override
  String get filterSshKeys => 'SSH-Schlüssel';

  @override
  String get filterBankAccounts => 'Bankkonten';

  @override
  String get filterDriversLicenses => 'Führerscheine';

  @override
  String get filterPassports => 'Reisepässe';

  @override
  String get filterTrash => 'Papierkorb';

  @override
  String get noItemsHere => 'Hier gibt es keine Einträge.';

  @override
  String get searchItems => 'Suchen';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get noSearchResults => 'Keine Einträge passen zu deiner Suche.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen noch nicht gesendet',
      one: '1 Änderung noch nicht gesendet',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Neuer Eintrag';

  @override
  String get newLogin => 'Neue Zugangsdaten';

  @override
  String get newCard => 'Neue Karte';

  @override
  String get newSecureNote => 'Neue sichere Notiz';

  @override
  String get editItem => 'Eintrag bearbeiten';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get itemSaveFailed => 'Der Eintrag konnte nicht gespeichert werden.';

  @override
  String get vault => 'Tresor';

  @override
  String get itemName => 'Name';

  @override
  String get itemNameRequired => 'Gib dem Eintrag einen Namen.';

  @override
  String get authenticatorKey => 'Authenticator-Schlüssel';

  @override
  String get authenticatorKeyHint => 'Base32-Secret oder otpauth://-URI';

  @override
  String get addWebsite => 'Website hinzufügen';

  @override
  String get addField => 'Feld hinzufügen';

  @override
  String get customField => 'Benutzerdefiniertes Feld';

  @override
  String get editField => 'Feld bearbeiten';

  @override
  String get fieldType => 'Feldtyp';

  @override
  String get fieldTypeText => 'Text';

  @override
  String get fieldTypeHidden => 'Versteckt';

  @override
  String get fieldTypeCheckbox => 'Kontrollkästchen';

  @override
  String get fieldTypeLinked => 'Verknüpft';

  @override
  String get textFieldHelp =>
      'Verwende Textfelder für Daten wie Sicherheitsfragen.';

  @override
  String get hiddenFieldHelp =>
      'Verwende versteckte Felder für vertrauliche Daten wie ein Passwort.';

  @override
  String get checkboxFieldHelp =>
      'Verwende Kontrollkästchen, um Kontrollkästchen in Formularen auszufüllen, etwa E-Mail merken.';

  @override
  String get linkedFieldHelp =>
      'Verwende ein verknüpftes Feld, wenn das automatische Ausfüllen bei einer bestimmten Website Probleme macht.';

  @override
  String get fieldLabel => 'Feldbezeichnung';

  @override
  String get linkedFieldLabelHelp =>
      'Gib die HTML-ID, den Namen, das aria-label oder den Platzhalter des Felds ein.';

  @override
  String editFieldNamed(String field) {
    return '$field bearbeiten';
  }

  @override
  String deleteFieldNamed(String field) {
    return '$field löschen';
  }

  @override
  String reorderField(String field) {
    return '$field verschieben';
  }

  @override
  String get cardBrandOther => 'Sonstige';

  @override
  String get cardExpYearHint => 'JJJJ';

  @override
  String get notSet => 'Keine Angabe';

  @override
  String get favorite => 'Favorit';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get discardChanges => 'Änderungen verwerfen?';

  @override
  String get keepEditing => 'Weiter bearbeiten';

  @override
  String get discard => 'Verwerfen';

  @override
  String get moreActions => 'Weitere Aktionen';

  @override
  String get copyUsername => 'Benutzernamen kopieren';

  @override
  String get copyPassword => 'Passwort kopieren';

  @override
  String get copyTotp => 'Verifizierungscode kopieren';

  @override
  String get copyNumber => 'Nummer kopieren';

  @override
  String get moveToTrash => 'In den Papierkorb verschieben';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get deletePermanently => 'Dauerhaft löschen';

  @override
  String get deleteItemTitle => 'Diesen Eintrag dauerhaft löschen?';

  @override
  String get deleteItemBody =>
      'Er wird auf allen Geräten aus dem Tresor gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get delete => 'Löschen';

  @override
  String get generatePassword => 'Passwort generieren';

  @override
  String get generateUsername => 'Benutzernamen generieren';

  @override
  String get generator => 'Generator';

  @override
  String get passphrase => 'Passphrase';

  @override
  String get regenerate => 'Neu generieren';

  @override
  String get passwordLength => 'Länge';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeichen',
      one: '1 Zeichen',
    );
    return '$_temp0';
  }

  @override
  String get includeCharacters => 'Einschließen';

  @override
  String get uppercaseLetters => 'Großbuchstaben';

  @override
  String get lowercaseLetters => 'Kleinbuchstaben';

  @override
  String get digits => 'Ziffern';

  @override
  String get specialCharacters => 'Sonderzeichen';

  @override
  String get minNumbers => 'Mindestanzahl Ziffern';

  @override
  String get minSpecial => 'Mindestanzahl Sonderzeichen';

  @override
  String get avoidAmbiguous => 'Mehrdeutige Zeichen vermeiden';

  @override
  String get numberOfWords => 'Anzahl der Wörter';

  @override
  String get wordSeparator => 'Worttrennzeichen';

  @override
  String get capitalize => 'Wörter großschreiben';

  @override
  String get includeNumber => 'Ziffer einschließen';

  @override
  String get usePassword => 'Dieses Passwort verwenden';

  @override
  String get usePassphrase => 'Diese Passphrase verwenden';

  @override
  String get useUsername => 'Diesen Benutzernamen verwenden';

  @override
  String get usernameCapitalize => 'Großer Anfangsbuchstabe';

  @override
  String get usernameIncludeNumber => 'Zahl anhängen';

  @override
  String get decrease => 'Verringern';

  @override
  String get increase => 'Erhöhen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get security => 'Sicherheit';

  @override
  String get unlockWithBiometrics => 'Mit Biometrie entsperren';

  @override
  String get unlockWithBiometricsDescription =>
      'Oder mit dem Code oder Passwort dieses Geräts. Die Tresorschlüssel bleiben in seinem sicheren Speicher.';

  @override
  String get lockNeedsScreenLock =>
      'Richte zuerst eine Bildschirmsperre auf diesem Gerät ein.';

  @override
  String get lockAfter => 'Sperren nach';

  @override
  String get lockImmediately => 'Sofort';

  @override
  String get lockOnRestart => 'Beim Neustart der App';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'Kopierte Passwörter löschen nach';

  @override
  String get never => 'Nie';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sekunden',
      one: '1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Bildschirmaufnahmen erlauben';

  @override
  String get allowScreenCaptureDescription =>
      'Screenshots, Aufnahmen und Bildschirmfreigaben können dann deine Passwörter zeigen.';

  @override
  String get lock => 'Sperren';

  @override
  String lockWithShortcut(String shortcut) {
    return 'Sperren ($shortcut)';
  }

  @override
  String get unlock => 'Entsperren';

  @override
  String get vaultsLocked => 'Deine Tresore sind gesperrt.';

  @override
  String get unlockReason => 'Deine Tresore entsperren';

  @override
  String get enableLockReason => 'Sperre aktivieren';

  @override
  String get authLockedOut => 'Zu viele Versuche. Versuche es später erneut.';

  @override
  String get authFailed =>
      'Dieses Gerät konnte nicht bestätigen, dass du es bist.';

  @override
  String get vaultTab => 'Tresor';

  @override
  String get storageReadFailed => 'Deine Tresore konnten nicht gelesen werden.';

  @override
  String get storageReadFailedBody =>
      'Der sichere Speicher dieses Geräts hat sich geweigert, sie zu öffnen. Es wurde nichts gelöscht: Versuche es erneut. Deine Einträge bleiben online, und jeder Tresor lässt sich mit seinem Schlüssel auf jedem Gerät öffnen.';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get appearance => 'Darstellung';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageName => 'Deutsch';

  @override
  String get theme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get importExport => 'Import und Export';

  @override
  String get importFromBitwarden => 'Aus Bitwarden importieren';

  @override
  String get importFromBitwardenDescription => 'Ein JSON-Export aus Bitwarden.';

  @override
  String get importButton => 'Importieren';

  @override
  String get importReadFailed => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get importNotBitwarden =>
      'Diese Datei ist kein JSON-Export aus Bitwarden.';

  @override
  String get importEncrypted =>
      'Dieser Export ist auf dein Bitwarden-Konto beschränkt, und nur Bitwarden kann ihn öffnen. Exportiere deinen Tresor erneut aus Bitwarden, passwortgeschützt oder im Format .json.';

  @override
  String get importEmpty => 'Dieser Export enthält keine Einträge.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge in $file gefunden.',
      one: '1 Eintrag in $file gefunden.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done von $total Einträgen importiert';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge in $vault importiert.',
      one: '1 Eintrag in $vault importiert.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'Der Import wurde abgebrochen: $done von $total Einträgen wurden gespeichert.';
  }

  @override
  String get exportVault => 'Tresor exportieren';

  @override
  String get exportVaultDescription =>
      'Eine Bitwarden-JSON-Datei, passwortgeschützt oder unverschlüsselt.';

  @override
  String get exportButton => 'Exportieren';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge. Der Papierkorb wird nicht exportiert.',
      one: '1 Eintrag. Der Papierkorb wird nicht exportiert.',
      zero: 'Dieser Tresor hat keine Einträge zum Exportieren.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'Die Datei ist nicht verschlüsselt. Versende sie nicht per E-Mail und lösche sie, sobald du sie nicht mehr brauchst.';

  @override
  String get exportFailed => 'Die Datei konnte nicht gespeichert werden.';

  @override
  String get importPasswordBody =>
      'Dieser Export ist passwortgeschützt. Gib das Passwort ein, um die Datei zu öffnen.';

  @override
  String get filePassword => 'Dateipasswort';

  @override
  String get wrongFilePassword => 'Dieses Passwort passt nicht zur Datei.';

  @override
  String get exportProtect => 'Mit Passwort schützen';

  @override
  String get confirmFilePassword => 'Dateipasswort bestätigen';

  @override
  String get filePasswordHelper =>
      'Submarine und Bitwarden fragen beim Import danach. Es kann nicht wiederhergestellt werden.';

  @override
  String get filePasswordRequired => 'Wähle ein Passwort.';

  @override
  String get filePasswordMismatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get lockPassword => 'Sperrpasswort';

  @override
  String get lockPasswordDescription =>
      'Verschlüsselt die Tresorschlüssel auf diesem Gerät und entsperrt die App. Es kann nicht wiederhergestellt werden.';

  @override
  String get setLockPassword => 'Festlegen';

  @override
  String get changeLockPassword => 'Ändern';

  @override
  String get removeLockPassword => 'Entfernen';

  @override
  String get setLockPasswordTitle => 'Sperrpasswort festlegen';

  @override
  String get changeLockPasswordTitle => 'Sperrpasswort ändern';

  @override
  String get removeLockPasswordTitle => 'Sperrpasswort entfernen';

  @override
  String get removeLockPasswordBody =>
      'Die App fragt nicht mehr danach. Die Tresorschlüssel auf diesem Gerät sind dann nur noch durch seinen sicheren Speicher geschützt.';

  @override
  String get currentLockPassword => 'Aktuelles Passwort';

  @override
  String get newLockPassword => 'Neues Passwort';

  @override
  String get confirmLockPassword => 'Passwort bestätigen';

  @override
  String lockPasswordHelper(int count) {
    return 'Mindestens $count Zeichen. Wenn du es vergisst, werden die Tresore von diesem Gerät entfernt.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Mindestens $count Zeichen.';
  }

  @override
  String get lockPasswordMismatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get wrongLockPassword => 'Das ist nicht das Sperrpasswort.';

  @override
  String get generatePassphrase => 'Passphrase generieren';

  @override
  String get unlockWithBiometricsWithPassword =>
      'Statt das Sperrpasswort einzugeben, das weiterhin funktioniert.';

  @override
  String get forgotLockPassword => 'Passwort vergessen?';

  @override
  String get forgetVaultsTitle => 'Tresore von diesem Gerät entfernen?';

  @override
  String get forgetVaultsBody =>
      'Ohne das Sperrpasswort können sie hier nicht entschlüsselt werden. Deine Einträge bleiben online: Öffne jeden Tresor erneut mit seinem Schlüssel.';

  @override
  String get forgetVaults => 'Tresore entfernen';

  @override
  String get removeVault => 'Von diesem Gerät entfernen';

  @override
  String get removeVaultDescription =>
      'Der Tresor bleibt online, damit du ihn wieder öffnen kannst.';

  @override
  String removeVaultTitle(String name) {
    return '$name von diesem Gerät entfernen?';
  }

  @override
  String get removeVaultBody =>
      'Deine Einträge bleiben online: Öffne den Tresor erneut, um sie wiederzufinden.';

  @override
  String get removeVaultKeyWarning =>
      'Sichere zuerst den Tresorschlüssel: Ohne ihn kannst du den Tresor nicht wieder öffnen.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen sind noch nicht gesendet und gehen verloren.',
      one: '1 Änderung ist noch nicht gesendet und geht verloren.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Entfernen';

  @override
  String get removeVaultFailed => 'Der Tresor konnte nicht entfernt werden.';

  @override
  String get emailSettings => 'E-Mail';

  @override
  String get mailBridge => 'E-Mail-Bridge';

  @override
  String mailBridgeDescription(String domain) {
    return 'Neue E-Mail-Adressen enden auf @$domain';
  }

  @override
  String get changeMailBridge => 'Ändern';

  @override
  String get mailBridgeDomain => 'Domain';

  @override
  String get mailBridgeExplanation =>
      'Ab jetzt erstellte E-Mail-Adressen enden auf diese Domain. Bereits erstellte behalten ihre.';

  @override
  String get mailBridgeInvalid => 'Das ist keine Domain.';

  @override
  String get emailAddressField => 'E-Mail-Adresse';

  @override
  String get mailboxKey => 'Postfachschlüssel';

  @override
  String get inbox => 'Posteingang';

  @override
  String get inboxFetching => 'Nachrichten werden abgerufen';

  @override
  String get inboxEmpty => 'Noch keine Nachrichten';

  @override
  String get noSubject => '(kein Betreff)';

  @override
  String get privateMessage => 'Private Nachricht';

  @override
  String get emailDownloadFailed =>
      'Diese E-Mail konnte nicht heruntergeladen werden.';

  @override
  String get refreshInbox => 'Aktualisieren';

  @override
  String get mailInboxRelays => 'Empfangs-Relays';

  @override
  String get mailInboxRelaysExplanation =>
      'E-Mails an neue Adressen kommen auf diesen Relays an. Bereits erstellte Adressen behalten ihre.';

  @override
  String get mailAddressRelays => 'Adress-Relays';

  @override
  String get mailAddressRelaysExplanation =>
      'Neue Adressen veröffentlichen ihre Empfangs-Relays auf diesen Relays, wo die Bridge sie findet. Bereits erstellte Adressen behalten ihre.';

  @override
  String get changeMailRelays => 'Ändern';

  @override
  String get mailRelaysNeedOne =>
      'Neue Adressen brauchen mindestens ein Relay.';

  @override
  String get resetMailRelays => 'Zurücksetzen';
}
