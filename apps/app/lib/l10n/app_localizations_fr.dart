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
  String get openVault => 'Ouvrir un coffre avec sa clé';

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
  String get vaultKeyInvalid =>
      'Ce n\'est pas une clé de coffre. Elle commence par nsec1.';

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
  String get sync => 'Synchronisation';

  @override
  String get syncAllSent => 'Toutes vos modifications sont sur vos relais.';

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
      'Un gestionnaire de mots de passe bâti sur Nostr.';

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
  String get syncFailed => 'Relais injoignables';

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
  String get lookingForItems => 'Recherche des éléments sur les relais';

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
  String searchItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rechercher parmi $count éléments',
      one: 'Rechercher dans 1 élément',
      zero: 'Rechercher',
    );
    return '$_temp0';
  }

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
  String get moveToTrash => 'Mettre à la corbeille';

  @override
  String get restore => 'Restaurer';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String get deleteItemTitle => 'Supprimer définitivement cet élément ?';

  @override
  String get deleteItemBody =>
      'Il sera effacé de cet appareil et de vos relais. Vous ne pourrez pas revenir en arrière.';

  @override
  String get delete => 'Supprimer';
}
