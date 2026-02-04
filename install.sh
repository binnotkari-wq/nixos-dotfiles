#!/usr/bin/env bash
set -e

# --- EXPLICATIONS ---
echo "
- Ce script prépare ce shéma de partitions :
- une partition EFI de 512Mo
- une partition BTRFS dans un conteneur chiffré LUKS 2 sur tout le reste de l'espace disponible
- Les sous-volumes BTRFS /nix, /swap et /home
- Le swap sera un swapfile, + un zram qui est configuré dans les .nix.
- / est monté en tmpfs qui sera vidé à chaqué redémarrage, avec quelques éléments persistés grâce au module impermanence configuré dans les .nix.
- Les sous-volumes /nix, /persist, /home et /swap étant distinct de /, il seront persistants.
- Ces partitions sont provisoirement montées dans /mnt/, qui est la cible de l'installation.
- Système sans Flakes ni Home Manager"

# --- DEBUT DE LA DEFINITION DES VARIABLES ---
DISK="sda" # parmis les disques listés avec la commande lsblk -dn -o NAME,SIZE,MODEL
TARGET_HOSTNAME="len-x240" # machine sur laquelle on fait l'installation, sont nom doit correspondre à la valeur de HOST dans les .nix
TARGET_USER="benoit" # utilisateur déclaré dans les .nix
TARGET_MOUNT="/mnt" # laisser par défaut
DOTFILES_PATH="$TARGET_MOUNT/home/$TARGET_USER/Mes-Donnees/Git/nixos-dotfiles" # on peut personnaliser le dossier dans lequel les .nix vont être copiés pour l'installation.

echo -e "\e[36m==========================================================\e[0m"
echo "🛠️  INSTALLATION NIXOS"
echo "Au préalable, les variables doivent avoir été éditées dans le script, ainsi que user_name, host et choix de l'environnement logiciel dans ${TARGET_HOSTNAME}.nix"hardware-configuration
echo -e "\e[36m==========================================================\e[0m"
echo "wipe : 💥 Efface TOUT le disque selectionné, et créé le schéma de partition"
echo "reinstall :  volume LUKS2 existant du disque selectionné, garde /home, et reset de /nix /swap et /boot."
read -p "Choix : " MODE

echo ""
echo -e "\e[36m==========================================================\e[0m"
echo "RÉCAPITULATIF DE L'INSTALLATION :"
echo "  - Machine : $TARGET_HOSTNAME"
echo "  - Mode d'installation : $MODE"
echo "  - Utilisateur : $TARGET_USER"
echo "  - Disque : /dev/$DISK"
echo -e "\e[36m==========================================================\e[0m"
echo -e "\n\e[31m[ATTENTION]\e[0m TOUTES LES DONNÉES SUR /dev/$DISK VONT ÊTRE EFFACÉES."
read -p "Confirmer l'effacement et lancer l'installation ? (y/N) : " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "❌ Installation annulée."
    exit 1
fi


# Gestion intelligente des noms de partitions (nvme vs autres)
if [[ $DISK == *"nvme"* || $DISK == *"mmcblk"* ]]; then
    PART_BOOT="/dev/${DISK}p1"
    PART_LUKS="/dev/${DISK}p2"
else
    PART_BOOT="/dev/${DISK}1"
    PART_LUKS="/dev/${DISK}2"
fi

# --- FIN DE LA DEFINITION DES VARIABLES ---


# --- DÉBUT DU SCRIPT DE PARTITIONNEMENT ---

# 0. SECURITE : on désactive tous les éventuels swaps actifs pour libérer les fichiers
sudo swapoff -a || true

# 1. TABLE DE PARTITIONS - (installe WIPE uniquement)
if [[ $MODE == "wipe" ]]; then
    echo "🏗️  suppression de toute table de partition existante..."
    sudo sgdisk --zap-all /dev/$DISK
    echo "🏗️  Création de la table de partition GPT..."
    sudo sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"BOOT" /dev/$DISK   # EFI
    sudo sgdisk -n 2:0:0      -t 2:8300 -c 2:"SYSTEM" /dev/$DISK # LUKS + BTRFS
fi

# 2. CHIFFREMENT LUKS2  -  (installe WIPE uniquement)
# On utilise les réglages standards robustes
if [[ $MODE == "wipe" ]]; then
    echo "🔐 Chiffrement de la partition système (LUKS2)..."
    sudo cryptsetup luksFormat --type luks2 $PART_LUKS
fi

echo "🔓 Ouverture du conteneur chiffré..."
sudo cryptsetup open $PART_LUKS cryptroot # systématique quel que soit le mode d'installation
PART_BTRFS="/dev/mapper/cryptroot" # systématique quel que soit le mode d'installation

# 3. FORMATAGE
echo "🧹 Formatage des partitions..."
sudo mkfs.vfat -F 32 -n BOOT $PART_BOOT # systématique quel que soit le mode d'installation
[[ $MODE == "wipe" ]] && sudo mkfs.btrfs -f -L NIXOS $PART_BTRFS # (installe WIPE uniquement)
# Nota : [[ condition ]] && action équivaut à
# if [ condition ]; then
# action
# fi


# 4. CRÉATION DES SOUS-VOLUMES BTRFS # systématique quel que soit le mode d'installation
sudo mount $PART_BTRFS $TARGET_MOUNT
echo "📦 Ajustement des sous-volumes..."
# Suppression des anciens (si existants)
sudo btrfs subvolume delete $TARGET_MOUNT/@nix 2>/dev/null || true
sudo btrfs subvolume delete $TARGET_MOUNT/@swap 2>/dev/null || true
# Création des sous-volumes si nécessaire (@home est donc préservé s'il existe déjà)
[[ ! -d "$TARGET_MOUNT/@nix" ]]  && sudo btrfs subvolume create $TARGET_MOUNT/@nix
[[ ! -d "$TARGET_MOUNT/@persist" ]] && sudo btrfs subvolume create $TARGET_MOUNT/@persist
[[ ! -d "$TARGET_MOUNT/@home" ]] && sudo btrfs subvolume create $TARGET_MOUNT/@home
[[ ! -d "$TARGET_MOUNT/@swap" ]] && sudo btrfs subvolume create $TARGET_MOUNT/@swap
sudo umount $TARGET_MOUNT


# 5. ARCHITECTURE STATELESS (RAM)  # systématique quel que soit le mode d'installation
echo "🧠 Montage du Root en RAM (tmpfs)..."
sudo mount -t tmpfs none $TARGET_MOUNT -o size=2G,mode=755
sudo mkdir -p $TARGET_MOUNT/{boot,nix,persist,home,swap}


# 7. MONTAGES FINAUX # systématique quel que soit le mode d'installation
echo "🔗 Montages des volumes..."
sudo mount $PART_BOOT $TARGET_MOUNT/boot
sudo mount $PART_BTRFS $TARGET_MOUNT/nix -o subvol=@nix,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET_MOUNT/persist -o subvol=@persist,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET_MOUNT/home -o subvol=@home,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET_MOUNT/swap -o subvol=@swap,noatime,ssd # Pas de compression sur le swap, pas de trim (discard=async) car vu le contenu changeant du swapfile, il y aurait un trim constant


# 8. CRÉATION DU SWAPFILE (Méthode moderne Btrfs) # systématique quel que soit le mode d'installation
echo "💾 Création du swapfile de 4Go..."
sudo btrfs filesystem mkswapfile --size 4g $TARGET_MOUNT/swap/swapfile
sudo swapon $TARGET_MOUNT/swap/swapfile

# --- FIN DU SCRIPT DE PARTITIONNEMENT ---


# 9. GÉNÉRATION DU MATÉRIEL
echo "🔍 Détection des composants matériels"
sudo nixos-generate-config --root $TARGET_MOUNT


# 10. PRÉPARATION
echo "📂 Copie de la configuration..."
sudo mkdir -p $DOTFILES_PATH
sudo cp -ra . $DOTFILES_PATH # on y copie tout le contenu du dossier ou se trouve le script, c'est à dire tous les fichiers nix
sudo cp "$TARGET_MOUNT/etc/nixos/hardware-configuration.nix" "$DOTFILES_PATH/hardware-support/hardware-configuration/${TARGET_HOSTNAME}_hardware-configuration.nix" # on y copie le fichier fraîchement généré vers le dossier des dotfiles (tout en le renommant avec le nom de la machine)
sudo chown -R 1000:1000 "$TARGET_MOUNT/home/$TARGET_USER" # On donne les droits pour le futur système
echo "Fichiers .nix mis en place dans $DOTFILES_PATH/"

echo "🔐 Configuration du mot de passe pour $TARGET_USER..."
# On demande le mot de passe de manière invisible
read -rs -p "Entrez le mot de passe pour $TARGET_USER : " USER_PASS
echo
# On génère le hash yescrypt et on l'enregistre. Ce fichier est appellé par le .nix de déclaration de l'utilisateur.
sudo mkdir -p $TARGET_MOUNT/persist/secrets
echo "$USER_PASS" | mkpasswd -m yescrypt | sudo tee $TARGET_MOUNT/persist/secrets/$TARGET_USER-password > /dev/null
sudo chmod 600 $TARGET_MOUNT/persist/secrets/$TARGET_USER-password
unset USER_PASS # Efface la variable de la RAM par sécurité


# 11. INSTALLATION
echo "❄️  Déploiement du système...sudo nixos-install --root $TARGET_MOUNT -I nixos-config=$DOTFILES_PATH/${TARGET_HOSTNAME}.nix"
read -p "Confirmer ? (y/N) : " CONFIRM
sudo nixos-install --root $TARGET_MOUNT -I nixos-config=$DOTFILES_PATH/${TARGET_HOSTNAME}.nix # sans flakes


echo "✅ Installation terminée avec succès !"
echo "🚀 Vous pouvez redémarrer."
