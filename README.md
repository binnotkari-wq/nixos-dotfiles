# the-greatest-repo
Dépot pour geeker :)


## How-to-build

Fiches des experimentation des differents builds

## nixos-dotfiles

Dépôt de configuration NixOS. Ce système est conçu pour être reproductible, propre et performant, avec une gestion modulaire des machines. Système basé sur flakes et home manager, 100% stateless

### 🚀 Philosophie du Système

* Flakes & Nixos-rebuild : Gestion moderne des dépendances et des versions.

* Architecture Stateless (Erase Your Darlings) : La partition racine (/) est montée en tmpfs (RAM). Elle est donc effacée à chaque redémarrage pour garantir un système sain. Options déclarées dans core.nix.

* Impermanence & Persistance : Seules les données contextuelles (config réseaux, bluetooth, imprimantes, reègles firewall) sont persistées sur le disque via des bind-mounts Btrfs. Options déclarées dans core.nix.

* Structure Modulaire :
    - hosts/ : Configurations spécifiques au matériel, par machines
    - users/ : Définition des comptes utilisateurs et profils Home Manager.
    - OS / : Composants partagés (options de l'OS, applications de base...).

### 🛠️ Script d'installation' (bootstrap.sh)

Pour faciliter le déploiement sur une nouvelle machine ou après une réinstallation, utiliser le script interactif qui gère :

* Vérification de Version : Aligne automatiquement la version du système sur celle du Live USB.
* Choix du Disque : parmis la liste les périphériques (lsblk) avec double confirmation avant formatage.
* Choix de la machine (host) préconfigurée parmis la liste des machine déclarées dans les .nix
* Choix de l'utilisateur préconfigurée parmis la liste des utilisateurs déclarées dans les .nix
* Partitionnement Btrfs : Création automatique des sous-volumes (@nix, @home) et du montage RAM.
* Injection Automatique : Mise à jour dynamique du stateVersion et des URLs de nixpkgs dans les fichiers .nix avant l'installation.

### 💻 Machines gérées
Hostname	Type	Caractéristiques
dell-5485	Laptop	Ryzen 5, Mobilité, Optimisation batterie
r5-3600	Desktop	Gaming, Performance, Drivers NVIDIA/AMD


### 📦 Installation rapide

Depuis un Live USB NixOS, se connecter à internet et dans le terminal : 

```bash
git clone https://github.com/binnotkari-wq/the-greatest-repo.git
cd the-greatest-repo/nixos-dotfiles/
chmod +x bootstrap.sh
./bootstrap.sh
```
### 💡 Conseil d'utilisation

Ce dépôt utilise Home Manager pour la gestion de l'environnement utilisateur. Les fichiers de configuration spécifiques se trouvent dans ./users/benoit_home.nix.

### A faire

* basculer les déclaration de logiciels spécifiques AMD / gestion de l'énergie pour les PC portables etc ... dans les fichiers tuning.nix propres à chaque machine

* intégrer luks2 à l'installation

* arrêter les flatpaks et passer en natif, tout en déclaratif

## Scripts

Scripts bash utiles (sauvegarde, conversion, lanceurs ...)
