---
description: "Réponses aux questions fréquentes sur Submarine, le gestionnaire de mots de passe sans compte : clé perdue, serveur en panne, hors ligne, partage d'un coffre, prix."
---

# Questions et réponses

## Et si je perds la clé de mon coffre ?

Personne ne peut la récupérer, pas même nous : il n'y a ni compte ni lien de réinitialisation. Si Submarine est encore ouvert sur l'un de vos appareils, copiez la clé depuis les réglages du coffre et gardez-la en lieu sûr. Sinon, le coffre ne pourra plus être ouvert.

## Et si un serveur ferme ?

Chaque coffre est copié sur plusieurs relais, et chacun de vos appareils en garde sa propre copie. Si un relais tombe, les autres ont toujours votre coffre. Vous pouvez ajouter ou retirer des relais dans les réglages du coffre, sous Synchronisation.

## Qui gère les serveurs ?

Les relais Nostr sont gérés par des opérateurs indépendants, pour toutes les applications qui utilisent Nostr, pas seulement Submarine. Ils ne voient que des données chiffrées. Vous pouvez aussi faire tourner votre propre relais et l'ajouter à votre coffre.

## Submarine fonctionne-t-il hors ligne ?

Oui. Chaque modification est d'abord enregistrée sur votre appareil, puis synchronisée dès que vous êtes de nouveau en ligne. Submarine indique combien de modifications attendent encore d'être envoyées.

## Puis-je l'utiliser sur plusieurs appareils ?

Oui : sur Android, Windows, macOS et Linux, et sur le web pour tous les autres appareils. Ouvrez votre coffre sur chacun d'eux avec la même clé. [Télécharger Submarine](/fr/download).

## Puis-je partager un coffre ?

Oui. Donnez la clé du coffre à la personne avec qui vous le partagez : qui la détient peut ouvrir et modifier le coffre. Une clé donnée ne se reprend pas, alors gardez les mots de passe partagés dans un coffre à part, séparé de vos mots de passe personnels.

## Et si je modifie le même élément sur deux appareils en même temps ?

Les deux modifications sont conservées. Submarine n'écrase jamais l'une par l'autre en silence.

## Submarine est-il gratuit ?

Oui. Il n'y a rien à payer, ni version premium, ni publicité. Submarine est open source, sous licence MIT.

## En quoi est-il différent des autres gestionnaires de mots de passe ?

Avec la plupart des gestionnaires de mots de passe, votre coffre vit sur les serveurs de l'entreprise qui les fait, derrière un compte. Submarine n'a ni compte ni serveur à lui : votre coffre est copié sur des serveurs ouverts que vous choisissez, et seule votre clé l'ouvre. La contrepartie, c'est que personne ne peut récupérer une clé perdue. Submarine est aussi plus jeune, et pas encore audité.

## Puis-je importer mes mots de passe ?

Oui, depuis Bitwarden, et depuis la plupart des autres gestionnaires de mots de passe en passant par Bitwarden. [Importer depuis Bitwarden](/fr/import-bitwarden). Vous pouvez exporter vos coffres à tout moment, dans un format que d'autres gestionnaires de mots de passe savent importer.

## Submarine est-il sûr ?

Votre coffre est chiffré sur vos appareils, et les serveurs ne voient que des données chiffrées. En revanche, aucune société indépendante n'a encore audité Submarine. [Comment Submarine protège vos mots de passe](/fr/security).

## Qu'est-ce que Nostr ?

Un protocole ouvert pour échanger des données par des relais : des serveurs que tout le monde peut faire tourner. Submarine s'en sert pour synchroniser votre coffre sans entreprise au milieu. Pas besoin de connaître Nostr, ni d'avoir un compte Nostr, pour utiliser Submarine.

## Comment signaler un problème ?

[Signalez-le sur GitHub](https://github.com/nogringo/submarine/issues), ou [contactez-nous sur Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).
