# Politique de confidentialité de l'extension de navigateur Submarine

Dernière mise à jour : 18 octobre 2026.

Submarine est un gestionnaire de mots de passe. Son extension de navigateur affiche les mots de passe, les cartes et les notes de vos coffres, vous permet de les créer et de les modifier, les copie pour vous, remplit vos identifiants sur les sites web et affiche les e-mails envoyés aux adresses e-mail que vous donnez à vos identifiants. Cette politique explique ce que l'extension fait de vos données. En bref : il n'y a pas de serveur Submarine, et l'extension n'envoie rien à ses développeurs.

## Ce qui reste dans votre navigateur

- La clé de chaque coffre que vous créez ou ouvrez, avec le nom et la couleur que vous lui donnez. Ces données sont chiffrées avec une clé propre à ce navigateur, elle-même protégée par votre mot de passe de verrouillage dès que vous en définissez un.
- Une copie du contenu de vos coffres, pour qu'ils s'ouvrent sans attendre le réseau. Elle est chiffrée elle aussi.
- Les messages d'une adresse e-mail, tels qu'ils sont arrivés : chiffrés pour la clé de cette adresse. L'extension les déchiffre chaque fois qu'elle les affiche, et ne les stocke jamais déchiffrés.
- Vos réglages : le délai de verrouillage, le délai du presse-papiers, les options du générateur de mots de passe, ainsi que le pont e-mail, les relais et les serveurs que reçoivent les nouvelles adresses e-mail.
- Un formulaire que vous quittez sans l'enregistrer, pour qu'il réapparaisse quand vous rouvrez l'extension. Il reste dans la mémoire du navigateur, jamais sur le disque, et disparaît dès que vous l'enregistrez, l'abandonnez, verrouillez l'extension ou fermez le navigateur.

Retirer un coffre de l'extension supprime sa clé et sa copie de votre navigateur. Désinstaller l'extension supprime tout ce qu'elle a stocké.

## Ce qui sort de votre navigateur

Vos coffres sont stockés sur des relais Nostr : des serveurs gérés par des opérateurs indépendants, qui stockent des données pour tout le monde. Vos éléments sont chiffrés sur vos appareils avant d'atteindre un relais, donc les relais ne détiennent que des données qu'ils ne peuvent pas lire.

Pour télécharger vos coffres, l'extension se connecte à leurs relais : les relais que liste chaque coffre, ou à défaut les [relais par défaut](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) de Submarine, ainsi que trois relais annuaires où est publiée la liste des relais d'un coffre. Chaque relais voit votre adresse IP, comme tout site web que vous visitez, et la clé publique de chaque coffre que vous ouvrez, avec laquelle l'extension s'identifie et demande les données de ce coffre.

Quand vous créez, modifiez, ajoutez aux favoris, mettez à la corbeille ou restaurez un élément, l'extension chiffre sa nouvelle version sur votre appareil et l'envoie aux relais de son coffre. Quand vous supprimez définitivement un élément, elle demande à ces relais de supprimer chacune de ses versions. Une modification qu'aucun relais n'a encore acceptée attend dans la copie chiffrée de votre navigateur, et elle est renvoyée la prochaine fois que vous ouvrez l'extension ou appuyez sur son bouton de synchronisation.

Le générateur de mots de passe fonctionne dans votre navigateur : ce qu'il génère n'en sort que dans un élément que vous enregistrez.

Quand vous importez un export Bitwarden, l'extension lit dans votre navigateur le fichier que vous choisissez, puis enregistre ses éléments dans le coffre que vous indiquez, comme des éléments que vous créez. Quand vous exportez un coffre, elle enregistre le fichier sur votre ordinateur, chiffré avec le mot de passe que vous choisissez, ou non chiffré si vous désactivez cette option. Le fichier ne va nulle part ailleurs.

Quand vous lui demandez de remplir un identifiant, depuis sa fenêtre ou avec son raccourci clavier, l'extension écrit le nom d'utilisateur et le mot de passe dans le formulaire de connexion de la page actuelle, et seulement si l'adresse de la page correspond à l'identifiant. Le site web les reçoit quand vous vous connectez, comme si vous les aviez tapés.

## Adresses e-mail

Un identifiant peut recevoir sa propre adresse e-mail, comme `npub1...@uid.ovh`, depuis le menu qui ajoute un champ. L'extension crée une nouvelle clé pour chaque adresse, sans lien avec vos coffres, et la garde dans un champ caché de l'identifiant, chiffrée avec le reste de l'élément. Le domaine est celui d'un pont e-mail, `uid.ovh` sauf si vous en choisissez un autre dans les réglages : un serveur géré par un opérateur indépendant, qui reçoit les e-mails envoyés à l'adresse, comme tout serveur de messagerie, les chiffre pour la clé de l'adresse et les transmet aux relais de l'adresse. L'extension n'envoie jamais d'e-mail et ne se connecte jamais au pont.

Quand vous enregistrez un identifiant avec une nouvelle adresse e-mail, l'extension publie trois listes publiques signées avec la clé de l'adresse, pour que le pont sache où livrer : la liste des relais de l'adresse, envoyée à ces relais et aux trois relais annuaires ; celle des relais sur lesquels arrivent ses e-mails ; et celle des serveurs qui reçoivent les e-mails trop gros pour un relais. Ces listes nomment la clé de l'adresse, ses relais et ses serveurs, jamais vos coffres. Par défaut, ce sont les [relais et serveurs e-mail par défaut](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) de Submarine ; vous pouvez changer dans les réglages ceux que reçoivent les nouvelles adresses.

Tant qu'un identifiant avec une adresse e-mail est affiché, l'extension se connecte aux relais de cette adresse, trouvés sur les relais annuaires, s'y identifie avec la clé de l'adresse, télécharge ses derniers messages et reçoit les nouveaux jusqu'à ce que vous fermiez l'identifiant. Chaque relais voit votre adresse IP et la clé publique de l'adresse. L'extension reçoit aussi les messages privés (NIP-17) envoyés à cette clé. Un e-mail trop gros pour un relais est téléchargé, chiffré, quand vous l'ouvrez, depuis l'un des serveurs de l'adresse ou du pont, ou à défaut depuis les serveurs par défaut de Submarine ; ce serveur voit votre adresse IP.

Quand vous enregistrez un e-mail, l'extension écrit le message entier, pièces jointes comprises, dans un fichier sur votre ordinateur. Quand vous supprimez un message, elle demande aux relais de l'adresse de le supprimer. Supprimer définitivement un identifiant ne supprime pas ses messages des relais. Un lien dans un message ne s'ouvre dans un nouvel onglet qu'après votre confirmation, une fois que l'extension vous a montré où il mène.

## Ce que l'extension ne fait pas

- Elle n'a ni compte ni serveur à elle : ses développeurs ne reçoivent aucune donnée de sa part.
- Elle n'envoie jamais d'e-mail, et n'affiche jamais les images ni les autres contenus qu'un e-mail chargerait depuis le web : elle affiche les e-mails en texte brut.
- Elle n'a ni statistiques d'utilisation, ni pistage, ni publicité.
- Elle ne lit rien des pages que vous visitez, sauf les champs de la page actuelle quand vous lui demandez de remplir un identifiant, pour trouver où vont le nom d'utilisateur et le mot de passe. À son ouverture, elle lit l'adresse de l'onglet actuel pour afficher en premier les identifiants de ce site. Ni l'un ni l'autre ne sort de votre navigateur.
- Elle n'écrit dans le presse-papiers que ce que vous copiez, et le code de vérification d'un identifiant qu'elle remplit, puis vide le presse-papiers après le délai choisi dans les réglages. Elle ne lit jamais le presse-papiers.

## Autorisations

- Stockage : garde vos coffres et vos réglages dans votre navigateur, comme décrit ci-dessus.
- Écriture dans le presse-papiers : copie un mot de passe, un code ou tout autre champ quand vous le demandez.
- Alarmes : verrouille les coffres une fois le délai de verrouillage écoulé.
- Onglet actif : donne à l'extension l'onglet sur lequel vous l'ouvrez ou utilisez son raccourci, et seulement celui-là : son adresse, pour afficher en premier les identifiants de ce site, et sa page, pour remplir un identifiant quand vous le demandez.
- Scripts : remplit un identifiant dans la page de cet onglet quand vous le demandez.
- Documents hors écran, dans Chrome uniquement : copie le code de vérification d'un identifiant rempli, et vide le presse-papiers après le délai du presse-papiers, même quand la fenêtre de l'extension est fermée.

## Modifications et contact

Cette politique évolue avec l'extension. Son historique est celui de ce fichier dans le [dépôt Submarine](https://github.com/nogringo/submarine). Pour toute question, ouvrez un [ticket](https://github.com/nogringo/submarine/issues).
