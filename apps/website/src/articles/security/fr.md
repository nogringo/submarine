---
description: "Comment Submarine protège vos mots de passe : chiffrés sur vos appareils, gardés par des serveurs ouverts qui ne voient que des données chiffrées, ouverts par une clé qui n'appartient qu'à vous."
---

# Comment Submarine protège vos mots de passe

Submarine chiffre votre coffre sur vos appareils, avant que quoi que ce soit n'en sorte. Les serveurs qui le gardent ne voient jamais que des données chiffrées, et il n'y a ni compte Submarine ni serveur Submarine entre les deux. Cette page explique ce qui est protégé, comment, et ce qui n'est pas encore fait.

## La clé de votre coffre

Chaque coffre a sa propre clé, créée sur votre appareil quand vous créez le coffre. Qui détient cette clé peut ouvrir le coffre, et personne d'autre ne le peut : ni les serveurs, ni nous.

- Submarine vous montre la clé quand vous créez le coffre. Gardez-la en lieu sûr, par exemple sur papier ou dans un gestionnaire de mots de passe que vous utilisez déjà.
- Vous pouvez aussi la garder chiffrée avec un mot de passe de votre choix. Il vous faut alors la clé chiffrée et son mot de passe pour ouvrir le coffre.
- Personne ne peut récupérer une clé perdue. Il n'y a ni compte ni lien de réinitialisation : gardez une copie de la clé, ou de la clé chiffrée et de son mot de passe.

## Sur vos appareils

- Vos coffres sont chiffrés sur chaque appareil, avec une clé propre à cet appareil.
- Votre mot de passe de verrouillage protège cette clé. Submarine le transforme en clé avec Argon2id, une méthode conçue pour rendre lent et coûteux le fait de deviner un mot de passe. Un mot de passe de verrouillage oublié ne se récupère pas non plus : vous rouvrez alors vos coffres avec leurs clés.
- Votre empreinte, votre visage ou le verrouillage de l'écran peuvent déverrouiller Submarine à la place du mot de passe de verrouillage.
- Submarine se verrouille après le délai que vous choisissez, de tout de suite à quelques heures, et efface vos coffres de la mémoire en se verrouillant.
- Les mots de passe copiés sont effacés du presse-papiers après le délai que vous choisissez.
- Sur Android, les captures et enregistrements d'écran de Submarine sont bloqués, sauf si vous les autorisez.

## Sur les serveurs

Vos coffres sont gardés sur des relais Nostr : des serveurs ouverts, gérés par des opérateurs indépendants, que tout le monde peut utiliser ou faire tourner. Chaque coffre est copié sur plusieurs relais, il survit donc à la panne de l'un d'eux, et c'est vous qui choisissez les relais qui le gardent, y compris le vôtre.

Chaque modification que vous faites est chiffrée sur votre appareil et envoyée aux relais dans une enveloppe scellée. Un relais voit :

- des données chiffrées qu'il ne peut pas lire,
- la clé publique du coffre, qui lui indique quelles enveloppes vont ensemble, mais pas ce qu'elles contiennent,
- une date tirée au hasard dans les deux jours qui précèdent la modification, et non l'heure de la modification,
- votre adresse IP, comme tout site web que vous visitez.

Un relais ne peut pas non plus modifier vos mots de passe. Chaque modification est signée avec la clé du coffre, et Submarine ignore tout ce que le coffre n'a pas signé.

## Ni compte, ni pistage

- Il n'y a pas de compte Submarine, et aucun serveur Submarine ne détient vos données.
- Submarine ne contient ni statistiques d'usage, ni rapports de plantage, ni publicité.
- Le code est open source, sous licence MIT : tout le monde peut vérifier ce que fait Submarine. [Voir le code source](https://github.com/nogringo/submarine).

## Pas encore fait

Aucune société indépendante n'a encore audité la sécurité de Submarine. En attendant, gardez vos mots de passe les plus critiques, comme ceux de votre messagerie et de votre banque, dans un gestionnaire de mots de passe plus éprouvé, et commencez par les autres.

Si vous trouvez un problème de sécurité, merci de [le signaler](https://github.com/nogringo/submarine/issues) ou de [nous contacter sur Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Détails techniques

Le format complet est décrit dans le [protocole Nostr Passwords](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords).

- Un coffre est une paire de clés Nostr. Sa clé s'affiche sous forme de `nsec`, et sa forme chiffrée est un `ncryptsec` NIP-49 (scrypt, puis XChaCha20-Poly1305).
- Chaque modification est une nouvelle version de l'élément : un événement signé par le coffre, chiffré pour le coffre avec NIP-44 (ChaCha20 et HMAC-SHA256, avec un remplissage qui masque la longueur exacte) et placé dans un gift wrap NIP-59, signé par une clé à usage unique et daté au hasard dans les deux jours précédents.
- Les éléments sont des éléments Bitwarden : c'est pourquoi Submarine importe et exporte le format de Bitwarden.
- Sur un appareil, les clés des coffres sont chiffrées avec AES-256-CBC et HMAC-SHA256 sous une clé d'appareil. Cette clé est protégée par le mot de passe de verrouillage via Argon2id, ou gardée dans le stockage sécurisé du système. La copie locale des coffres est chiffrée avec AES-256-GCM.
- Si vous utilisez Nostr, un signataire peut détenir la clé du coffre pour qu'elle n'entre jamais dans Submarine : un bunker (NIP-46), une application de signature comme Amber (NIP-55) ou une extension de navigateur (NIP-07).
