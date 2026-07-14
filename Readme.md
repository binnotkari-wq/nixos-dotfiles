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
├── hosts
│   ├── hostname1
│   ├── hostname2
│   └── hostname...
├── modules
│   └── home-manager_options
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

## modules/home-manager_options

Les fichiers décrivent les préférences utilisateur pour certains logiciels. Ces .nix ne sont pas obligatoires.
Ils ne contiennent que des déclarations spécifiques à home-manager : pas de mélange des déclaration système et des déclarations home-manager, pour conserver une cohérence système / utilisateur, et garantir l'indépendance et l'idempotence.

## software_packs

Contient des .nix qui proposent une selection de logiciels GTK, TUI et CLI par thèmes, cohérents et testés. Ces fichiers peuvent être importés ou non, indépendemment.

- peu de dépendances
- taille raisonnable
- éprouvés
- aucune dépendance qt


# Ressources et dépendances utilisées par les .nix

| Modules                                      | Disque      |  Ram        | Intégration | Conditions pour éval nix | Remarques                                                                       |
| :------------------------------------------- | ----------: | ----------: | :---------: | :----------------------: | :------------------------------------------------------------------------------ |
| etc/nixos/configuration.nix                  | 7200,00 Mio | 1200,00 Mio | Obligatoire | Calamares                | Base système générée via Calamares, cible de nixos-rebuild                      |
| etc/nixos/hardware-configuration.nix         |    0,00 Mio |    0,00 Mio | Obligatoire | Calamares                | Base système générée via Calamares, propre au PC                                |
| ou common/standard_configuration.nix         | 7200,00 Mio | 1200,00 Mio | Obligatoire | Script + variables.nix   | Base système pour déploiement scripté. Calqué sur configuration.nix Calamares   |
| + common/variables.nix                       |    0,00 Mio |    0,00 Mio | Obligatoire | Script                   | Base système générée via script. Ignoré par git                                 |
| + hosts/$hostname/configuration.nix          |      qq Mio |         Mio | Obligatoire | Script + variables.nix   | Fichier racine des .nix, cible de nixos-rebuild, propre à chaque PC             |
| + hosts/$hostname/hardware-configuration.nix |         Mio |         Mio | Obligatoire | Script                   | Base système générée via script, propre à chaque PC                             |
| software_packs/CLI_base.nix                  |         Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base opérationnel                |
| software_packs/GTK_base.nix                  | 1800,00 Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base opérationnel                |
| modules/OS_options.nix                       |   20,00 Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base perfectionné                |
| modules/performance_addons.nix               |    1,00 Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base optimisé                    |
| drivers/CPU_AMD.nix                          |         Mio |         Mio | Facultative |                          | Spécifique au hardware. Recommandé pour un système de base affiné au matériel   |
| drivers/CPU_intel_pre10.nix                  |         Mio |         Mio | Facultative |                          | Spécifique au hardware. Recommandé pour un système de base affiné au matériel   |
| drivers/GPU_AMD.nix                          |         Mio |         Mio | Facultative |                          | Spécifique au hardware. Recommandé pour un système de base affiné au matériel   |
| drivers/GPU_nivida.nix                       |         Mio |         Mio | Facultative |                          | Spécifique au hardware. Recommandé pour un système de base affiné au matériel   |
| drivers/iGPU_intel.nix                       |         Mio |         Mio | Facultative |                          | Spécifique au hardware. Recommandé pour un système de base affiné au matériel   |
| modules/btop.nix                             |    0,00 Mio |    0,00 Mio | Facultative | variables.nix ou edition | 100% agnostique. Inutile si btop n'est pas installé                             |
| modules/firefox.nix                          |    1,50 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Inutile si Firefox n'est pas installé                          |
| modules/flatpak.nix                          |   15,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique                                                                 |
| modules/git.nix                              |         Mio |         Mio | Facultative | variables.nix ou edition | 100% agnostique. Inutile si git n'est pas installé                              |
| modules/gnome-dconf.nix                      |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique                                                                 |
| modules/home-manager.nix                     |    0,00 Mio |    0,00 Mio | Facultative | variables.nix ou edition | Fichier de configuration : module commnautaire Home-Manager. Inutile si newsboat, pyradio et yazi ne sont pas installés (TUI_all.nix) |
| modules/impermanence.nix                     |    0,00 Mio |    0,00 Mio | Facultative | Config disque adaptée    | Fichier de configuration : module commnautaire Impermanence                     |
| modules/kitty.nix                            |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Inutile si Kitty n'est pas installé                            |
| modules/pseudo_impermanence.nix              |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Inutile lorsqu'on active impermanence.nix                      |
| modules/shell.nix                            |    0,03 Mio |    0,00 Mio | Facultative | Aucune                   | Génère des alias vers scripts personnalisés et outils de TUI_base.nix           |
| modules/SteamOS.nix                          | 1400,00 Mio |    0,00 Mio | Facultative | Aucune                   | La session Gamescope ne s'exécute qu'avec un GPU AMD                            |
| modules/xdg.nix                              |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Raccourcis vers outils TUI_base.nix                            |
| modules/home-manager_options/newsboat.nix    |         Mio |         Mio | Facultative | HM activé                | Module home-manager : prefs utilisateur. Inutile si newsboat n'est pas installé |
| modules/home-manager_options/pyradio.nix     |         Mio |         Mio | Facultative | HM activé                | Module home-manager : prefs utilisateur. Inutile si pyradio n'est pas installé  |
| modules/home-manager_options/yazi.nix        |         Mio |         Mio | Facultative | HM activé                | Module home-manager : prefs utilisateur. Inutile si yazi n'est pas installé     |
| software_packs/dev_experiments.nix           | 1800,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour développement et expérimentations.              |
| software_packs/firmwares.nix                 |  780,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. A utiliser si firmwares spécifiques                            |
| software_packs/gaming.nix                    | 3300,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour gaming. Aucun tuning.                           |
| software_packs/CLI_all.nix                   |         Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour utilisation CLI avancée.                        |
| software_packs/GTK_all.nix                   | 2500,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour utilisation GUI avancée.                        |
| software_packs/TUI.nix                       |         Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour utilisation TUI.                                |
| software_packs/unwanted.nix                  | -300,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Exclusion de logiciels Gnome inutiles.                         |














