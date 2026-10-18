---
description: "Gardez une copie de vos coffres, et de ceux de vos proches, sur des serveurs que vous faites tourner : un relais Nostr pour les coffres, et un serveur de fichiers pour leurs pièces jointes."
---

# Héberger des serveurs pour vous et vos proches

Submarine n'a pas de serveur à lui : par défaut, vos coffres sont copiés sur des relais Nostr publics, gérés par des opérateurs indépendants. Vous pouvez ajouter des serveurs tenus par vous, ou par une personne de confiance : une copie de votre coffre reste alors chez des gens que vous connaissez.

## Pour vous et vos proches

Un seul serveur peut garder les coffres de tout votre entourage : donnez-leur son adresse, et ils l'ajoutent à leurs coffres comme à l'étape 3.

- Si vous arrêtez votre serveur, ils ne perdent rien : leurs coffres sont toujours sur leurs autres relais, et sur chacun de leurs appareils.
- Votre serveur ne voit que des données chiffrées : il ne peut ni lire leurs mots de passe ni les modifier. Comme tout relais, il voit leur adresse IP.
- Si un ami fait aussi tourner un serveur, ajoutez chacun celui de l'autre : vous gardez ainsi une copie l'un pour l'autre.

## Ce qu'il vous faut

- Une machine joignable depuis Internet, comme un serveur loué ou un ordinateur chez vous.
- Un nom de domaine qui pointe vers elle, avec HTTPS.
- Docker, pour installer les deux serveurs ci-dessous.

## 1. Installez un relais

Installez [nostr-relay](https://github.com/nogringo/nostr-relay) en suivant ses instructions. Contrairement à la plupart des relais, il ne remet les données d'un coffre qu'à qui détient la clé du coffre, et vous laisse les supprimer.

Placez devant lui un proxy HTTPS qui transmet l'en-tête Host d'origine : le relais en a besoin pour vérifier que Submarine détient la clé du coffre.

Son adresse commence par `wss://`, par exemple `wss://relay.example.com`.

## 2. Installez un serveur de fichiers

Les fichiers joints à vos éléments sont gardés sur des serveurs de fichiers, pas sur les relais. Pour en garder aussi une copie, installez [blossom-server](https://github.com/hzrd149/blossom-server) en suivant ses instructions.

Dans son fichier de configuration, ajoutez cette règle en tête des règles sous `storage` :

```yaml
- type: application/octet-stream
  expiration: 100 years
```

Les fichiers chiffrés de Submarine sont alors gardés. Sans cette règle, la configuration d'exemple supprime tout fichier que personne n'a ouvert depuis une semaine.

Son adresse commence par `https://`, par exemple `https://blossom.example.com`.

## 3. Ajoutez-les à votre coffre

1. Ouvrez les réglages du coffre et, sous **Synchronisation**, ouvrez **Relais**.
2. Appuyez sur **Ajouter un relais**, saisissez l'adresse de votre relais, activez **Garder privé**, puis appuyez sur **Ajouter**.
3. Appuyez sur **Enregistrer**.
4. De retour dans les réglages du coffre, ouvrez **Serveurs de fichiers**, et ajoutez votre serveur de fichiers de la même façon avec **Ajouter un serveur**.

Faites-le pour chacun de vos coffres. **Garder privé** chiffre l'adresse dans le coffre : sinon, n'importe qui pourrait voir que ce coffre est gardé sur votre serveur, et deviner à qui il appartient.

## Gardez quelques relais publics

Gardez quelques relais publics à côté du vôtre : si votre serveur tombe ou perd ses données, votre coffre y est toujours. Chacun de vos appareils en garde aussi sa propre copie.
