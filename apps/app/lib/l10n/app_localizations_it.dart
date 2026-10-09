// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get allVaults => 'Tutte le casseforti';

  @override
  String get vaults => 'Casseforti';

  @override
  String get addVault => 'Aggiungi una cassaforte';

  @override
  String get createVault => 'Crea una cassaforte';

  @override
  String get createVaultDescription =>
      'Una nuova cassaforte vuota, con la sua chiave.';

  @override
  String get openVault => 'Apri una cassaforte';

  @override
  String get openVaultDescription =>
      'Da un altro dispositivo, o condivisa con te.';

  @override
  String get openVaultTitle => 'Apri una cassaforte';

  @override
  String get vaultName => 'Nome';

  @override
  String get vaultNameHelper =>
      'Solo su questo dispositivo. Chi condivide con te la cassaforte la chiama a modo suo.';

  @override
  String get vaultNameRequired => 'Dai un nome alla cassaforte.';

  @override
  String get vaultColor => 'Colore';

  @override
  String vaultColorOption(int number) {
    return 'Colore $number';
  }

  @override
  String get vaultKey => 'Chiave della cassaforte';

  @override
  String get vaultKeyInvalid => 'Questa non è la chiave di una cassaforte.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Questa cassaforte è già aperta, con il nome $name.';
  }

  @override
  String get vaultSaveFailed =>
      'Impossibile salvare la cassaforte su questo dispositivo.';

  @override
  String get saveVaultKeyTitle => 'Conserva la chiave della cassaforte';

  @override
  String get saveVaultKeyBody =>
      'Chiunque abbia questa chiave può aprire la cassaforte. Conservala in un posto sicuro: ti servirà per aprire la cassaforte su un altro dispositivo o per condividerla.';

  @override
  String get vaultSettings => 'Impostazioni della cassaforte';

  @override
  String get vaultNameAndColor => 'Nome e colore';

  @override
  String get vaultPublicKey => 'Chiave pubblica';

  @override
  String get vaultKeyDescription =>
      'Chiunque la possieda può aprire questa cassaforte. Inseriscila su un altro dispositivo per aprire lì la cassaforte, oppure dalla alla persona con cui vuoi condividerla.';

  @override
  String get vaultKeyHelper =>
      'La chiave conservata alla creazione della cassaforte, o condivisa con te.';

  @override
  String get vaultKeyPassword => 'Password della chiave';

  @override
  String get vaultKeyPasswordWrong => 'Questa password non apre la chiave.';

  @override
  String get vaultKeyDecrypting => 'Decifratura della chiave';

  @override
  String get otherWaysToOpen => 'Altri modi per aprirla';

  @override
  String get signersDescription =>
      'Con un firmatario che tiene la chiave fuori da Submarine. Anche un indirizzo bunker:// va nel campo della chiave.';

  @override
  String get browserExtension => 'Estensione del browser';

  @override
  String get signerApp => 'App di firma';

  @override
  String get bunker => 'Firmatario remoto';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Scansiona questo codice con il tuo firmatario remoto o la tua app di firma, oppure incolla lì l\'indirizzo.';

  @override
  String get noBrowserExtension =>
      'Nessuna estensione Nostr in questo browser.';

  @override
  String get noSignerApp =>
      'Nessuna app di firma, come Amber, su questo dispositivo.';

  @override
  String get signerRefused => 'La richiesta è stata rifiutata.';

  @override
  String get waitingForAnswer => 'In attesa di una risposta';

  @override
  String get bunkerUrlInvalid =>
      'A questo indirizzo bunker manca un relay o un segreto.';

  @override
  String get bunkerNoAnswer => 'Il firmatario remoto non ha risposto.';

  @override
  String get bunkerApproval =>
      'Il firmatario remoto ti chiede di approvare Submarine sulla sua pagina.';

  @override
  String get openApprovalPage => 'Apri la pagina';

  @override
  String get nothingConnected => 'Nessuno si è connesso in tempo.';

  @override
  String get useAnotherKey => 'Usa un\'altra chiave';

  @override
  String get vaultSignerDescription =>
      'Custodisce la chiave della cassaforte, che non entra mai in Submarine. Su un altro dispositivo, apri la cassaforte allo stesso modo.';

  @override
  String get askSignerAtStart => 'Chiedi al firmatario a ogni avvio';

  @override
  String get askSignerAtStartDescription =>
      'Se disattivato, una chiave conservata su questo dispositivo legge la cassaforte anche quando il firmatario non è raggiungibile. Se attivato, la cassaforte resta chiusa finché il firmatario non la apre.';

  @override
  String get askSignerFailed =>
      'Il firmatario ha rifiutato o non ci è riuscito.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count richieste in attesa del tuo firmatario',
      one: '1 richiesta in attesa del tuo firmatario',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'In attesa del tuo firmatario';

  @override
  String get signerRequestsDescription =>
      'Approva queste richieste nel tuo firmatario, oppure annullale.';

  @override
  String get requestOpenVault => 'Apertura della cassaforte';

  @override
  String get requestLockVault =>
      'Blocco della cassaforte tramite il firmatario';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Decifratura di $count versioni di elementi',
      one: 'Decifratura di una versione di un elemento',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvataggio di $count versioni di elementi',
      one: 'Salvataggio di una versione di un elemento',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminazione definitiva di $count versioni di elementi',
      one: 'Eliminazione definitiva di una versione di un elemento',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Salvataggio dell\'elenco dei relay';

  @override
  String get requestReadRelays => 'Lettura dei relay privati';

  @override
  String get requestEncryptRelays => 'Cifratura dei relay privati';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Accesso a $count relay',
      one: 'Accesso a un relay',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count altre richieste ($method)',
      one: 'Altra richiesta ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Annulla tutto';

  @override
  String get close => 'Chiudi';

  @override
  String get sync => 'Sincronizzazione';

  @override
  String get syncAllSent => 'Tutte le modifiche sono salvate online.';

  @override
  String get relays => 'Relay';

  @override
  String get relaysDescription =>
      'Questa cassaforte è copiata su ciascuno di questi relay. Vedono solo dati cifrati e la sua chiave pubblica.';

  @override
  String get relayConnected => 'Connesso';

  @override
  String get relayNotConnected => 'Non connesso';

  @override
  String get relayPrivate => 'Privato';

  @override
  String get removeRelay => 'Rimuovi questo relay';

  @override
  String get addRelay => 'Aggiungi un relay';

  @override
  String get relayAddress => 'Indirizzo del relay';

  @override
  String get relayAddressInvalid => 'Questo non è l\'indirizzo di un relay.';

  @override
  String get relayAlreadyListed => 'Questo relay è già nell\'elenco.';

  @override
  String get relayKeepPrivate => 'Mantieni privato';

  @override
  String get relayKeepPrivateDescription =>
      'Cifrato nell\'elenco dei relay della cassaforte: solo chi ha la chiave della cassaforte sa che si trova su questo relay.';

  @override
  String get relaysSaveFailed => 'Impossibile salvare i relay.';

  @override
  String get relaysWaitForSync =>
      'Potrai modificare i relay una volta sincronizzata la cassaforte.';

  @override
  String get relayAdded => 'Nuovo';

  @override
  String get relayRemoved => 'Rimosso';

  @override
  String get keepRelay => 'Mantieni questo relay';

  @override
  String get relaysNeedOne => 'La cassaforte ha bisogno di almeno un relay.';

  @override
  String get add => 'Aggiungi';

  @override
  String get cancel => 'Annulla';

  @override
  String get create => 'Crea';

  @override
  String get open => 'Apri';

  @override
  String get done => 'Fine';

  @override
  String get welcomeTagline =>
      'Le tue password, cifrate e sincronizzate. Senza bisogno di un account.';

  @override
  String get builtOnNostr => 'Basato su Nostr';

  @override
  String get builtOnNostrBody =>
      'Le tue casseforti si trovano sui relay Nostr: server aperti che chiunque può gestire e che vedono solo dati cifrati. La chiave di una cassaforte è una chiave Nostr, quindi un firmatario Nostr può custodirla.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '1 elemento',
      zero: 'Nessun elemento',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String get syncing => 'Sincronizzazione in corso';

  @override
  String get syncNever => 'Mai sincronizzata';

  @override
  String get syncFailed => 'Sincronizzazione non riuscita';

  @override
  String get signerDidNotOpen => 'Il firmatario non ha aperto la cassaforte';

  @override
  String get syncedJustNow => 'Sincronizzata poco fa';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Sincronizzata $minutes min fa';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Sincronizzata $hours h fa';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Sincronizzata il $dateString';
  }

  @override
  String get noItems => 'Ancora nessun elemento in questa cassaforte.';

  @override
  String get lookingForItems => 'Ricerca dei tuoi elementi';

  @override
  String get signerDidNotOpenVault =>
      'Il firmatario non ha aperto questa cassaforte. Sincronizza per chiederglielo di nuovo.';

  @override
  String get selectItem => 'Seleziona un elemento per vederlo qui.';

  @override
  String get itemNotFound => 'Questo elemento non è più nella cassaforte.';

  @override
  String get typeLogin => 'Login';

  @override
  String get typeSecureNote => 'Nota sicura';

  @override
  String get typeCard => 'Carta';

  @override
  String get typeIdentity => 'Identità';

  @override
  String get typeSshKey => 'Chiave SSH';

  @override
  String get typeBankAccount => 'Conto bancario';

  @override
  String get typeDriversLicense => 'Patente di guida';

  @override
  String get typePassport => 'Passaporto';

  @override
  String get typeUnknown => 'Elemento';

  @override
  String get copy => 'Copia';

  @override
  String get copied => 'Copiato';

  @override
  String get show => 'Mostra';

  @override
  String get hide => 'Nascondi';

  @override
  String get hiddenValue => 'Valore nascosto';

  @override
  String get openWebsite => 'Apri il sito web';

  @override
  String get username => 'Nome utente';

  @override
  String get password => 'Password';

  @override
  String get verificationCode => 'Codice di verifica';

  @override
  String get totpInvalid => 'Impossibile leggere questa chiave di verifica.';

  @override
  String get website => 'Sito web';

  @override
  String get passkey => 'Passkey';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Creata il $dateString';
  }

  @override
  String get notes => 'Note';

  @override
  String get customFields => 'Campi personalizzati';

  @override
  String get passwordHistory => 'Cronologia delle password';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Aggiornato il $updatedString, creato il $createdString';
  }

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String linkedTo(String field) {
    return 'Collegato a $field';
  }

  @override
  String get cardholderName => 'Titolare della carta';

  @override
  String get cardBrand => 'Marca';

  @override
  String get cardNumber => 'Numero';

  @override
  String get cardExpiration => 'Scadenza';

  @override
  String get cardExpMonth => 'Mese di scadenza';

  @override
  String get cardExpYear => 'Anno di scadenza';

  @override
  String get cardCode => 'Codice di sicurezza';

  @override
  String get fullName => 'Nome';

  @override
  String get identityTitle => 'Titolo';

  @override
  String get firstName => 'Nome';

  @override
  String get middleName => 'Secondo nome';

  @override
  String get lastName => 'Cognome';

  @override
  String get company => 'Azienda';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Telefono';

  @override
  String get address => 'Indirizzo';

  @override
  String get city => 'Città';

  @override
  String get state => 'Stato o provincia';

  @override
  String get postalCode => 'CAP';

  @override
  String get country => 'Paese';

  @override
  String get ssn => 'Codice fiscale';

  @override
  String get passportNumber => 'Numero passaporto';

  @override
  String get licenseNumber => 'Numero patente';

  @override
  String get privateKey => 'Chiave privata';

  @override
  String get publicKey => 'Chiave pubblica';

  @override
  String get fingerprint => 'Impronta';

  @override
  String get bankName => 'Banca';

  @override
  String get accountHolder => 'Titolare del conto';

  @override
  String get accountType => 'Tipo di conto';

  @override
  String get accountNumber => 'Numero del conto';

  @override
  String get routingNumber => 'Numero di routing';

  @override
  String get branchNumber => 'Codice filiale';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'Codice SWIFT';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Telefono della banca';

  @override
  String get accountTypeChecking => 'Conto corrente';

  @override
  String get accountTypeSavings => 'Conto di risparmio';

  @override
  String get accountTypeCertificateOfDeposit => 'Certificato di deposito';

  @override
  String get accountTypeLineOfCredit => 'Linea di credito';

  @override
  String get accountTypeInvestmentBrokerage => 'Conto titoli';

  @override
  String get accountTypeMoneyMarket => 'Mercato monetario';

  @override
  String get accountTypeOther => 'Altro';

  @override
  String get dateOfBirth => 'Data di nascita';

  @override
  String get issuingCountry => 'Paese di rilascio';

  @override
  String get issuingState => 'Stato o provincia di rilascio';

  @override
  String get issueDate => 'Data di rilascio';

  @override
  String get expirationDate => 'Data di scadenza';

  @override
  String get issuingAuthority => 'Autorità di rilascio';

  @override
  String get licenseClass => 'Categoria';

  @override
  String get surname => 'Cognome';

  @override
  String get givenName => 'Nome';

  @override
  String get sex => 'Sesso';

  @override
  String get birthPlace => 'Luogo di nascita';

  @override
  String get nationality => 'Nazionalità';

  @override
  String get passportType => 'Tipo';

  @override
  String get nationalId => 'Numero identificativo nazionale';

  @override
  String get filterAllItems => 'Tutti gli elementi';

  @override
  String get filterAllShort => 'Tutti';

  @override
  String get filterFavorites => 'Preferiti';

  @override
  String get filterLogins => 'Login';

  @override
  String get filterSecureNotes => 'Note sicure';

  @override
  String get filterCards => 'Carte';

  @override
  String get filterIdentities => 'Identità';

  @override
  String get filterSshKeys => 'Chiavi SSH';

  @override
  String get filterBankAccounts => 'Conti bancari';

  @override
  String get filterDriversLicenses => 'Patenti di guida';

  @override
  String get filterPassports => 'Passaporti';

  @override
  String get filterTrash => 'Cestino';

  @override
  String get noItemsHere => 'Nessun elemento qui.';

  @override
  String get searchItems => 'Cerca';

  @override
  String get clearSearch => 'Cancella la ricerca';

  @override
  String get noSearchResults => 'Nessun elemento corrisponde alla tua ricerca.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifiche non ancora inviate',
      one: '1 modifica non ancora inviata',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Nuovo elemento';

  @override
  String get newLogin => 'Nuovo login';

  @override
  String get newCard => 'Nuova carta';

  @override
  String get newSecureNote => 'Nuova nota sicura';

  @override
  String get editItem => 'Modifica elemento';

  @override
  String get edit => 'Modifica';

  @override
  String get save => 'Salva';

  @override
  String get itemSaveFailed => 'Impossibile salvare l\'elemento.';

  @override
  String get vault => 'Cassaforte';

  @override
  String get itemName => 'Nome';

  @override
  String get itemNameRequired => 'Dai un nome all\'elemento.';

  @override
  String get authenticatorKey => 'Chiave di autenticazione';

  @override
  String get authenticatorKeyHint => 'Segreto base32 o URI otpauth://';

  @override
  String get addWebsite => 'Aggiungi un sito web';

  @override
  String get addField => 'Aggiungi un campo';

  @override
  String get customField => 'Campo personalizzato';

  @override
  String get editField => 'Modifica il campo';

  @override
  String get fieldType => 'Tipo di campo';

  @override
  String get fieldTypeText => 'Testo';

  @override
  String get fieldTypeHidden => 'Nascosto';

  @override
  String get fieldTypeCheckbox => 'Casella di controllo';

  @override
  String get fieldTypeLinked => 'Collegato';

  @override
  String get textFieldHelp =>
      'Usa i campi di testo per dati come le domande di sicurezza.';

  @override
  String get hiddenFieldHelp =>
      'Usa i campi nascosti per dati sensibili come una password.';

  @override
  String get checkboxFieldHelp =>
      'Usa le caselle di controllo per spuntare quelle di un modulo, come quella per ricordare la tua email.';

  @override
  String get linkedFieldHelp =>
      'Usa un campo collegato quando il riempimento automatico ha problemi con un sito web specifico.';

  @override
  String get fieldLabel => 'Etichetta del campo';

  @override
  String get linkedFieldLabelHelp =>
      'Inserisci l\'id HTML, il name, l\'aria-label o il placeholder del campo.';

  @override
  String editFieldNamed(String field) {
    return 'Modifica $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return 'Elimina $field';
  }

  @override
  String reorderField(String field) {
    return 'Sposta $field';
  }

  @override
  String get cardBrandOther => 'Altro';

  @override
  String get cardExpYearHint => 'AAAA';

  @override
  String get notSet => 'Non specificato';

  @override
  String get favorite => 'Preferito';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get discardChanges => 'Scartare le modifiche?';

  @override
  String get keepEditing => 'Continua a modificare';

  @override
  String get discard => 'Scarta';

  @override
  String get moreActions => 'Altre azioni';

  @override
  String get copyUsername => 'Copia nome utente';

  @override
  String get copyPassword => 'Copia password';

  @override
  String get copyTotp => 'Copia codice di verifica';

  @override
  String get copyNumber => 'Copia numero';

  @override
  String get moveToTrash => 'Sposta nel cestino';

  @override
  String get restore => 'Ripristina';

  @override
  String get deletePermanently => 'Elimina definitivamente';

  @override
  String get deleteItemTitle => 'Eliminare definitivamente questo elemento?';

  @override
  String get deleteItemBody =>
      'Verrà cancellato dalla cassaforte, su tutti i dispositivi. Questa azione non può essere annullata.';

  @override
  String get delete => 'Elimina';

  @override
  String get generatePassword => 'Genera una password';

  @override
  String get generateUsername => 'Genera un nome utente';

  @override
  String get generator => 'Generatore';

  @override
  String get passphrase => 'Frase segreta';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get passwordLength => 'Lunghezza';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caratteri',
      one: '1 carattere',
    );
    return '$_temp0';
  }

  @override
  String get includeCharacters => 'Includi';

  @override
  String get uppercaseLetters => 'Lettere maiuscole';

  @override
  String get lowercaseLetters => 'Lettere minuscole';

  @override
  String get digits => 'Cifre';

  @override
  String get specialCharacters => 'Caratteri speciali';

  @override
  String get minNumbers => 'Cifre minime';

  @override
  String get minSpecial => 'Caratteri speciali minimi';

  @override
  String get avoidAmbiguous => 'Evita caratteri ambigui';

  @override
  String get numberOfWords => 'Numero di parole';

  @override
  String get wordSeparator => 'Separatore di parole';

  @override
  String get capitalize => 'Iniziali maiuscole';

  @override
  String get includeNumber => 'Includi una cifra';

  @override
  String get usePassword => 'Usa questa password';

  @override
  String get usePassphrase => 'Usa questa frase segreta';

  @override
  String get useUsername => 'Usa questo nome utente';

  @override
  String get usernameCapitalize => 'Iniziale maiuscola';

  @override
  String get usernameIncludeNumber => 'Includi un numero';

  @override
  String get decrease => 'Diminuisci';

  @override
  String get increase => 'Aumenta';

  @override
  String get settings => 'Impostazioni';

  @override
  String get security => 'Sicurezza';

  @override
  String get unlockWithBiometrics => 'Sblocca con i dati biometrici';

  @override
  String get unlockWithBiometricsDescription =>
      'Oppure con il codice o la password di questo dispositivo. Le chiavi delle casseforti restano nel suo archivio sicuro.';

  @override
  String get lockNeedsScreenLock =>
      'Imposta prima un blocco schermo su questo dispositivo.';

  @override
  String get lockAfter => 'Blocca dopo';

  @override
  String get lockImmediately => 'Subito';

  @override
  String get lockOnRestart => 'Al riavvio dell\'app';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'Cancella le password copiate dopo';

  @override
  String get never => 'Mai';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondi',
      one: '1 secondo',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Consenti la cattura dello schermo';

  @override
  String get allowScreenCaptureDescription =>
      'Permette a screenshot, registrazioni e condivisione dello schermo di mostrare le tue password.';

  @override
  String get lock => 'Blocca';

  @override
  String lockWithShortcut(String shortcut) {
    return 'Blocca ($shortcut)';
  }

  @override
  String get unlock => 'Sblocca';

  @override
  String get vaultsLocked => 'Le tue casseforti sono bloccate.';

  @override
  String get unlockReason => 'Sblocca le tue casseforti';

  @override
  String get enableLockReason => 'Attiva il blocco';

  @override
  String get authLockedOut => 'Troppi tentativi. Riprova più tardi.';

  @override
  String get authFailed =>
      'Questo dispositivo non è riuscito a verificare che sei tu.';

  @override
  String get vaultTab => 'Cassaforte';

  @override
  String get storageReadFailed => 'Impossibile leggere le tue casseforti.';

  @override
  String get storageReadFailedBody =>
      'L\'archivio sicuro di questo dispositivo si è rifiutato di aprirle. Non è stato cancellato nulla: riprova. I tuoi elementi restano online e la chiave di una cassaforte la apre su qualsiasi dispositivo.';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get appearance => 'Aspetto';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageName => 'Italiano';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get importExport => 'Importa ed esporta';

  @override
  String get importFromBitwarden => 'Importa da Bitwarden';

  @override
  String get importFromBitwardenDescription =>
      'Un\'esportazione JSON di Bitwarden.';

  @override
  String get importButton => 'Importa';

  @override
  String get importReadFailed => 'Impossibile leggere il file.';

  @override
  String get importNotBitwarden =>
      'Questo file non è un\'esportazione JSON di Bitwarden.';

  @override
  String get importEncrypted =>
      'Questa esportazione è limitata al tuo account Bitwarden e solo Bitwarden può aprirla. Esporta di nuovo la cassaforte da Bitwarden, protetta da password o nel formato .json.';

  @override
  String get importEmpty => 'Questa esportazione non contiene elementi.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi trovati in $file.',
      one: '1 elemento trovato in $file.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done su $total elementi importati';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi importati in $vault.',
      one: '1 elemento importato in $vault.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'L\'importazione si è interrotta: salvati $done su $total elementi.';
  }

  @override
  String get exportVault => 'Esporta una cassaforte';

  @override
  String get exportVaultDescription =>
      'Un file JSON di Bitwarden, protetto da password o non cifrato.';

  @override
  String get exportButton => 'Esporta';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi. Il cestino è escluso.',
      one: '1 elemento. Il cestino è escluso.',
      zero: 'Questa cassaforte non ha elementi da esportare.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'Il file non è cifrato. Non inviarlo via email ed eliminalo appena non ti serve più.';

  @override
  String get exportFailed => 'Impossibile salvare il file.';

  @override
  String get importPasswordBody =>
      'Questa esportazione è protetta da una password. Inseriscila per aprire il file.';

  @override
  String get filePassword => 'Password del file';

  @override
  String get wrongFilePassword => 'Questa password non apre il file.';

  @override
  String get exportProtect => 'Proteggi con una password';

  @override
  String get confirmFilePassword => 'Conferma la password del file';

  @override
  String get filePasswordHelper =>
      'Submarine e Bitwarden la chiedono per importare il file. Non può essere recuperata.';

  @override
  String get filePasswordRequired => 'Scegli una password.';

  @override
  String get filePasswordMismatch => 'Le password non corrispondono.';

  @override
  String get lockPassword => 'Password di sblocco';

  @override
  String get lockPasswordDescription =>
      'Cifra le chiavi delle casseforti su questo dispositivo e sblocca l\'app. Non può essere recuperata.';

  @override
  String get setLockPassword => 'Imposta';

  @override
  String get changeLockPassword => 'Cambia';

  @override
  String get removeLockPassword => 'Rimuovi';

  @override
  String get setLockPasswordTitle => 'Imposta una password di sblocco';

  @override
  String get changeLockPasswordTitle => 'Cambia la password di sblocco';

  @override
  String get removeLockPasswordTitle => 'Rimuovi la password di sblocco';

  @override
  String get removeLockPasswordBody =>
      'L\'app non la chiederà più. Le chiavi delle casseforti su questo dispositivo saranno protette solo dal suo archivio sicuro.';

  @override
  String get currentLockPassword => 'Password attuale';

  @override
  String get newLockPassword => 'Nuova password';

  @override
  String get confirmLockPassword => 'Conferma la password';

  @override
  String lockPasswordHelper(int count) {
    return 'Almeno $count caratteri. Se la dimentichi, le casseforti vanno rimosse da questo dispositivo.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Almeno $count caratteri.';
  }

  @override
  String get lockPasswordMismatch => 'Le password non corrispondono.';

  @override
  String get wrongLockPassword => 'Questa non è la password di sblocco.';

  @override
  String get generatePassphrase => 'Genera una frase segreta';

  @override
  String get unlockWithBiometricsWithPassword =>
      'Invece di digitare la password di sblocco, che resta valida.';

  @override
  String get forgotLockPassword => 'Password dimenticata?';

  @override
  String get forgetVaultsTitle =>
      'Rimuovere le casseforti da questo dispositivo?';

  @override
  String get forgetVaultsBody =>
      'Senza la password di sblocco, qui non possono essere decifrate. I tuoi elementi restano online: riapri ogni cassaforte con la sua chiave.';

  @override
  String get forgetVaults => 'Rimuovi le casseforti';

  @override
  String get removeVault => 'Rimuovi da questo dispositivo';

  @override
  String get removeVaultDescription =>
      'La cassaforte resta online, così potrai riaprirla.';

  @override
  String removeVaultTitle(String name) {
    return 'Rimuovere $name da questo dispositivo?';
  }

  @override
  String get removeVaultBody =>
      'I tuoi elementi restano online: riapri la cassaforte per ritrovarli.';

  @override
  String get removeVaultKeyWarning =>
      'Conserva prima la sua chiave: senza di essa non potrai riaprire la cassaforte.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifiche non sono ancora state inviate e andranno perse.',
      one: '1 modifica non è ancora stata inviata e andrà persa.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Rimuovi';

  @override
  String get removeVaultFailed => 'Impossibile rimuovere la cassaforte.';

  @override
  String get emailSettings => 'Email';

  @override
  String get mailBridge => 'Ponte email';

  @override
  String mailBridgeDescription(String domain) {
    return 'I nuovi indirizzi email finiscono con @$domain';
  }

  @override
  String get changeMailBridge => 'Cambia';

  @override
  String get mailBridgeDomain => 'Dominio';

  @override
  String get mailBridgeExplanation =>
      'Gli indirizzi email creati da ora in poi finiscono con questo dominio. Quelli creati prima mantengono il loro.';

  @override
  String get mailBridgeInvalid => 'Questo non è un dominio.';
}
