// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get allVaults => 'Kaikki holvit';

  @override
  String get vaults => 'Holvit';

  @override
  String get addVault => 'Lisää holvi';

  @override
  String get createVault => 'Luo holvi';

  @override
  String get createVaultDescription => 'Uusi tyhjä holvi, jolla on oma avain.';

  @override
  String get openVault => 'Avaa holvi';

  @override
  String get openVaultDescription => 'Toiselta laitteelta tai sinulle jaettu.';

  @override
  String get openVaultTitle => 'Avaa holvi';

  @override
  String get vaultName => 'Nimi';

  @override
  String get vaultNameHelper =>
      'Vain tällä laitteella. Henkilö, jonka kanssa jaat holvin, nimeää sen omalla tavallaan.';

  @override
  String get vaultNameRequired => 'Anna holville nimi.';

  @override
  String get vaultColor => 'Väri';

  @override
  String get vaultColorBlue => 'Sininen';

  @override
  String get vaultColorOrange => 'Oranssi';

  @override
  String get vaultColorGreen => 'Vihreä';

  @override
  String get vaultColorPurple => 'Violetti';

  @override
  String get vaultColorPink => 'Pinkki';

  @override
  String get vaultColorGray => 'Harmaa';

  @override
  String get vaultKey => 'Holvin avain';

  @override
  String get vaultKeyInvalid => 'Tämä ei ole holvin avain.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Tämä holvi on jo auki nimellä $name.';
  }

  @override
  String get vaultSaveFailed => 'Holvia ei voitu tallentaa tälle laitteelle.';

  @override
  String get saveVaultKeyTitle => 'Tallenna holvin avain';

  @override
  String get saveVaultKeyBody =>
      'Kuka tahansa, jolla on tämä avain, voi avata holvin. Säilytä se turvallisessa paikassa: tarvitset sitä avataksesi holvin toisella laitteella tai jakaaksesi sen.';

  @override
  String get vaultSettings => 'Holvin asetukset';

  @override
  String get vaultNameAndColor => 'Nimi ja väri';

  @override
  String get vaultPublicKey => 'Julkinen avain';

  @override
  String get vaultKeyDescription =>
      'Kuka tahansa, jolla se on, voi avata tämän holvin. Syötä se toisella laitteella avataksesi holvin siellä, tai anna se jollekulle jakaaksesi holvin hänen kanssaan.';

  @override
  String get vaultKeyHelper =>
      'Holvia luotaessa tallennettu avain tai sinulle jaettu avain.';

  @override
  String get vaultKeyPassword => 'Avaimen salasana';

  @override
  String get vaultKeyPasswordWrong => 'Tämä salasana ei avaa avainta.';

  @override
  String get vaultKeyDecrypting => 'Puretaan avaimen salausta';

  @override
  String get otherWaysToOpen => 'Muut avaustavat';

  @override
  String get signersDescription =>
      'Käytä allekirjoittajaa, joka säilyttää avaimen Submarinen ulkopuolella. Myös bunker://-osoitteen voi syöttää avainkenttään.';

  @override
  String get browserExtension => 'Selainlaajennus';

  @override
  String get signerApp => 'Allekirjoitussovellus';

  @override
  String get bunker => 'Etäallekirjoittaja';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Skannaa tämä koodi etäallekirjoittajallasi tai allekirjoitussovelluksellasi, tai liitä osoite siihen.';

  @override
  String get noBrowserExtension => 'Tässä selaimessa ei ole Nostr-laajennusta.';

  @override
  String get noSignerApp =>
      'Tällä laitteella ei ole allekirjoitussovellusta, kuten Amberia.';

  @override
  String get signerRefused => 'Pyyntö hylättiin.';

  @override
  String get waitingForAnswer => 'Odotetaan vastausta';

  @override
  String get bunkerUrlInvalid =>
      'Tästä etäallekirjoittajan osoitteesta puuttuu rele tai salaisuus.';

  @override
  String get bunkerNoAnswer => 'Etäallekirjoittaja ei vastannut.';

  @override
  String get bunkerApproval =>
      'Etäallekirjoittaja pyytää sinua hyväksymään Submarinen sen sivulla.';

  @override
  String get openApprovalPage => 'Avaa sivu';

  @override
  String get nothingConnected => 'Yhteyttä ei muodostunut ajoissa.';

  @override
  String get useAnotherKey => 'Käytä toista avainta';

  @override
  String get vaultSignerDescription =>
      'Säilyttää holvin avaimen, joka ei koskaan päädy Submarineen. Avaa holvi toisella laitteella samalla tavalla.';

  @override
  String get askSignerAtStart => 'Kysy allekirjoittajalta joka käynnistyksessä';

  @override
  String get askSignerAtStartDescription =>
      'Pois päältä: tälle laitteelle tallennettu avain lukee holvia, vaikka allekirjoittaja ei olisi tavoitettavissa. Päällä: holvi pysyy suljettuna, kunnes allekirjoittaja avaa sen.';

  @override
  String get askSignerFailed => 'Allekirjoittaja kieltäytyi tai epäonnistui.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pyyntöä odottaa allekirjoittajaasi',
      one: '1 pyyntö odottaa allekirjoittajaasi',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'Odotetaan allekirjoittajaasi';

  @override
  String get signerRequestsDescription =>
      'Hyväksy nämä pyynnöt allekirjoittajassasi tai peruuta ne.';

  @override
  String get requestOpenVault => 'Avaa holvi';

  @override
  String get requestLockVault => 'Lukitse holvi allekirjoittajan taakse';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pura $count kohdeversion salaus',
      one: 'Pura kohteen version salaus',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tallenna $count kohdeversiota',
      one: 'Tallenna kohteen versio',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poista $count kohdeversiota pysyvästi',
      one: 'Poista kohteen versio pysyvästi',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Tallenna releluettelo';

  @override
  String get requestReadRelays => 'Lue yksityiset releet';

  @override
  String get requestEncryptRelays => 'Salaa yksityiset releet';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kirjaudu $count releeseen',
      one: 'Kirjaudu releeseen',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count muuta pyyntöä ($method)',
      one: 'Muu pyyntö ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Peruuta kaikki';

  @override
  String get close => 'Sulje';

  @override
  String get sync => 'Synkronointi';

  @override
  String get syncAllSent => 'Kaikki muutokset on tallennettu verkkoon.';

  @override
  String get relays => 'Releet';

  @override
  String get relaysDescription =>
      'Tämä holvi kopioidaan kaikkiin näihin releisiin. Ne näkevät vain salattua tietoa ja holvin julkisen avaimen.';

  @override
  String get relayConnected => 'Yhdistetty';

  @override
  String get relayNotConnected => 'Ei yhteyttä';

  @override
  String get relayPrivate => 'Yksityinen';

  @override
  String get removeRelay => 'Poista tämä rele';

  @override
  String get addRelay => 'Lisää rele';

  @override
  String get relayAddress => 'Releen osoite';

  @override
  String get relayAddressInvalid => 'Tämä ei ole releen osoite.';

  @override
  String get relayAlreadyListed => 'Tämä rele on jo luettelossa.';

  @override
  String get relayKeepPrivate => 'Pidä yksityisenä';

  @override
  String get relayKeepPrivateDescription =>
      'Salattu holvin releluettelossa: vain holvin avaimen haltijat tietävät, että holvi on tässä releessä.';

  @override
  String get relaysSaveFailed => 'Releitä ei voitu tallentaa.';

  @override
  String get relaysWaitForSync =>
      'Voit muuttaa releitä, kun holvi on synkronoitu.';

  @override
  String get relayAdded => 'Uusi';

  @override
  String get relayRemoved => 'Poistettu';

  @override
  String get keepRelay => 'Säilytä tämä rele';

  @override
  String get relaysNeedOne => 'Holvi tarvitsee vähintään yhden releen.';

  @override
  String get fileServers => 'Tiedostopalvelimet';

  @override
  String get fileServersDescription =>
      'Tämän holvin liitetiedostot kopioidaan kaikille näille palvelimille. Ne näkevät vain salattuja tiedostoja.';

  @override
  String relaysConnected(int connected, int count) {
    return '$connected/$count yhdistetty';
  }

  @override
  String fileServerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palvelinta',
      one: '1 palvelin',
    );
    return '$_temp0';
  }

  @override
  String get serverPrivate => 'Yksityinen';

  @override
  String get removeServer => 'Poista tämä palvelin';

  @override
  String get keepServer => 'Säilytä tämä palvelin';

  @override
  String get addServer => 'Lisää palvelin';

  @override
  String get serverAddress => 'Palvelimen osoite';

  @override
  String get serverAddressInvalid => 'Tämä ei ole palvelimen osoite.';

  @override
  String get serverAlreadyListed => 'Tämä palvelin on jo luettelossa.';

  @override
  String get serverKeepPrivate => 'Pidä yksityisenä';

  @override
  String get serverKeepPrivateDescription =>
      'Salattu holvin palvelinluettelossa: vain holvin avaimen haltijat tietävät, että holvi käyttää tätä palvelinta.';

  @override
  String get serversSaveFailed => 'Palvelimia ei voitu tallentaa.';

  @override
  String get serversWaitForSync =>
      'Voit muuttaa palvelimia, kun holvi on synkronoitu.';

  @override
  String get serverAdded => 'Uusi';

  @override
  String get serverRemoved => 'Poistettu';

  @override
  String get serversNeedOne => 'Holvi tarvitsee vähintään yhden palvelimen.';

  @override
  String get add => 'Lisää';

  @override
  String get cancel => 'Peruuta';

  @override
  String get create => 'Luo';

  @override
  String get open => 'Avaa';

  @override
  String get done => 'Valmis';

  @override
  String get welcomeTagline =>
      'Salasanasi salattuina ja synkronoituina. Tiliä ei tarvita.';

  @override
  String get builtOnNostr => 'Nostr-pohjainen';

  @override
  String get builtOnNostrBody =>
      'Holvisi sijaitsevat Nostr-releillä eli avoimilla palvelimilla, joita kuka tahansa voi ylläpitää ja jotka näkevät vain salattua tietoa. Holvin avain on Nostr-avain, joten Nostr-allekirjoittaja voi säilyttää sen.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kohdetta',
      one: '1 kohde',
      zero: 'Ei kohteita',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Synkronoi nyt';

  @override
  String get syncing => 'Synkronoidaan';

  @override
  String get syncNever => 'Ei koskaan synkronoitu';

  @override
  String get syncFailed => 'Synkronointi epäonnistui';

  @override
  String get signerDidNotOpen => 'Allekirjoittaja ei avannut holvia';

  @override
  String get syncedJustNow => 'Synkronoitu juuri nyt';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Synkronoitu $minutes min sitten';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Synkronoitu $hours h sitten';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Synkronoitu $dateString';
  }

  @override
  String get noItems => 'Tässä holvissa ei ole vielä kohteita.';

  @override
  String get lookingForItems => 'Etsitään kohteitasi';

  @override
  String get signerDidNotOpenVault =>
      'Allekirjoittaja ei avannut tätä holvia. Pyydä uudelleen synkronoimalla.';

  @override
  String get selectItem => 'Valitse kohde nähdäksesi sen tässä.';

  @override
  String get itemNotFound => 'Tätä kohdetta ei ole enää holvissa.';

  @override
  String get typeLogin => 'Kirjautumistieto';

  @override
  String get typeSecureNote => 'Salattu muistio';

  @override
  String get typeCard => 'Kortti';

  @override
  String get typeIdentity => 'Henkilöllisyys';

  @override
  String get typeSshKey => 'SSH-avain';

  @override
  String get typeBankAccount => 'Pankkitili';

  @override
  String get typeDriversLicense => 'Ajokortti';

  @override
  String get typePassport => 'Passi';

  @override
  String get typeUnknown => 'Kohde';

  @override
  String get copy => 'Kopioi';

  @override
  String get copied => 'Kopioitu';

  @override
  String get show => 'Näytä';

  @override
  String get hide => 'Piilota';

  @override
  String get hiddenValue => 'Piilotettu arvo';

  @override
  String get openWebsite => 'Avaa verkkosivusto';

  @override
  String get username => 'Käyttäjätunnus';

  @override
  String get password => 'Salasana';

  @override
  String get verificationCode => 'Todennuskoodi';

  @override
  String get totpInvalid => 'Tätä todennusavainta ei voi lukea.';

  @override
  String get website => 'Verkkosivusto';

  @override
  String get passkey => 'Pääsyavain';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Luotu $dateString';
  }

  @override
  String get notes => 'Merkinnät';

  @override
  String get customFields => 'Lisäkentät';

  @override
  String get passwordHistory => 'Salasanahistoria';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Päivitetty $updatedString, luotu $createdString';
  }

  @override
  String get yes => 'Kyllä';

  @override
  String get no => 'Ei';

  @override
  String linkedTo(String field) {
    return 'Linkitetty: $field';
  }

  @override
  String get cardholderName => 'Kortinhaltijan nimi';

  @override
  String get cardBrand => 'Merkki';

  @override
  String get cardNumber => 'Numero';

  @override
  String get cardExpiration => 'Voimassaolo päättyy';

  @override
  String get cardExpMonth => 'Erääntymiskuukausi';

  @override
  String get cardExpYear => 'Erääntymisvuosi';

  @override
  String get cardCode => 'Turvakoodi';

  @override
  String get fullName => 'Nimi';

  @override
  String get identityTitle => 'Titteli';

  @override
  String get firstName => 'Etunimi';

  @override
  String get middleName => 'Toinen nimi';

  @override
  String get lastName => 'Sukunimi';

  @override
  String get company => 'Yritys';

  @override
  String get email => 'Sähköpostiosoite';

  @override
  String get phone => 'Puhelinnumero';

  @override
  String get address => 'Osoite';

  @override
  String get city => 'Paikkakunta';

  @override
  String get state => 'Osavaltio tai maakunta';

  @override
  String get postalCode => 'Postinumero';

  @override
  String get country => 'Maa';

  @override
  String get ssn => 'Sosiaaliturvatunnus';

  @override
  String get passportNumber => 'Passin numero';

  @override
  String get licenseNumber => 'Ajokortin numero';

  @override
  String get privateKey => 'Yksityinen avain';

  @override
  String get publicKey => 'Julkinen avain';

  @override
  String get fingerprint => 'Sormenjälki';

  @override
  String get bankName => 'Pankki';

  @override
  String get accountHolder => 'Tilinomistaja';

  @override
  String get accountType => 'Tilityyppi';

  @override
  String get accountNumber => 'Tilinumero';

  @override
  String get routingNumber => 'Reititysnumero';

  @override
  String get branchNumber => 'Konttorinumero';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'SWIFT-koodi';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Pankin puhelinnumero';

  @override
  String get accountTypeChecking => 'Käyttötili';

  @override
  String get accountTypeSavings => 'Säästötili';

  @override
  String get accountTypeCertificateOfDeposit => 'Määräaikaistalletus';

  @override
  String get accountTypeLineOfCredit => 'Luottolimiitti';

  @override
  String get accountTypeInvestmentBrokerage => 'Arvo-osuustili';

  @override
  String get accountTypeMoneyMarket => 'Rahamarkkinatili';

  @override
  String get accountTypeOther => 'Muu';

  @override
  String get dateOfBirth => 'Syntymäaika';

  @override
  String get issuingCountry => 'Myöntäjämaa';

  @override
  String get issuingState => 'Myöntäjäalue';

  @override
  String get issueDate => 'Myöntämispäivä';

  @override
  String get expirationDate => 'Viimeinen voimassaolopäivä';

  @override
  String get issuingAuthority => 'Myöntänyt viranomainen';

  @override
  String get licenseClass => 'Luokka';

  @override
  String get surname => 'Sukunimi';

  @override
  String get givenName => 'Etunimi';

  @override
  String get sex => 'Sukupuoli';

  @override
  String get birthPlace => 'Syntymäpaikka';

  @override
  String get nationality => 'Kansalaisuus';

  @override
  String get passportType => 'Tyyppi';

  @override
  String get nationalId => 'Henkilötunnus';

  @override
  String get filterAllItems => 'Kaikki kohteet';

  @override
  String get filterAllShort => 'Kaikki';

  @override
  String get filterFavorites => 'Suosikit';

  @override
  String get filterLogins => 'Kirjautumistiedot';

  @override
  String get filterSecureNotes => 'Salatut muistiot';

  @override
  String get filterCards => 'Kortit';

  @override
  String get filterIdentities => 'Henkilöllisyydet';

  @override
  String get filterSshKeys => 'SSH-avaimet';

  @override
  String get filterBankAccounts => 'Pankkitilit';

  @override
  String get filterDriversLicenses => 'Ajokortit';

  @override
  String get filterPassports => 'Passit';

  @override
  String get filterTrash => 'Roskakori';

  @override
  String get noItemsHere => 'Täällä ei ole kohteita.';

  @override
  String get searchItems => 'Etsi';

  @override
  String get clearSearch => 'Tyhjennä haku';

  @override
  String get noSearchResults => 'Mikään kohde ei vastaa hakuasi.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count muutosta lähettämättä',
      one: '1 muutos lähettämättä',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Uusi kohde';

  @override
  String get newLogin => 'Uusi kirjautumistieto';

  @override
  String get newCard => 'Uusi kortti';

  @override
  String get newSecureNote => 'Uusi salattu muistio';

  @override
  String get editItem => 'Muokkaa kohdetta';

  @override
  String get edit => 'Muokkaa';

  @override
  String get save => 'Tallenna';

  @override
  String get itemSaveFailed => 'Kohdetta ei voitu tallentaa.';

  @override
  String get vault => 'Holvi';

  @override
  String get itemName => 'Nimi';

  @override
  String get itemNameRequired => 'Anna kohteelle nimi.';

  @override
  String get authenticatorKey => 'Todennusavain';

  @override
  String get authenticatorKeyHint => 'Base32-salaisuus tai otpauth://-URI';

  @override
  String get addWebsite => 'Lisää verkkosivusto';

  @override
  String get addField => 'Lisää kenttä';

  @override
  String get customField => 'Lisäkenttä';

  @override
  String get editField => 'Muokkaa kenttää';

  @override
  String get fieldType => 'Kentän tyyppi';

  @override
  String get fieldTypeText => 'Teksti';

  @override
  String get fieldTypeHidden => 'Piilotettu';

  @override
  String get fieldTypeCheckbox => 'Valintaruutu';

  @override
  String get fieldTypeLinked => 'Linkitetty';

  @override
  String get textFieldHelp =>
      'Käytä tekstikenttiä esimerkiksi turvakysymysten kaltaisille tiedoille.';

  @override
  String get hiddenFieldHelp =>
      'Käytä piilotettuja kenttiä arkaluonteisille tiedoille, kuten salasanoille.';

  @override
  String get checkboxFieldHelp =>
      'Käytä valintaruutuja lomakkeen valintaruutujen täyttämiseen, esimerkiksi sähköpostiosoitteen muistamiseen.';

  @override
  String get linkedFieldHelp =>
      'Käytä linkitettyä kenttää, kun automaattinen täyttö ei toimi jollakin sivustolla.';

  @override
  String get fieldLabel => 'Kentän nimi';

  @override
  String get linkedFieldLabelHelp =>
      'Syötä kentän HTML-id, name, aria-label tai placeholder.';

  @override
  String editFieldNamed(String field) {
    return 'Muokkaa kenttää $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return 'Poista kenttä $field';
  }

  @override
  String reorderField(String field) {
    return 'Siirrä kenttää $field';
  }

  @override
  String get cardBrandOther => 'Muu';

  @override
  String get cardExpYearHint => 'VVVV';

  @override
  String get notSet => 'Ei määritetty';

  @override
  String get favorite => 'Suosikki';

  @override
  String get addToFavorites => 'Lisää suosikkeihin';

  @override
  String get removeFromFavorites => 'Poista suosikeista';

  @override
  String get discardChanges => 'Hylätäänkö muutokset?';

  @override
  String get keepEditing => 'Jatka muokkausta';

  @override
  String get discard => 'Hylkää';

  @override
  String get moreActions => 'Lisää toimintoja';

  @override
  String get copyUsername => 'Kopioi käyttäjätunnus';

  @override
  String get copyPassword => 'Kopioi salasana';

  @override
  String get copyTotp => 'Kopioi todennuskoodi';

  @override
  String get copyNumber => 'Kopioi numero';

  @override
  String get moveToTrash => 'Siirrä roskakoriin';

  @override
  String get restore => 'Palauta';

  @override
  String get deletePermanently => 'Poista pysyvästi';

  @override
  String get deleteItemTitle => 'Poistetaanko kohde pysyvästi?';

  @override
  String get deleteItemBody =>
      'Se poistetaan holvista kaikilla laitteilla. Toimintoa ei voi kumota.';

  @override
  String get delete => 'Poista';

  @override
  String get generatePassword => 'Luo salasana';

  @override
  String get generateUsername => 'Luo käyttäjätunnus';

  @override
  String get generator => 'Generaattori';

  @override
  String get passphrase => 'Salalause';

  @override
  String get regenerate => 'Luo uudelleen';

  @override
  String get passwordLength => 'Pituus';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count merkkiä',
      one: '1 merkki',
    );
    return '$_temp0';
  }

  @override
  String get includeCharacters => 'Sisällytä';

  @override
  String get uppercaseLetters => 'Isot kirjaimet';

  @override
  String get lowercaseLetters => 'Pienet kirjaimet';

  @override
  String get digits => 'Numerot';

  @override
  String get specialCharacters => 'Erikoismerkit';

  @override
  String get minNumbers => 'Numeroita vähintään';

  @override
  String get minSpecial => 'Erikoismerkkejä vähintään';

  @override
  String get avoidAmbiguous => 'Vältä epäselviä merkkejä';

  @override
  String get numberOfWords => 'Sanojen määrä';

  @override
  String get wordSeparator => 'Sanojen erotin';

  @override
  String get capitalize => 'Sanat isoilla alkukirjaimilla';

  @override
  String get includeNumber => 'Sisällytä numero';

  @override
  String get usePassword => 'Käytä tätä salasanaa';

  @override
  String get usePassphrase => 'Käytä tätä salalausetta';

  @override
  String get useUsername => 'Käytä tätä käyttäjätunnusta';

  @override
  String get usernameCapitalize => 'Iso alkukirjain';

  @override
  String get usernameIncludeNumber => 'Sisällytä numero';

  @override
  String get decrease => 'Vähennä';

  @override
  String get increase => 'Kasvata';

  @override
  String get settings => 'Asetukset';

  @override
  String get security => 'Suojaus';

  @override
  String get unlockWithBiometrics => 'Avaa lukitus biometrialla';

  @override
  String get unlockWithBiometricsDescription =>
      'Tai tämän laitteen koodilla tai salasanalla. Holvien avaimet pysyvät laitteen suojatussa tallennustilassa.';

  @override
  String get lockNeedsScreenLock =>
      'Ota ensin näytön lukitus käyttöön tällä laitteella.';

  @override
  String get lockAfter => 'Lukitusviive';

  @override
  String get lockImmediately => 'Heti';

  @override
  String get lockOnRestart => 'Kun sovellus käynnistyy uudelleen';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuuttia',
      one: '1 minuutti',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuntia',
      one: '1 tunti',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'Tyhjennä kopioidut salasanat';

  @override
  String get never => 'Ei koskaan';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sekuntia',
      one: '1 sekunti',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Salli näytön kaappaus';

  @override
  String get allowScreenCaptureDescription =>
      'Salasanasi voivat tällöin näkyä kuvakaappauksissa, näyttötallenteissa ja näytön jakamisessa.';

  @override
  String get lock => 'Lukitse';

  @override
  String lockWithShortcut(String shortcut) {
    return 'Lukitse ($shortcut)';
  }

  @override
  String get unlock => 'Avaa lukitus';

  @override
  String get vaultsLocked => 'Holvisi ovat lukossa.';

  @override
  String get unlockReason => 'Avaa holviesi lukitus';

  @override
  String get enableLockReason => 'Ota lukitus käyttöön';

  @override
  String get authLockedOut =>
      'Liian monta yritystä. Yritä myöhemmin uudelleen.';

  @override
  String get authFailed => 'Tämä laite ei voinut varmistaa henkilöllisyyttäsi.';

  @override
  String get vaultTab => 'Holvi';

  @override
  String get storageReadFailed => 'Holvejasi ei voitu lukea.';

  @override
  String get storageReadFailedBody =>
      'Tämän laitteen suojattu tallennustila ei suostunut avaamaan niitä. Mitään ei poistettu: yritä uudelleen. Kohteesi pysyvät verkossa, ja holvin avain avaa sen millä tahansa laitteella.';

  @override
  String get tryAgain => 'Yritä uudelleen';

  @override
  String get appearance => 'Ulkoasu';

  @override
  String get language => 'Kieli';

  @override
  String get languageSystem => 'Järjestelmä';

  @override
  String get languageName => 'Suomi';

  @override
  String get theme => 'Teema';

  @override
  String get themeSystem => 'Järjestelmä';

  @override
  String get themeLight => 'Vaalea';

  @override
  String get themeDark => 'Tumma';

  @override
  String get importExport => 'Tuonti ja vienti';

  @override
  String get importFromBitwarden => 'Tuo Bitwardenista';

  @override
  String get importFromBitwardenDescription =>
      'Bitwardenin JSON-vientitiedosto.';

  @override
  String get importButton => 'Tuo';

  @override
  String get importReadFailed => 'Tiedostoa ei voitu lukea.';

  @override
  String get importNotBitwarden =>
      'Tämä tiedosto ei ole Bitwardenin JSON-vientitiedosto.';

  @override
  String get importEncrypted =>
      'Tämä vientitiedosto on rajattu Bitwarden-tilillesi, ja vain Bitwarden voi avata sen. Vie holvisi Bitwardenista uudelleen salasanasuojattuna tai .json-muodossa.';

  @override
  String get importEmpty => 'Tässä vientitiedostossa ei ole kohteita.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tiedostosta $file löytyi $count kohdetta.',
      one: 'Tiedostosta $file löytyi 1 kohde.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done/$total kohdetta tuotu';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kohdetta tuotiin holviin $vault.',
      one: '1 kohde tuotiin holviin $vault.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'Tuonti keskeytyi: $done/$total kohdetta tallennettiin.';
  }

  @override
  String get exportVault => 'Vie holvi';

  @override
  String get exportVaultDescription =>
      'Bitwardenin JSON-tiedosto, salasanasuojattu tai salaamaton.';

  @override
  String get exportButton => 'Vie';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kohdetta. Roskakoria ei viedä.',
      one: '1 kohde. Roskakoria ei viedä.',
      zero: 'Tässä holvissa ei ole vietäviä kohteita.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'Tiedostoa ei ole salattu. Älä lähetä sitä sähköpostitse, ja poista se, kun et enää tarvitse sitä.';

  @override
  String get exportFailed => 'Tiedostoa ei voitu tallentaa.';

  @override
  String get importPasswordBody =>
      'Tämä vientitiedosto on salasanasuojattu. Avaa tiedosto syöttämällä salasana.';

  @override
  String get filePassword => 'Tiedoston salasana';

  @override
  String get wrongFilePassword => 'Tämä salasana ei avaa tiedostoa.';

  @override
  String get exportProtect => 'Suojaa salasanalla';

  @override
  String get confirmFilePassword => 'Vahvista tiedoston salasana';

  @override
  String get filePasswordHelper =>
      'Submarine ja Bitwarden kysyvät sitä tiedostoa tuotaessa. Sitä ei voi palauttaa.';

  @override
  String get filePasswordRequired => 'Valitse salasana.';

  @override
  String get filePasswordMismatch => 'Salasanat eivät täsmää.';

  @override
  String get lockPassword => 'Lukitussalasana';

  @override
  String get lockPasswordDescription =>
      'Salaa holvien avaimet tällä laitteella ja avaa sovelluksen lukituksen. Sitä ei voi palauttaa.';

  @override
  String get setLockPassword => 'Aseta';

  @override
  String get changeLockPassword => 'Vaihda';

  @override
  String get removeLockPassword => 'Poista';

  @override
  String get setLockPasswordTitle => 'Aseta lukitussalasana';

  @override
  String get changeLockPasswordTitle => 'Vaihda lukitussalasana';

  @override
  String get removeLockPasswordTitle => 'Poista lukitussalasana';

  @override
  String get removeLockPasswordBody =>
      'Sovellus ei enää kysy sitä. Holvien avaimet ovat tällä laitteella silloin vain sen suojatun tallennustilan varassa.';

  @override
  String get currentLockPassword => 'Nykyinen salasana';

  @override
  String get newLockPassword => 'Uusi salasana';

  @override
  String get confirmLockPassword => 'Vahvista salasana';

  @override
  String lockPasswordHelper(int count) {
    return 'Vähintään $count merkkiä. Jos unohdat sen, holvit poistetaan tältä laitteelta.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Vähintään $count merkkiä.';
  }

  @override
  String get lockPasswordMismatch => 'Salasanat eivät täsmää.';

  @override
  String get wrongLockPassword => 'Tämä ei ole lukitussalasana.';

  @override
  String get generatePassphrase => 'Luo salalause';

  @override
  String get unlockWithBiometricsWithPassword =>
      'Lukitussalasanan kirjoittamisen sijaan. Salasana toimii edelleen.';

  @override
  String get forgotLockPassword => 'Unohditko salasanan?';

  @override
  String get forgetVaultsTitle => 'Poistetaanko holvit tältä laitteelta?';

  @override
  String get forgetVaultsBody =>
      'Ilman lukitussalasanaa niiden salausta ei voi purkaa tällä laitteella. Kohteesi pysyvät verkossa: avaa jokainen holvi uudelleen sen omalla avaimella.';

  @override
  String get forgetVaults => 'Poista holvit';

  @override
  String get removeVault => 'Poista tältä laitteelta';

  @override
  String get removeVaultDescription =>
      'Holvi säilyy verkossa, joten voit avata sen uudelleen.';

  @override
  String removeVaultTitle(String name) {
    return 'Poistetaanko holvi $name tältä laitteelta?';
  }

  @override
  String get removeVaultBody =>
      'Kohteesi pysyvät verkossa: avaa holvi uudelleen löytääksesi ne.';

  @override
  String get removeVaultKeyWarning =>
      'Tallenna ensin sen avain: ilman sitä et voi avata holvia uudelleen.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count muutosta on vielä lähettämättä ja menetetään.',
      one: '1 muutos on vielä lähettämättä ja menetetään.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Poista';

  @override
  String get removeVaultFailed => 'Holvia ei voitu poistaa.';

  @override
  String get emailSettings => 'Sähköposti';

  @override
  String get mailBridge => 'Sähköpostisilta';

  @override
  String mailBridgeDescription(String domain) {
    return 'Uudet sähköpostiosoitteet päättyvät @$domain';
  }

  @override
  String get changeMailBridge => 'Vaihda';

  @override
  String get mailBridgeDomain => 'Verkkotunnus';

  @override
  String get mailBridgeExplanation =>
      'Tästä lähtien luodut sähköpostiosoitteet päättyvät tähän verkkotunnukseen. Aiemmin luodut säilyttävät omansa.';

  @override
  String get mailBridgeInvalid => 'Tämä ei ole verkkotunnus.';

  @override
  String get emailAddressField => 'Sähköpostiosoite';

  @override
  String get mailboxKey => 'Postilaatikon avain';

  @override
  String get inbox => 'Saapuneet';

  @override
  String get inboxFetching => 'Haetaan viestejä';

  @override
  String get inboxEmpty => 'Ei vielä viestejä';

  @override
  String get noSubject => '(ei aihetta)';

  @override
  String get privateMessage => 'Yksityisviesti';

  @override
  String get emailDownloadFailed => 'Tätä sähköpostia ei voitu ladata.';

  @override
  String get refreshInbox => 'Päivitä';

  @override
  String get mailInboxRelays => 'Vastaanottoreleet';

  @override
  String get mailInboxRelaysExplanation =>
      'Uusiin osoitteisiin lähetetyt sähköpostit saapuvat näille releille. Aiemmin luodut osoitteet säilyttävät omansa.';

  @override
  String get mailAddressRelays => 'Osoitteen releet';

  @override
  String get mailAddressRelaysExplanation =>
      'Uudet osoitteet julkaisevat vastaanottoreleensä näillä releillä, joilta silta löytää ne. Aiemmin luodut osoitteet säilyttävät omansa.';

  @override
  String get changeMailRelays => 'Vaihda';

  @override
  String get mailRelaysNeedOne =>
      'Uudet osoitteet tarvitsevat vähintään yhden releen.';

  @override
  String get resetMailRelays => 'Palauta oletukset';

  @override
  String get mailServers => 'Suurten sähköpostien palvelimet';

  @override
  String get mailServersExplanation =>
      'Uudet osoitteet vastaanottavat releelle liian suuret sähköpostit salattuina näille palvelimille. Aiemmin luodut osoitteet säilyttävät omansa.';

  @override
  String get mailServersNeedOne =>
      'Uudet osoitteet tarvitsevat vähintään yhden palvelimen.';
}
