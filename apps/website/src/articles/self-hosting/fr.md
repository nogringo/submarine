---
description: "Gardez une copie de vos coffres sur des serveurs que vous faites tourner vous-même : un relais Nostr pour vos coffres, et un serveur de fichiers pour leurs pièces jointes."
---

# Héberger vos propres serveurs

Submarine n'a pas de serveur à lui : par défaut, vos coffres sont copiés sur des relais Nostr publics, gérés par des opérateurs indépendants. Ajoutez des serveurs que vous faites tourner vous-même, et une copie de votre coffre y reste aussi longtemps que vous le décidez.

## Ce qu'il vous faut

- Une machine joignable depuis Internet, comme un serveur loué ou un ordinateur chez vous.
- Un nom de domaine qui pointe vers elle, avec HTTPS.
- Docker, pour installer les deux serveurs ci-dessous.

## 1. Installez un relais

Installez [nostr-relay](https://github.com/nogringo/nostr-relay) en suivant ses instructions. Contrairement à la plupart des relais, il ne remet les données d'un coffre qu'à qui détient la clé du coffre, et vous laisse les supprimer.

Placez devant lui un proxy HTTPS qui transmet l'en-tête Host d'origine : le relais en a besoin pour vérifier que Submarine détient la clé du coffre.

Son adresse commence par `wss://`, par exemple `wss://relay.example.com`.

## 2. Installez un serveur de fichiers

Les fichiers joints à vos éléments sont gardés sur des serveurs de fichiers, pas sur les relais. Pour en garder aussi votre propre copie, installez [blossom-server](https://github.com/hzrd149/blossom-server) en suivant ses instructions.

Dans son fichier de configuration, mettez `rules: []` sous `storage`. La configuration d'exemple supprime tout fichier que personne n'a ouvert depuis une semaine, ce qui supprimerait vos pièces jointes.

Son adresse commence par `https://`, par exemple `https://blossom.example.com`.

## 3. Ajoutez-les à votre coffre

1. Ouvrez les réglages du coffre et, sous **Synchronisation**, ouvrez **Relais**.
2. Appuyez sur **Ajouter un relais**, saisissez l'adresse de votre relais, activez **Garder privé**, puis appuyez sur **Ajouter**.
3. Appuyez sur **Enregistrer**.
4. De retour dans les réglages du coffre, ouvrez **Serveurs de fichiers**, et ajoutez votre serveur de fichiers de la même façon avec **Ajouter un serveur**.

Faites-le pour chacun de vos coffres. **Garder privé** chiffre l'adresse dans le coffre : sinon, n'importe qui pourrait voir que ce coffre est gardé sur votre serveur, et deviner à qui il appartient.

## Gardez quelques relais publics

Gardez quelques relais publics à côté du vôtre : si votre serveur tombe ou perd ses données, votre coffre y est toujours. Chacun de vos appareils en garde aussi sa propre copie.
