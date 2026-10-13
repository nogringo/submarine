# Politique de confidentialité de l'extension de navigateur Submarine

Dernière mise à jour : 12 octobre 2026.

Submarine est un gestionnaire de mots de passe. Son extension de navigateur affiche les mots de passe, les cartes et les notes de vos coffres, vous permet de les créer et de les modifier, les copie pour vous et remplit vos identifiants sur les sites web. Cette politique explique ce que l'extension fait de vos données. En bref : il n'y a pas de serveur Submarine, et l'extension n'envoie rien à ses développeurs.

## Ce qui reste dans votre navigateur

- La clé de chaque coffre que vous ouvrez, avec le nom et la couleur que vous lui donnez. Ces données sont chiffrées avec une clé propre à ce navigateur, elle-même protégée par votre mot de passe de verrouillage dès que vous en définissez un.
- Une copie du contenu de vos coffres, pour qu'ils s'ouvrent sans attendre le réseau. Elle est chiffrée elle aussi.
- Vos réglages : le délai de verrouillage, le délai du presse-papiers et les options du générateur de mots de passe.
- Un formulaire que vous quittez sans l'enregistrer, pour qu'il réapparaisse quand vous rouvrez l'extension. Il reste dans la mémoire du navigateur, jamais sur le disque, et disparaît dès que vous l'enregistrez, l'abandonnez, verrouillez l'extension ou fermez le navigateur.

Retirer un coffre de l'extension supprime sa clé et sa copie de votre navigateur. Désinstaller l'extension supprime tout ce qu'elle a stocké.

## Ce qui sort de votre navigateur

Vos coffres sont stockés sur des relais Nostr : des serveurs gérés par des opérateurs indépendants, qui stockent des données pour tout le monde. Vos éléments sont chiffrés sur vos appareils avant d'atteindre un relais, donc les relais ne détiennent que des données qu'ils ne peuvent pas lire.

Pour télécharger vos coffres, l'extension se connecte à leurs relais : les relais que liste chaque coffre, ou à défaut les [relais par défaut](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) de Submarine, ainsi que trois relais annuaires où est publiée la liste des relais d'un coffre. Chaque relais voit votre adresse IP, comme tout site web que vous visitez, et la clé publique de chaque coffre que vous ouvrez, avec laquelle l'extension s'identifie et demande les données de ce coffre.

Quand vous créez, modifiez, ajoutez aux favoris, mettez à la corbeille ou restaurez un élément, l'extension chiffre sa nouvelle version sur votre appareil et l'envoie aux relais de son coffre. Quand vous supprimez définitivement un élément, elle demande à ces relais de supprimer chacune de ses versions. Une modification qu'aucun relais n'a encore acceptée attend dans la copie chiffrée de votre navigateur, et elle est renvoyée la prochaine fois que vous ouvrez l'extension ou appuyez sur son bouton de synchronisation.

Le générateur de mots de passe fonctionne dans votre navigateur : ce qu'il génère n'en sort que dans un élément que vous enregistrez.

Quand vous lui demandez de remplir un identifiant, depuis sa fenêtre ou avec son raccourci clavier, l'extension écrit le nom d'utilisateur et le mot de passe dans le formulaire de connexion de la page actuelle, et seulement si l'adresse de la page correspond à l'identifiant. Le site web les reçoit quand vous vous connectez, comme si vous les aviez tapés.

## Ce que l'extension ne fait pas

- Elle n'a ni compte ni serveur à elle : ses développeurs ne reçoivent aucune donnée de sa part.
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
