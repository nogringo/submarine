---
description: "Transférez vos mots de passe de Bitwarden vers Submarine en quelques minutes, avec leurs champs personnalisés et leurs codes de vérification, et récupérez-les quand vous voulez."
---

# Importer vos mots de passe depuis Bitwarden

Submarine lit le fichier d'export de Bitwarden : transférer vos mots de passe prend quelques minutes. Rien ne change dans votre compte Bitwarden, l'import ne fait que copier vos éléments.

## 1. Exportez votre coffre depuis Bitwarden

1. Dans le coffre web de Bitwarden, ouvrez Outils, puis Exporter le coffre. Les applications Bitwarden ont la même commande dans leurs paramètres ou leurs menus.
2. Choisissez le format .json. Vous pouvez aussi choisir le format .json chiffré, protégé par un mot de passe de votre choix : Submarine l'ouvre aussi.
3. Confirmez avec votre mot de passe principal Bitwarden, puis enregistrez le fichier.

Un export chiffré restreint à votre compte Bitwarden ne fonctionne pas : seul Bitwarden peut l'ouvrir. Choisissez plutôt le type protégé par mot de passe.

## 2. Importez le fichier dans Submarine

1. Ouvrez Submarine, puis créez ou ouvrez le coffre qui doit recevoir vos mots de passe.
2. Allez dans **Réglages**, puis **Importer et exporter**, et appuyez sur **Importer** à côté de **Importer depuis Bitwarden**.
3. Choisissez le fichier. S'il est protégé par un mot de passe, saisissez ce mot de passe.
4. Vérifiez le nombre d'éléments trouvés, choisissez le coffre si vous en avez plusieurs, et appuyez sur **Importer**.

Vos éléments sont chiffrés sur votre appareil, puis synchronisés avec vos autres appareils comme toute autre modification.

## 3. Supprimez le fichier d'export

Un export .json sans mot de passe n'est pas chiffré : quiconque le récupère peut lire tous vos mots de passe. Supprimez-le une fois l'import terminé, et videz la corbeille de votre ordinateur. Ne l'envoyez pas par e-mail.

## Ce qui est importé

- Les identifiants, cartes, notes sécurisées, identités, clés SSH et les autres types d'éléments de Bitwarden, avec leurs champs personnalisés et leurs codes de vérification.
- Les identifiants, cartes et notes sécurisées se modifient dans Submarine. Les autres types sont conservés et affichés, mais ne se modifient pas encore.
- Les clés d'accès sont conservées et affichées, mais Submarine ne peut pas encore s'en servir pour vous connecter.
- Les dossiers ne sont pas importés : Submarine sépare les éléments par coffre.
- Les fichiers joints ne font pas partie de l'export de Bitwarden : ils restent dans Bitwarden.

## Si vous venez d'un autre gestionnaire de mots de passe

Submarine ne lit que le format de Bitwarden. Bitwarden, lui, importe depuis la plupart des gestionnaires de mots de passe, comme 1Password, LastPass, KeePass ou votre navigateur. Avec un compte Bitwarden gratuit, importez-y d'abord vos mots de passe, puis suivez les étapes ci-dessus.

## Quitter Submarine

Submarine exporte dans le même format. Dans **Réglages**, puis **Importer et exporter**, **Exporter un coffre** enregistre un fichier Bitwarden, protégé par un mot de passe ou non chiffré, que Bitwarden et d'autres gestionnaires de mots de passe savent importer. La corbeille n'est pas exportée.

Vous découvrez Submarine ? [Téléchargez-le](/fr/download), ou lisez [comment il protège vos mots de passe](/fr/security).
