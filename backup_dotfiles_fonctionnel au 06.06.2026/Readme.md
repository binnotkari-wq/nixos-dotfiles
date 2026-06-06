# Dans /etc/nixos

Ces deux fichiers restent dans /etc/nixos/ pour simplifier les commandes nixos, dont on aura pas besoin de modifier la cible.

## hardware-configuration.nix

Généré par le script d'installation avec nixos-generate-config avec pour contenu le scan du matériel

## configuration.nix

Créé par le script d'installation avec cat, avec pour seul contenu l'import de hardware configuration et de main.nix





# Dans /$HOME/Mes-Donnees/Git/nixos-dotfiles/

## variable.nix

Contient les principales données que l'ont personnalise lors d'une installation (et ne contient que ça)

Ces données sont héritées dans les fichiers .nix concernés, sous forme de variables que nixos appelle depuis variables.nix au moment de l'évaluation.
Les fichiers .nix ne contiennet donc aucun paramètre personnel.

--> en excluant variables.nix dans .gitignore, on a un repo github anonymisé, aucun paramètre personnel

--> en regroupant les variables dans variable.nix, le reste des fichiers .nix deviennent un sanctuaire, jamais modifiés même si on installe sur une autre mahcine, avec un autre nom d'utilisateur, etc ...

## main.nix

Il contient la configuration coeur du système.
il se charge également de propager les vars de variables.nix vers ses imports.

On peut build avec ce seul fichier, hardware-configuration.nix (généré par le script d'installation), "hostname".nix, et variable.nix  (généré par le script d'installation)

Tous les autres fichiers .nix sont optionnels.