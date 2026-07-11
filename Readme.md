# Déploiement

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]"
curl -fsSL -o bootstrap.sh https://raw.githubusercontent.com/binnotkari-wq/nixos-dotfiles/main/bootstrap.sh
chmod +x bootstrap.sh
sudo ./bootstrap.sh
```

# Organisation des .nix

> Seuls 4 fichiers sont nécessaires : standard_configuration.nix, variables.nix, hardware-configuration.nix, configuration.nix.
> Tout le reste peux être ignoré, ou tous importés, ou importés selon n'importe quelle combinaison.

## Structure générale

```bash
.
├── common
├── drivers
├── home_manager
│   └── options
├── hosts
│   ├── hostname1
│   ├── hostname2
│   └── hostname...
├── modules
└── software_packs
```


## common

Contient les .nix minimaux obligatoires à un système utilisable. Tous les autres .nix en dehors de ce dossier sont facultatifs. 

### standard_configuration.nix

Reprend le contenu d'un configuration.nix tel que généré lors d'une installation graphique Calamares dans l'environnement live Gnome.
C'est une base garantie de bon fonctionnement. Il contient la configuration coeur du système.

### variables.nix
Ce fichier est généré à la volée par le script d'installation. Il rassemble toutes les variables personnalisées choisies à l'installation ( (et ne contient que ça) : nom d'utilisateur, hash de mot de passe, hostname....
Ces données sont héritées dans les fichiers .nix concernés, sous forme de variables que nixos appelle depuis variables.nix au moment de l'évaluation.

Bénéfices :

- Les fichiers .nix ne sont donc jamais modifiés, quelles que soient les valeurs choisies lors d'une installation, seul variables.nix est adapté.
- Cela permet également d'anonymiser le repo git, puisque le seul fichier qui contient des informations d'identification est ignoré par git. On a un repo github anonymisé, aucune donnée personnelle



## drivers

Contient des .nix de réglages additionnels spécifiques CPU et GPU. Ces .nix ne sont pas obligatoires. Il s'agit d'option qui ne sont pas déclarées lors d'une installation standard de Nixos.

## home_manager

Les fichiers décrivent les options de l'environnement utilisateur et les préférences utilisateur des logiciels. Ces .nix ne sont pas obligatoires.
Ils ne contiennent que des déclarations spécifiques à home-manager : pas de mélange des déclaration système et des déclarations home-manager, pour conserver une cohérence système / utilisateur, et garantir l'indépendance et l'idempotence.

## hosts/hostname...

### hardware-configuration.nix

Généré par le script d'installation avec nixos-generate-config avec pour contenu le scan du matériel. Le contenu de ce fichier est spécifiques à chaque machine, chaque host a le sien.

### configuration.nix

- centralise tous les imports des .nix. on peut ainsi construire sur-mesure chaque machine, en ajoutant ou retirant des imports. Ceux-ci sont indépendants les uns des autres et idempotents.
- se charge de propager les vars de variables.nix vers ses imports.
- déclare des options spécifiques à la machine


## modules

firefox.nix
flatpak.nix
impermanence.nix
OS_options.nix
performance_addons.nix
pseudo_impermanence.nix
shell.nix
SteamOS.nix


## software_packs

Contient des .nix qui proposent une selection de logiciels GTK, TUI et CLI par thèmes, cohérents et testés. Ces fichiers peuvent être importés ou non, indépendemment.

- peu de dépendances
- taille raisonnable
- éprouvés
- aucune dépendance qt

