# Refactorisation

## Objectifs 

- les fichiers .nix ne sont plus éparpillés entre /etc/nixos et /git/nixos-dotfiles.

- On doit pouvoir gérer le multimachines (configuration spécifiques à chaque machine) sans ambiguités.

- Importer les modules homes manager un par un dans $(hostname).nix

- Analyser shell.nix et voir ce qui est réellement nécessaire de gérer par home manager

## Sous-dossiers hosts/$(hostname)/

### Principe

- chaque sous-dossier /$(hostname)/ contient configuration.nix qui sera le point d'entrée, avec pour contenu les imports et les options sécifiques à chaque machine.

- chaque sous-dossier /$(hostname)/ contient également hardware-configuration.nix

### Implications

- il faut créer un lien symbiolique entre hosts/$(hostname)/ et /etc/nixos.

- pas besoin de renommer les hardware-configuration.nix

- la commande nixos-rebuild n'a pas besoin d'être personnalisée

- on peut avoir un fichier variables.nix pour chaque machine (dans chaque sous-dossier)

## Fichiers $(hostname).nix

### Principe

- le point d'entrée est $(hostname).nix

- le fichiers hardware-configuration.nix généré pour chaque machine est renommé en hardware-configuration_$(hostname).nix

### Implications

- chaque point d'entrée est placé à la racine du repo git

- il faut donc un sous-dossier pour les hardware-configuration_$(hostname).nix

- la commande nixos-rebuild doit pointer vers la cible $(hostname).nix


## Choix : sous-dossiers hosts/$(hostname)/

### Réorganiser les .nix

[x] repo git : créer les sous-dossiers

[x] déplacer et renommer les fichiers (y compris ceux contenus dans /etc/nixos)

[x] lien symbolique vers /etc/nixos déclaratif par systemd, pour création à chaque démarrage (le lien disparaissant à chaque extinction / redémarrage du fait de l'impermanence)

[x] essayer un nixos-rebuild

#### adapter le script d'installation :

[x] déplacement de hardware-configuration.nix dans le bon sous-dossier hosts/$(hostname)/

[x] suppression de configuration.nix

[x] suppression de /etc/nixos

[x] création du lien symbolique juste avant l'exécution de nixos-install


```bash
ln -sr /mnt/etc/nixos /mnt/home/benoit/Mes-Donnees/Git/nixos-dotfiles/hosts/dell-5485
```
>La commande d'installation doit cibler vers hosts/$(hostname)/configuration.nix.
Donc soit on créer le lien symbolique avant, soit on indique la cible dans la commande d'instalation.
On privilégie le lien symbolique, pour garder une cohérence avec le fonctionnement du système une fois l'installation terminée.