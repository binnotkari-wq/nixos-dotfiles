#!/usr/bin/env bash
set -e

# --- DEBUT DE LA DEFINITION DES VARIABLES ---
echo "--- Configuration de l'installation NixOS ---"
echo "--- Au préalable, les variables doivent avoir été éditées, ainsi que user_name, host et choix de l'environnement logiciel dans configuration.nix ---"
echo "- Ce script va effacer le disque choisi, créer une partition EFI de 512Mo, et une partition BTRFS dans un conteneur chiffré LUKS 2 sur tout le reste de l'espace disponible.
- Les sous-volumes BTRFS /nix, /swap et /home seront créés.
- Le swap sera un swapfile, + un zram qui est configuré dans les .nix.
- / est monté en tmpfs qui sera vidé à chaqué redémarrage, avec quelques éléments persistés grâce au module impermanence configuré dans les .nix.
- Les sous-volumes /nix, /home et /swap étant distinct de /, il seront persistants.
- Ces partitions sont montés dans /mnt/, qui est la cible de l'installation.
- Système sans Flakes ni Home Manager"
echo

# 3. les valeurs de ces variables n'ont pas de raison d'être différentes. Laisser tel quel.
DISK="sda" # parmis les disques listés avec la commande lsblk -dn -o NAME,SIZE,MODEL
TARGET_HOSTNAME="vm" # machine sur laquelle on fait l'installation, sont nom doit correspondre à la valeur de HOST dans les .nix
TARGET_MOUNT="/mnt" # laisser par défaut
TARGET_USER="benoit" # doit être déclaré dans les .nix
DOTFILES_PATH="$TARGET_MOUNT/home/$TARGET_USER/Mes-Donnees/Git/nixos-dotfiles" # on peut personnaliser le dossier dans lequel les .nix vont être copiés pour l'nsstallation.



# --- RAPPEL DES SELECTIONS ---
echo ""
echo -e "\e[36m==========================================================\e[0m"
echo "RÉCAPITULATIF DE L'INSTALLATION :"
echo "  - Machine : $TARGET_HOSTNAME"
echo "  - Utilisateur : $TARGET_USER"
echo "  - Disque : /dev/$DISK"
echo -e "\e[36m==========================================================\e[0m"
echo -e "\n\e[31m[ATTENTION]\e[0m TOUTES LES DONNÉES SUR /dev/$DISK VONT ÊTRE EFFACÉES."
read -p "Confirmer l'effacement et lancer l'installation ? (y/N) : " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "❌ Installation annulée."
    exit 1
fi
# --- DEBUT DE LA DEFINITION DES VARIABLES ---


# --- DÉBUT DU SCRIPT DE PARTITIONNEMENT ---
# 1. TABLE DE PARTITIONS
echo "🏗️  Création de la table de parLe swap sera un swapfile.tition GPT..."
sudo sgdisk --zap-all /dev/$DISK
sudo sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"BOOT" /dev/$DISK   # EFI
sudo sgdisk -n 2:0:0      -t 2:8300 -c 2:"SYSTEM" /dev/$DISK # LUKS + BTRFS

# Gestion intelligente des noms de partitions (nvme vs autres)
if [[ $DISK == *"nvme"* || $DISK == *"mmcblk"* ]]; then
    PART_BOOT="/dev/${DISK}p1"
    PART_LUKS="/dev/${DISK}p2"
else
    PART_BOOT="/dev/${DISK}1"
    PART_LUKS="/dev/${DISK}2"
fi

# 2. CHIFFREMENT LUKS2
echo "🔐 Chiffrement de la partition système (LUKS2)..."
# On utilise les réglages standards robustes
sudo cryptsetup luksFormat --type luks2 $PART_LUKS
echo "🔓 Ouverture du conteneur chiffré..."
sudo cryptsetup open $PART_LUKS cryptroot
PART_BTRFS="/dev/mapper/cryptroot"

# 3. FORMATAGE
echo "🧹 Formatage des partitions..."
sudo mkfs.vfat -F 32 -n BOOT $PART_BOOT
sudo mkfs.btrfs -f -L NIXOS $PART_BTRFS

# 4. CRÉATION DES SOUS-VOLUMES BTRFS
echo "📦 Création des sous-volumes..."
sudo mount $PART_BTRFS $TARGET_MOUNT
sudo btrfs subvolume create $TARGET_MOUNT/@nix
sudo btrfs subvolume create $TARGET_MOUNT/@home
sudo btrfs subvolume create $TARGET_MOUNT/@swap
sudo umount $TARGET_MOUNT

# 5. ARCHITECTURE STATELESS (RAM)
echo "🧠 Montage du Root en RAM..."
sudo mount -t tmpfs none $TARGET_MOUNT -o size=2G,mode=755
sudo mkdir -p $TARGET_MOUNT/{boot,nix/persist,home,swap}
sudo mkdir -p $TARGET_MOUNT/nix/persist

# 7. MONTAGES FINAUX
echo "🔗 Montages des volumes..."
sudo mount $PART_BOOT $TARGET_MOUNT/boot
sudo mount $PART_BTRFS $TARGET_MOUNT/nix -o subvol=@nix,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET_MOUNT/home -o subvol=@home,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET_MOUNT/swap -o subvol=@swap,noatime,ssd # Pas de compression sur le swap, pas de trim (discard=async) car vu le contenu changeant du swapfile, il y aurait un trim constant
# NB : l'autorisation du trim des données avant leur chiffrement par LUKS est déclarée dans les .nix

# 8. CRÉATION DU SWAPFILE (Méthode moderne Btrfs)
echo "💾 Création du swapfile de 4Go..."
sudo btrfs filesystem mkswapfile --size 4g $TARGET_MOUNT/swap/swapfile
sudo swapon $TARGET_MOUNT/swap/swapfile

# --- FIN DU SCRIPT DE PARTITIONNEMENT ---



# 9. GÉNÉRATION DU MATÉRIEL
echo "🔍 Détection des composants matériels...sauf les sytèmes de fichier, qui vont être gérés par un .nix distinct"
sudo nixos-generate-config --root $TARGET_MOUNT


# 10. PRÉPARATION DU HOME & REPO
echo "📂 Copie de la configuration..."
sudo mkdir -p $DOTFILES_PATH/hosts/$TARGET_HOSTNAME # on créé les dossiers des dotfiles dans le répertoire utilisateur
sudo cp -ra . $DOTFILES_PATH # on ycopie tout le contenu du dossier ou se trouve le script, c'est à dire tous les fichiers nix
sudo cp $TARGET_MOUNT/etc/nixos/hardware-configuration.nix $DOTFILES_PATH/hosts/$TARGET_HOSTNAME/hardware-configuration.nix ## on y copie le fichier fraîchement généré vers le dossier des dotfiles
sudo chown -R 1000:1000 "$TARGET_MOUNT/home/$TARGET_USER" # On donne les droits pour le futur système
cd "$DOTFILES_PATH"
echo "Fichiers .nix mis en place dans $DOTFILES_PATH/"


# 11. INSTALLATION
# echo "❄️  Déploiement du système...sudo nixos-install --flake $DOTFILES_PATH#$TARGET_HOSTNAME"
# read -p "Confirmer ? (y/N) : " CONFIRM
# sudo nixos-install --root $TARGET_MOUNT -I nixos-config=$DOTFILES_PATH/configuration.nix # sans flakes

echo "✅ Installation terminée avec succès !"
echo "🚀 Vous pouvez redémarrer."
