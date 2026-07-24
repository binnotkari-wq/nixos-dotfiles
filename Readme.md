# Déploiement

## Commande

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]"
curl -fsSL https://raw.githubusercontent.com/binnotkari-wq/nixos-dotfiles/main/nixos_auto-install/bootstrap.sh -o bootstrap.sh
chmod +x bootstrap.sh
sudo ./bootstrap.sh
```

## Fonctionnement du script d'installation

- recueille les variables utilisées pour le déploiement et le paramétrage du système
- prépare le disque avec BTRFS (sous-volumes root, home, nix, supplémentaires au choix) dans un volume LUKS. Si un sous-volume home et/ou cargo existe déjà, il sera préservé.
- télécharge les .nix depuis le repo sur Github
- installe nixos d'après les variables spécifiées
- migre les fichiers à persister
- provisionne les scripts utiles du repo Github

Chaque étape peut être ignorée pour passer à la suivante.

# Organisation des .nix

> Seuls 3 fichiers sont nécessaires :

> - configuration.nix (copie renseignée de configuration_template.nix)
> - hardware-configuration.nix (généré à l'instalation)

> Tous les autres .nix peuvent être ignorés ou importés, indépendament ou non.

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

## racine du repo

Contient les .nix minimaux obligatoires à un système utilisable. 

### configuration.nix

Obligatoire. Reprend le contenu d'un configuration.nix tel que généré lors d'une installation graphique Calamares dans l'environnement live Gnome.
C'est une base garantie de bon fonctionnement. Il contient la configuration coeur du système.

### hardware-configuration.nix

Obligatoire. Ce fichier est généré par le script d'installation avec nixos-generate-config et a pour contenu le scan du matériel. Ce fichier est spécifiques à chaque machine, et reste isolé en local (.gitignore).

### variables.nix

Recommandé. Ce fichier est généré par le script d'installation avec un cat. Il rassemble toutes les variables personnalisées choisies à l'installation (et ne contient que ça) : nom d'utilisateur, hash de mot de passe, hostname....
Lors d'une évaluation ces données sont propagées vers les fichiers .nix qui en ont besoin.
Ce fichier est spécifiques à chaque machine, et reste isolé en local (.gitignore).

Bénéfices :

- Les autres fichiers .nix ne sont jamais modifiés, quelles que soient les valeurs choisies lors d'une installation, seul variables.nix est adapté.
- Cela permet également d'anonymiser le repo git : c'est le seul fichier qui contient des informations d'identification et il est ignoré par git (.gitignore). Le repo github est anonymisé, aucune donnée personnelle

## drivers

Recommandés. Contient des .nix de réglages additionnels spécifiques CPU et GPU. Ces .nix ne sont pas obligatoires. Il s'agit d'options qui ne sont pas déclarées lors d'une installation standard de Nixos, mais leur activation permet l'accès à toute la ressource matérielle.

## hosts/hostname...

Fichiers de paramétrage (options, packages...) distinct pour chaque machine.

### modules_selection.nix

Gère tous les imports des .nix optionnels (drivers, modules, softwares). On peut ainsi construire ou faire évoluer chaque machine en ajoutant ou retirant à tout moment des imports. Ceux-ci sont indépendants les uns des autres.
Il se charge de propager les vars de variables.nix vers ses imports. Conditions : si variables.nix n'est pas utilisé, il faut éditer manuellement les fichiers faisant appel à vars, pour remplacer les vars par les valeurs souhaitées.

### machine_features.nix

Déclare des options sur-mesure spécifiques à la machine, et qui ne seront jamais partagées avec une autre machine (matériel unique, identifiant machine...).

## modules

RECOMMANDE
OS_options.nix et performance_addons.nix sont recommandés, puisqu'ils apportent des fonctionnalités attendues d'un OS (sécurité, bluetooth, maintenance, convivialité) et des performances supérieures (BTRFS, swap, paramètres kernel) sans contreparties.

FACULTATIF ET SOUS CONDITIONS
- impermanence.nix : fichier de configuration et mise en place de l'impermanence. Conditions : le système de fichier doit être adapté et les fichiers à persister doivent avoir été migrés au préalable (ces opérations sont faites automatiquement lors du déploiement par bootstrap.sh).
- git.nix : préférences de git (déclarées à l'échelle du système, et non à l'échelle de l'utilisateur). Conditions : si variables.nix n'est pas utilisé, il faut éditer manuellement le fichier pour remplacer les vars par les valeurs souhaitées.
- home-manager : fichier de configuration du module communautaire Home-Manager (gestion déclarative de l'environnement utilisateur). Conditions : si variables.nix n'est pas utilisé, il faut éditer manuellement le fichier pour remplacer les vars par les valeurs souhaitées.

FACULTATIF
- btop.nix : préférences de btop (déclarées à l'échelle du système, et non à l'échelle de l'utilisateur).
- firefox.nix : préférences de Firefox (déclarées à l'échelle du système, et non à l'échelle de l'utilisateur).
- flatpak.nix : fichier de configuration et mise en place du service Flatpak et du module communautaire de gestion déclarative des Flatpaks.
- gnome-dconf.nix : préférences de Gnome (déclarées à l'échelle du système, et non à l'échelle de l'utilisateur).
- kitty.nix : préférences de Kitty (déclarées à l'échelle du système, et non à l'échelle de l'utilisateur).
- pseudo_impermanence.nix : 
- shell.nix : préférences du shell (déclarées à l'échelle du système, et non à l'échelle de l'utilisateur).
- SteamOS.nix : 
- xdg.nix : préférences des profils utilisateur (déclarées à l'échelle du système, et non à l'échelle de l'utilisateur).

## modules/deprecated/home-manager_options

**15/07/2026 : OK le contenu des nix est propre et standard. Aucune dépendance à un autre nix, aucun serpent qui se mords la queue. L'ensemble est agnostique**

FACULTATIF ET SOUS CONDITIONS  
Ces fichiers décrivent les préférences utilisateur pour certains logiciels.  
Conditions : home-manager doit être activé (home-manager.nix). Edition manuelle nécessaire si on utilise pas variables.nix.  
Ils ne contiennent que des déclarations spécifiques à home-manager : pas de mélange des déclaration système et des déclarations home-manager, pas de config éclatée nixos / home manager.



pour conserver une cohérence système / utilisateur, et garantir la cohérence et l'indépendance et l'idempotence.


## software_packs

**15/07/2026 : OK le contenu des nix est propre et standard. Aucune dépendance à un autre nix, aucun serpent qui se mords la queue. L'ensemble est agnostique**

Contient des .nix qui proposent une selection de logiciels GTK, TUI et CLI par thèmes, cohérents et testés.

- peu de dépendances
- taille raisonnable
- éprouvés
- aucune dépendance qt


# Utilisation des ressources et dépendances

| Modules                                      | Disque      |  Ram        | Intégration | Conditions pour éval nix | Remarques                                                                       |
| :------------------------------------------- | ----------: | ----------: | :---------: | :----------------------: | :------------------------------------------------------------------------------ |
| /etc/nixos/configuration.nix                 | 7200,00 Mio | 1200,00 Mio | Obligatoire | Aucune                   | Base système générée via Calamares (construit par séléctions de code de main.py). |
| /etc/nixos/hardware-configuration.nix        |    0,00 Mio |    0,00 Mio | Obligatoire | Aucune                   | Base système générée via Calamares (nixos-generate-config), propre au PC.       |
|        ou :                                  |             |             |             |                          |                                                                                 |
| ./nixos_auto-install/configuration_template.nix |    -     |      -      |      -      |             -            | Base système pour déploiement scripté (placeholders). Calqué sur un configuration.nix généré par Calamares.|
|    └──> copie : /etc/nixos/configuration.nix | 7200,00 Mio | 1200,00 Mio | Obligatoire | Aucune                   | Base système pour déploiement scripté (renseignées par script ou manuel).       |
| /etc/nixos/hardware-configuration.nix        |         Mio |         Mio | Obligatoire | Aucune                   | Base système générée via script (nixos-generate-config), propre au PC.          |
|                                              |             |             |             |                          |                                                                                 |
|        et :                                  |             |             |             |                          |                                                                                 |
|                                              |             |             |             |                          |                                                                                 |
| ./hosts/$hostname/modules_selection.nix      |      qq Mio |         Mio | Recommandée | Aucune                   | 100% agnostique. Permet l'import selectif d'options et packages pour chaque machine. |
| ./hosts/$hostname/machine_features.nix       |      qq Mio |         Mio | Recommandée | Aucune                   | 100% agnostique. Déclare uniquement ce qui ne peut concerner une autre machine. |
| ./software_packs/CLI_base.nix                |  463,00 Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base opérationnel.               |
| ./software_packs/GTK_base.nix                | 1800,00 Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base opérationnel.               |
| ./modules/variables_template.nix             |    0,00 Mio |    0,00 Mio |      -      | Aucune                   | Informations d'identifications (placeholders).								  |
|    └──> copie : ./modules/variables.nix      |    0,00 Mio |    0,00 Mio | Recommandée | Aucune                   | Informations d'identifications (renseignées par script ou manuel). Ignoré par git. |
| ./modules/OS_options.nix                     |   20,00 Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base perfectionné.               |
| ./modules/performance_addons.nix             |    1,00 Mio |    0,00 Mio | Recommandée | Aucune                   | 100% agnostique. Recommandé pour un système de base optimisé.                   |
| ./drivers/CPU_AMD.nix                        |         Mio |         Mio | Facultative | Aucune                   | Spécifique au hardware. Recommandé pour un système de base affiné au matériel.  |
| ./drivers/CPU_intel_pre10.nix                |         Mio |         Mio | Facultative | Aucune                   | Spécifique au hardware. Recommandé pour un système de base affiné au matériel.  |
| ./drivers/GPU_AMD.nix                        |         Mio |         Mio | Facultative | Aucune                   | Spécifique au hardware. Recommandé pour un système de base affiné au matériel.  |
| ./drivers/GPU_nivida.nix                     |         Mio |         Mio | Facultative | Aucune                   | Spécifique au hardware. Recommandé pour un système de base affiné au matériel.  |
| ./drivers/iGPU_intel.nix                     |         Mio |         Mio | Facultative | Aucune                   | Spécifique au hardware. Recommandé pour un système de base affiné au matériel.  |
| ./modules/btop.nix                           |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Prefs système. Inutile si btop n'est pas installé.             |
| ./modules/firefox.nix                        |    1,50 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Prefs système. Inutile si Firefox n'est pas installé.          |
| ./modules/flatpak.nix                        |    5,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Fonctions natives, sans dépendance à un module communautaire.  |
| ./modules/git.nix                            |    0,00 Mio |    0,00 Mio | Facultative | variables.nix ou edition | 100% agnostique. Prefs système. Inutile si git n'est pas installé               |
| ./modules/gnome-dconf.nix                    |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique                                                                 |
| ./modules/impermanence.nix                   |    0,00 Mio |    0,00 Mio | Facultative | variables.nix ou edition | Configuration impermanence. Fonctions natives, sans dépendance à un module communautaire. |
| ./modules/kitty.nix                          |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Prefs système. Inutile si Kitty n'est pas installé             |
| ./modules/newsboat.nix                       |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Prefs utilisateur. Inutile si newsboat n'est pas installé.     |
| ./modules/pseudo_impermanence.nix            |    0,00 Mio |    0,00 Mio | Facultative | variables.nix ou edition | 100% agnostique. Inutile lorsqu'on active impermanence.nix                      |
| ./modules/pyradio.nix                        |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Prefs utilisateur. Inutile si pyradio n'est pas installé.      |
| ./modules/shell.nix                          |    0,03 Mio |    0,00 Mio | Facultative | Aucune                   | Génère des alias vers scripts personnalisés et outils de TUI_base.nix           |
| ./modules/SteamOS.nix                        | 1400,00 Mio |    0,00 Mio | Facultative | Aucune                   | La session Gamescope ne s'exécute qu'avec un GPU AMD                            |
| ./modules/xdg.nix                            |    0,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Raccourcis vers outils TUI_base.nix                            |
| ./software_packs/dev_experiments.nix         | 1800,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour développement et expérimentations.              |
| ./software_packs/firmwares.nix               |  780,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. A utiliser si firmwares spécifiques                            |
| ./software_packs/gaming.nix                  | 3300,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour gaming. Aucun tuning.                           |
| ./software_packs/CLI_all.nix                 |  601,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour utilisation CLI avancée.                        |
| ./software_packs/GTK_all.nix                 | 2500,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour utilisation GUI avancée.                        |
| ./software_packs/TUI.nix                     |  326,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Logiciels pour utilisation TUI.                                |
| ./software_packs/unwanted.nix                | -300,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. Exclusion de logiciels Gnome inutiles.                         |


Les modules suivant ne sont pas utilisés, remplacées par des fonctions natives ne dépendant d'aucun module communautaire.
| Modules                                      | Disque      |  Ram        | Intégration | Conditions pour éval nix | Remarques                                                                       |
| :------------------------------------------- | ----------: | ----------: | :---------: | :----------------------: | :------------------------------------------------------------------------------ |
| ./modules/impermanence_module_communautaire.nix | 0,00 Mio |    0,00 Mio | Facultative | Config disque adaptée    | Configuration impermanence. (https://github.com/nix-community/impermanence)     |
| ./modules/flatpak_module_communautaire.nix   |    5,00 Mio |    0,00 Mio | Facultative | Aucune                   | 100% agnostique. (https://github.com/gmodena/nix-flatpak)						  |
| ./modules/home-manager.nix                   |    0,00 Mio |    0,00 Mio | Facultative | variables.nix ou edition | Configuration home-manager. Inutile si newsboat, pyradio et yazi ne sont pas installés (TUI_all.nix) |
| ./modules/home-manager_options/newsboat.nix  |    3,00 Mio |    0,00 Mio | Facultative | HM activé                | 100% agnostique. Prefs utilisateur. Inutile si newsboat n'est pas installé      |
| ./modules/home-manager_options/pyradio.nix   |    3,00 Mio |    0,00 Mio | Facultative | HM activé                | 100% agnostique. Prefs utilisateur. Inutile si pyradio n'est pas installé       |
| ./modules/home-manager_options/yazi.nix      |    3,00 Mio |    0,00 Mio | Facultative | HM activé                | 100% agnostique. Prefs utilisateur. Inutile si yazi n'est pas installé          |












