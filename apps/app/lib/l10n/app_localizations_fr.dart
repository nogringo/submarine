// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get allVaults => 'Tous les coffres';

  @override
  String get vaults => 'Coffres';

  @override
  String get addVault => 'Ajouter un coffre';

  @override
  String get createVault => 'Créer un coffre';

  @override
  String get createVaultDescription =>
      'Un nouveau coffre vide, avec sa propre clé.';

  @override
  String get openVault => 'Ouvrir un coffre';

  @override
  String get openVaultDescription =>
      'Depuis un autre appareil, ou partagé avec vous.';

  @override
  String get openVaultTitle => 'Ouvrir un coffre';

  @override
  String get vaultName => 'Nom';

  @override
  String get vaultNameHelper =>
      'Uniquement sur cet appareil. Une personne avec qui vous partagez le coffre le nomme à sa façon.';

  @override
  String get vaultNameRequired => 'Donnez un nom au coffre.';

  @override
  String get vaultColor => 'Couleur';

  @override
  String vaultColorOption(int number) {
    return 'Couleur $number';
  }

  @override
  String get vaultKey => 'Clé du coffre';

  @override
  String get vaultKeyInvalid => 'Ce n\'est pas une clé de coffre.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Ce coffre est déjà ouvert, sous le nom $name.';
  }

  @override
  String get vaultSaveFailed =>
      'Le coffre n\'a pas pu être enregistré sur cet appareil.';

  @override
  String get saveVaultKeyTitle => 'Sauvegardez la clé du coffre';

  @override
  String get saveVaultKeyBody =>
      'Toute personne qui a cette clé peut ouvrir le coffre. Gardez-la en lieu sûr : il vous la faudra pour ouvrir le coffre sur un autre appareil, ou pour le partager.';

  @override
  String get vaultSettings => 'Réglages du coffre';

  @override
  String get vaultNameAndColor => 'Nom et couleur';

  @override
  String get vaultPublicKey => 'Clé publique';

  @override
  String get vaultKeyDescription =>
      'Toute personne qui la détient peut ouvrir ce coffre. Saisissez-la sur un autre appareil pour y ouvrir le coffre, ou donnez-la à quelqu\'un pour partager le coffre.';

  @override
  String get vaultKeyHelper =>
      'La clé gardée à la création du coffre, ou partagée avec vous.';

  @override
  String get vaultKeyPassword => 'Mot de passe de la clé';

  @override
  String get vaultKeyPasswordWrong => 'Ce mot de passe n\'ouvre pas la clé.';

  @override
  String get vaultKeyDecrypting => 'Déchiffrement de la clé';

  @override
  String get otherWaysToOpen => 'Autres façons de l\'ouvrir';

  @override
  String get signersDescription =>
      'Avec un signeur qui garde la clé hors de Submarine. Une adresse bunker:// se colle aussi dans le champ de la clé.';

  @override
  String get browserExtension => 'Extension de navigateur';

  @override
  String get signerApp => 'Application de signature';

  @override
  String get bunker => 'Bunker';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Scannez ce code avec votre bunker ou votre application de signature, ou collez-y l\'adresse.';

  @override
  String get noBrowserExtension => 'Aucune extension Nostr dans ce navigateur.';

  @override
  String get noSignerApp =>
      'Aucune application de signature, comme Amber, sur cet appareil.';

  @override
  String get signerRefused => 'La demande a été refusée.';

  @override
  String get waitingForAnswer => 'En attente d\'une réponse';

  @override
  String get bunkerUrlInvalid =>
      'Il manque un relais ou un secret à cette adresse de bunker.';

  @override
  String get bunkerNoAnswer => 'Le bunker n\'a pas répondu.';

  @override
  String get bunkerApproval =>
      'Le bunker vous demande d\'approuver Submarine sur sa page.';

  @override
  String get openApprovalPage => 'Ouvrir la page';

  @override
  String get nothingConnected => 'Rien ne s\'est connecté à temps.';

  @override
  String get useAnotherKey => 'Utiliser une autre clé';

  @override
  String get vaultSignerDescription =>
      'Garde la clé du coffre, qui n\'entre jamais dans Submarine. Sur un autre appareil, ouvrez le coffre de la même façon.';

  @override
  String get askSignerAtStart => 'Demander au signeur à chaque ouverture';

  @override
  String get askSignerAtStartDescription =>
      'Désactivé, une clé gardée sur cet appareil lit le coffre même quand le signeur est injoignable. Activé, le coffre reste fermé tant que le signeur ne l\'a pas ouvert.';

  @override
  String get askSignerFailed => 'Le signeur a refusé ou a échoué.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes attendent votre signeur',
      one: '1 demande attend votre signeur',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'En attente de votre signeur';

  @override
  String get signerRequestsDescription =>
      'Validez ces demandes dans votre signeur, ou annulez-les.';

  @override
  String get requestOpenVault => 'Ouvrir le coffre';

  @override
  String get requestLockVault => 'Verrouiller le coffre derrière le signeur';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déchiffrer $count versions d\'éléments',
      one: 'Déchiffrer une version d\'un élément',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enregistrer $count versions d\'éléments',
      one: 'Enregistrer une version d\'un élément',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer définitivement $count versions d\'éléments',
      one: 'Supprimer définitivement une version d\'un élément',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Enregistrer la liste des relais';

  @override
  String get requestReadRelays => 'Lire les relais privés';

  @override
  String get requestEncryptRelays => 'Chiffrer les relais privés';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'identifier auprès de $count relais',
      one: 'S\'identifier auprès d\'un relais',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres demandes ($method)',
      one: 'Autre demande ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Tout annuler';

  @override
  String get close => 'Fermer';

  @override
  String get sync => 'Synchronisation';

  @override
  String get syncAllSent =>
      'Toutes vos modifications sont enregistrées en ligne.';

  @override
  String get relays => 'Relais';

  @override
  String get relaysDescription =>
      'Ce coffre est copié sur chacun de ces relais. Ils ne voient que des données chiffrées et sa clé publique.';

  @override
  String get relayConnected => 'Connecté';

  @override
  String get relayNotConnected => 'Non connecté';

  @override
  String get relayPrivate => 'Privé';

  @override
  String get removeRelay => 'Retirer ce relais';

  @override
  String get addRelay => 'Ajouter un relais';

  @override
  String get relayAddress => 'Adresse du relais';

  @override
  String get relayAddressInvalid => 'Ce n\'est pas une adresse de relais.';

  @override
  String get relayAlreadyListed => 'Ce relais est déjà dans la liste.';

  @override
  String get relayKeepPrivate => 'Garder privé';

  @override
  String get relayKeepPrivateDescription =>
      'Chiffré dans la liste des relais du coffre : seuls ceux qui ont la clé du coffre savent qu\'il s\'y trouve.';

  @override
  String get relaysSaveFailed => 'Les relais n\'ont pas pu être enregistrés.';

  @override
  String get relaysWaitForSync =>
      'Vous pourrez changer les relais une fois le coffre synchronisé.';

  @override
  String get relayAdded => 'Nouveau';

  @override
  String get relayRemoved => 'Retiré';

  @override
  String get keepRelay => 'Garder ce relais';

  @override
  String get relaysNeedOne => 'Le coffre a besoin d\'au moins un relais.';

  @override
  String get add => 'Ajouter';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get open => 'Ouvrir';

  @override
  String get done => 'Terminé';

  @override
  String get welcomeTagline =>
      'Vos mots de passe, chiffrés et synchronisés. Sans compte.';

  @override
  String get builtOnNostr => 'Basé sur Nostr';

  @override
  String get builtOnNostrBody =>
      'Vos coffres sont stockés sur des relais Nostr : des serveurs ouverts, que tout le monde peut faire tourner, et qui ne voient que des données chiffrées. La clé d\'un coffre est une clé Nostr : un signeur Nostr peut donc la garder.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
      zero: 'Aucun élément',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get syncing => 'Synchronisation';

  @override
  String get syncNever => 'Jamais synchronisé';

  @override
  String get syncFailed => 'Synchronisation impossible';

  @override
  String get signerDidNotOpen => 'Le signeur n\'a pas ouvert le coffre';

  @override
  String get syncedJustNow => 'Synchronisé à l\'instant';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Synchronisé il y a $minutes min';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Synchronisé il y a $hours h';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Synchronisé le $dateString';
  }

  @override
  String get noItems => 'Aucun élément dans ce coffre pour l\'instant.';

  @override
  String get lookingForItems => 'Recherche de vos éléments';

  @override
  String get signerDidNotOpenVault =>
      'Le signeur n\'a pas ouvert ce coffre. Synchronisez pour le lui redemander.';

  @override
  String get selectItem => 'Sélectionnez un élément pour l\'afficher ici.';

  @override
  String get itemNotFound => 'Cet élément n\'est plus dans le coffre.';

  @override
  String get typeLogin => 'Identifiant';

  @override
  String get typeSecureNote => 'Note sécurisée';

  @override
  String get typeCard => 'Carte';

  @override
  String get typeIdentity => 'Identité';

  @override
  String get typeSshKey => 'Clé SSH';

  @override
  String get typeBankAccount => 'Compte bancaire';

  @override
  String get typeDriversLicense => 'Permis de conduire';

  @override
  String get typePassport => 'Passeport';

  @override
  String get typeUnknown => 'Élément';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Copié';

  @override
  String get show => 'Afficher';

  @override
  String get hide => 'Masquer';

  @override
  String get hiddenValue => 'Valeur masquée';

  @override
  String get openWebsite => 'Ouvrir le site';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get totpInvalid => 'Cette clé de vérification est illisible.';

  @override
  String get website => 'Site web';

  @override
  String get passkey => 'Clé d\'accès';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Créée le $dateString';
  }

  @override
  String get notes => 'Notes';

  @override
  String get customFields => 'Champs personnalisés';

  @override
  String get passwordHistory => 'Historique des mots de passe';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Modifié le $updatedString, créé le $createdString';
  }

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String linkedTo(String field) {
    return 'Lié à $field';
  }

  @override
  String get cardholderName => 'Titulaire de la carte';

  @override
  String get cardBrand => 'Marque';

  @override
  String get cardNumber => 'Numéro';

  @override
  String get cardExpiration => 'Expiration';

  @override
  String get cardExpMonth => 'Mois d\'expiration';

  @override
  String get cardExpYear => 'Année d\'expiration';

  @override
  String get cardCode => 'Code de sécurité';

  @override
  String get fullName => 'Nom';

  @override
  String get identityTitle => 'Civilité';

  @override
  String get firstName => 'Prénom';

  @override
  String get middleName => 'Deuxième prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get company => 'Société';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get city => 'Ville';

  @override
  String get state => 'État ou région';

  @override
  String get postalCode => 'Code postal';

  @override
  String get country => 'Pays';

  @override
  String get ssn => 'Numéro de sécurité sociale';

  @override
  String get passportNumber => 'Numéro de passeport';

  @override
  String get licenseNumber => 'Numéro de permis';

  @override
  String get privateKey => 'Clé privée';

  @override
  String get publicKey => 'Clé publique';

  @override
  String get fingerprint => 'Empreinte';

  @override
  String get bankName => 'Banque';

  @override
  String get accountHolder => 'Titulaire du compte';

  @override
  String get accountType => 'Type de compte';

  @override
  String get accountNumber => 'Numéro de compte';

  @override
  String get routingNumber => 'Numéro de routage';

  @override
  String get branchNumber => 'Code guichet';

  @override
  String get pin => 'Code PIN';

  @override
  String get swiftCode => 'Code SWIFT';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Téléphone de la banque';

  @override
  String get accountTypeChecking => 'Compte courant';

  @override
  String get accountTypeSavings => 'Épargne';

  @override
  String get accountTypeCertificateOfDeposit => 'Compte à terme';

  @override
  String get accountTypeLineOfCredit => 'Ligne de crédit';

  @override
  String get accountTypeInvestmentBrokerage => 'Compte-titres';

  @override
  String get accountTypeMoneyMarket => 'Marché monétaire';

  @override
  String get accountTypeOther => 'Autre';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get issuingCountry => 'Pays de délivrance';

  @override
  String get issuingState => 'Région de délivrance';

  @override
  String get issueDate => 'Date de délivrance';

  @override
  String get expirationDate => 'Date d\'expiration';

  @override
  String get issuingAuthority => 'Autorité de délivrance';

  @override
  String get licenseClass => 'Catégorie';

  @override
  String get surname => 'Nom';

  @override
  String get givenName => 'Prénom';

  @override
  String get sex => 'Sexe';

  @override
  String get birthPlace => 'Lieu de naissance';

  @override
  String get nationality => 'Nationalité';

  @override
  String get passportType => 'Type';

  @override
  String get nationalId => 'Numéro d\'identification national';

  @override
  String get filterAllItems => 'Tous les éléments';

  @override
  String get filterAllShort => 'Tous';

  @override
  String get filterFavorites => 'Favoris';

  @override
  String get filterLogins => 'Identifiants';

  @override
  String get filterSecureNotes => 'Notes sécurisées';

  @override
  String get filterCards => 'Cartes';

  @override
  String get filterIdentities => 'Identités';

  @override
  String get filterSshKeys => 'Clés SSH';

  @override
  String get filterBankAccounts => 'Comptes bancaires';

  @override
  String get filterDriversLicenses => 'Permis de conduire';

  @override
  String get filterPassports => 'Passeports';

  @override
  String get filterTrash => 'Corbeille';

  @override
  String get noItemsHere => 'Aucun élément ici.';

  @override
  String get searchItems => 'Rechercher';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get noSearchResults =>
      'Aucun élément ne correspond à votre recherche.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications pas encore envoyées',
      one: '1 modification pas encore envoyée',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Nouvel élément';

  @override
  String get newLogin => 'Nouvel identifiant';

  @override
  String get newCard => 'Nouvelle carte';

  @override
  String get newSecureNote => 'Nouvelle note sécurisée';

  @override
  String get editItem => 'Modifier l\'élément';

  @override
  String get edit => 'Modifier';

  @override
  String get save => 'Enregistrer';

  @override
  String get itemSaveFailed => 'L\'élément n\'a pas pu être enregistré.';

  @override
  String get vault => 'Coffre';

  @override
  String get itemName => 'Nom';

  @override
  String get itemNameRequired => 'Donnez un nom à l\'élément.';

  @override
  String get authenticatorKey => 'Clé d\'authentification';

  @override
  String get authenticatorKeyHint => 'Secret base32 ou URI otpauth://';

  @override
  String get addWebsite => 'Ajouter un site web';

  @override
  String get addField => 'Ajouter un champ';

  @override
  String get customField => 'Champ personnalisé';

  @override
  String get editField => 'Modifier le champ';

  @override
  String get fieldType => 'Type de champ';

  @override
  String get fieldTypeText => 'Texte';

  @override
  String get fieldTypeHidden => 'Masqué';

  @override
  String get fieldTypeCheckbox => 'Case à cocher';

  @override
  String get fieldTypeLinked => 'Lié';

  @override
  String get textFieldHelp =>
      'Utilisez les champs texte pour des données comme les questions de sécurité.';

  @override
  String get hiddenFieldHelp =>
      'Utilisez les champs masqués pour des données sensibles comme un mot de passe.';

  @override
  String get checkboxFieldHelp =>
      'Utilisez les cases à cocher pour remplir la case d\'un formulaire, comme se souvenir de mon e-mail.';

  @override
  String get linkedFieldHelp =>
      'Utilisez un champ lié quand le remplissage automatique a du mal avec un site précis.';

  @override
  String get fieldLabel => 'Étiquette du champ';

  @override
  String get linkedFieldLabelHelp =>
      'Saisissez l\'id HTML, le name, l\'aria-label ou le placeholder du champ.';

  @override
  String editFieldNamed(String field) {
    return 'Modifier $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return 'Supprimer $field';
  }

  @override
  String reorderField(String field) {
    return 'Déplacer $field';
  }

  @override
  String get cardBrandOther => 'Autre';

  @override
  String get cardExpYearHint => 'AAAA';

  @override
  String get notSet => 'Non renseigné';

  @override
  String get favorite => 'Favori';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get discardChanges => 'Abandonner vos modifications ?';

  @override
  String get keepEditing => 'Continuer la modification';

  @override
  String get discard => 'Abandonner';

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String get copyUsername => 'Copier le nom d\'utilisateur';

  @override
  String get copyPassword => 'Copier le mot de passe';

  @override
  String get copyTotp => 'Copier le code de vérification';

  @override
  String get copyNumber => 'Copier le numéro';

  @override
  String get moveToTrash => 'Mettre à la corbeille';

  @override
  String get restore => 'Restaurer';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String get deleteItemTitle => 'Supprimer définitivement cet élément ?';

  @override
  String get deleteItemBody =>
      'Il sera effacé du coffre, sur tous les appareils. Vous ne pourrez pas revenir en arrière.';

  @override
  String get delete => 'Supprimer';

  @override
  String get generatePassword => 'Générer un mot de passe';

  @override
  String get generateUsername => 'Générer un nom d\'utilisateur';

  @override
  String get generator => 'Générateur';

  @override
  String get passphrase => 'Phrase de passe';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get passwordLength => 'Longueur';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères',
      one: '1 caractère',
    );
    return '$_temp0';
  }

  @override
  String get includeCharacters => 'Inclure';

  @override
  String get uppercaseLetters => 'Lettres majuscules';

  @override
  String get lowercaseLetters => 'Lettres minuscules';

  @override
  String get digits => 'Chiffres';

  @override
  String get specialCharacters => 'Caractères spéciaux';

  @override
  String get minNumbers => 'Minimum de chiffres';

  @override
  String get minSpecial => 'Minimum de caractères spéciaux';

  @override
  String get avoidAmbiguous => 'Éviter les caractères ambigus';

  @override
  String get numberOfWords => 'Nombre de mots';

  @override
  String get wordSeparator => 'Séparateur de mots';

  @override
  String get capitalize => 'Majuscule à chaque mot';

  @override
  String get includeNumber => 'Inclure un chiffre';

  @override
  String get usePassword => 'Utiliser ce mot de passe';

  @override
  String get usePassphrase => 'Utiliser cette phrase de passe';

  @override
  String get useUsername => 'Utiliser ce nom d\'utilisateur';

  @override
  String get usernameCapitalize => 'Commencer par une majuscule';

  @override
  String get usernameIncludeNumber => 'Inclure un nombre';

  @override
  String get decrease => 'Diminuer';

  @override
  String get increase => 'Augmenter';

  @override
  String get settings => 'Réglages';

  @override
  String get security => 'Sécurité';

  @override
  String get unlockWithBiometrics => 'Déverrouiller avec la biométrie';

  @override
  String get unlockWithBiometricsDescription =>
      'Ou avec le code ou le mot de passe de cet appareil. Les clés des coffres restent dans son stockage sécurisé.';

  @override
  String get lockNeedsScreenLock =>
      'Configurez d\'abord un verrouillage de l\'écran sur cet appareil.';

  @override
  String get lockAfter => 'Verrouiller après';

  @override
  String get lockImmediately => 'Immédiatement';

  @override
  String get lockOnRestart => 'Au redémarrage de l\'application';

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
      other: '$count heures',
      one: '1 heure',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'Effacer les mots de passe copiés après';

  @override
  String get never => 'Jamais';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondes',
      one: '1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Autoriser la capture d\'écran';

  @override
  String get allowScreenCaptureDescription =>
      'Permet aux captures, aux enregistrements et au partage d\'écran de montrer vos mots de passe.';

  @override
  String get lock => 'Verrouiller';

  @override
  String lockWithShortcut(String shortcut) {
    return 'Verrouiller ($shortcut)';
  }

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get vaultsLocked => 'Vos coffres sont verrouillés.';

  @override
  String get unlockReason => 'Déverrouiller vos coffres';

  @override
  String get enableLockReason => 'Activer le verrouillage';

  @override
  String get authLockedOut => 'Trop de tentatives. Réessayez plus tard.';

  @override
  String get authFailed => 'Cet appareil n\'a pas pu vérifier que c\'est vous.';

  @override
  String get vaultTab => 'Coffre';

  @override
  String get storageReadFailed => 'Vos coffres n\'ont pas pu être lus.';

  @override
  String get storageReadFailedBody =>
      'Le stockage sécurisé de cet appareil a refusé de les ouvrir. Rien n\'a été effacé : réessayez. Vos éléments restent en ligne, et la clé d\'un coffre l\'ouvre sur n\'importe quel appareil.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageName => 'Français';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get importExport => 'Importer et exporter';

  @override
  String get importFromBitwarden => 'Importer depuis Bitwarden';

  @override
  String get importFromBitwardenDescription => 'Un export JSON de Bitwarden.';

  @override
  String get importButton => 'Importer';

  @override
  String get importReadFailed => 'Le fichier n\'a pas pu être lu.';

  @override
  String get importNotBitwarden =>
      'Ce fichier n\'est pas un export JSON de Bitwarden.';

  @override
  String get importEncrypted =>
      'Cet export est restreint à votre compte Bitwarden, et seul Bitwarden peut l\'ouvrir. Exportez à nouveau votre coffre depuis Bitwarden, protégé par mot de passe ou au format .json.';

  @override
  String get importEmpty => 'Cet export ne contient aucun élément.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments trouvés dans $file.',
      one: '1 élément trouvé dans $file.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done éléments importés sur $total';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments importés dans $vault.',
      one: '1 élément importé dans $vault.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'L\'import s\'est arrêté : $done éléments sur $total ont été enregistrés.';
  }

  @override
  String get exportVault => 'Exporter un coffre';

  @override
  String get exportVaultDescription =>
      'Un fichier JSON Bitwarden, protégé par un mot de passe ou non chiffré.';

  @override
  String get exportButton => 'Exporter';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments. La corbeille n\'est pas exportée.',
      one: '1 élément. La corbeille n\'est pas exportée.',
      zero: 'Ce coffre n\'a aucun élément à exporter.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'Le fichier n\'est pas chiffré. Ne l\'envoyez pas par e-mail, et supprimez-le dès que vous n\'en avez plus besoin.';

  @override
  String get exportFailed => 'Le fichier n\'a pas pu être enregistré.';

  @override
  String get importPasswordBody =>
      'Cet export est protégé par un mot de passe. Saisissez-le pour ouvrir le fichier.';

  @override
  String get filePassword => 'Mot de passe du fichier';

  @override
  String get wrongFilePassword => 'Ce mot de passe n\'ouvre pas le fichier.';

  @override
  String get exportProtect => 'Protéger par un mot de passe';

  @override
  String get confirmFilePassword => 'Confirmez le mot de passe du fichier';

  @override
  String get filePasswordHelper =>
      'Submarine et Bitwarden le demandent pour importer le fichier. Il ne peut pas être récupéré.';

  @override
  String get filePasswordRequired => 'Choisissez un mot de passe.';

  @override
  String get filePasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get lockPassword => 'Mot de passe de verrouillage';

  @override
  String get lockPasswordDescription =>
      'Chiffre les clés des coffres sur cet appareil, et déverrouille l\'application. Il ne peut pas être récupéré.';

  @override
  String get setLockPassword => 'Définir';

  @override
  String get changeLockPassword => 'Changer';

  @override
  String get removeLockPassword => 'Retirer';

  @override
  String get setLockPasswordTitle => 'Définir un mot de passe de verrouillage';

  @override
  String get changeLockPasswordTitle =>
      'Changer le mot de passe de verrouillage';

  @override
  String get removeLockPasswordTitle =>
      'Retirer le mot de passe de verrouillage';

  @override
  String get removeLockPasswordBody =>
      'L\'application ne le demande plus. Les clés des coffres de cet appareil ne reposent alors plus que sur son stockage sécurisé.';

  @override
  String get currentLockPassword => 'Mot de passe actuel';

  @override
  String get newLockPassword => 'Nouveau mot de passe';

  @override
  String get confirmLockPassword => 'Confirmez le mot de passe';

  @override
  String lockPasswordHelper(int count) {
    return 'Au moins $count caractères. L\'oublier retire les coffres de cet appareil.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Au moins $count caractères.';
  }

  @override
  String get lockPasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get wrongLockPassword =>
      'Ce n\'est pas le mot de passe de verrouillage.';

  @override
  String get generatePassphrase => 'Générer une phrase de passe';

  @override
  String get unlockWithBiometricsWithPassword =>
      'Plutôt que de taper le mot de passe de verrouillage, qui reste valable.';

  @override
  String get forgotLockPassword => 'Mot de passe oublié ?';

  @override
  String get forgetVaultsTitle => 'Retirer les coffres de cet appareil ?';

  @override
  String get forgetVaultsBody =>
      'Sans le mot de passe de verrouillage, ils ne peuvent pas être déchiffrés ici. Vos éléments restent en ligne : rouvrez chaque coffre avec sa clé.';

  @override
  String get forgetVaults => 'Retirer les coffres';

  @override
  String get removeVault => 'Retirer de cet appareil';

  @override
  String get removeVaultDescription =>
      'Le coffre reste en ligne, pour que vous puissiez le rouvrir.';

  @override
  String removeVaultTitle(String name) {
    return 'Retirer $name de cet appareil ?';
  }

  @override
  String get removeVaultBody =>
      'Vos éléments restent en ligne : rouvrez le coffre pour les retrouver.';

  @override
  String get removeVaultKeyWarning =>
      'Gardez d\'abord sa clé : sans elle, vous ne pourrez pas rouvrir le coffre.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count modifications ne sont pas encore envoyées et seront perdues.',
      one: '1 modification n\'est pas encore envoyée et sera perdue.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Retirer';

  @override
  String get removeVaultFailed => 'Le coffre n\'a pas pu être retiré.';
}
