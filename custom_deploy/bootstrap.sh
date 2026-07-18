#!/usr/bin/env bash

##################################################################################################
# bootstrap.sh — Configuration du live USB et lancement de l'installation NixOS.                 #
#                                                                                                #
# Usage : sudo ./bootstrap.sh                                                                    #
# Pour passer le clavier en français avant de lancer le script :                                 #
# gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]" && sudo ./bootstrap.sh #
##################################################################################################

set -euo pipefail
timedatectl set-timezone Europe/Paris

# ─── VÉRIFICATION DES DROITS ────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être lancé avec sudo : sudo ./bootstrap.sh"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════
#  SEQUENCE D'EXECUTION
# ═══════════════════════════════════════════════════════════════════════════

executer() {

    configurer_wifi
    identifier_disque
    partitionner_disque
    installer_Nixos
    migrer_fichiers_persistants
    provisionner_cargo
    finaliser
}

# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 1/6 — CONFIGURATION DE LA CONNEXION WIFI
# ═══════════════════════════════════════════════════════════════════════════
configurer_wifi() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 1/6 : Configuration du wifi"
    echo "══════════════════════════════════════════"
    read -rp "Configurer le wifi ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }

    echo ""
    echo "Réseaux WiFi disponibles :"
    nmcli device wifi list

    echo ""
    read -rp "SSID du réseau : " WIFI_SSID
    read -rsp "Mot de passe WiFi : " WIFI_PASSWORD
    echo ""

    echo "Connexion à '$WIFI_SSID'..."
    nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD"
    unset WIFI_PASSWORD

    echo "Attente de la connexion réseau..."
    until ping -c1 github.com &>/dev/null; do
        sleep 2
    done
    echo "✓ Connexion établie."
}

# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 2/6 — CONFIGURATION DU DISQUE
#  Préparation d'un disque avec préservation de @home et @cargo (si existants).
#
#  Logique générale :
#  La détection se fait avant toute action destructive : on ouvre le
#  conteneur LUKS en lecture, on sonde @home avec btrfs subvolume show,
#  puis on referme proprement. 
#
# Après cette étape d'inspection, le script choisit en étape 3 son chemin
# (zap complet ou réinitialisation douce).
# ═══════════════════════════════════════════════════════════════════════════
identifier_disque() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 2/6 : Identifier le disque cible"
    echo "══════════════════════════════════════════"

    # ─── 1. Sélection du disque ──────────────────────────────────────────
    echo "Disques disponibles :"
    lsblk -d -o NAME,SIZE,MODEL

    echo ""
    read -rp "Entrez le disque cible (ex: sda, nvme0n1) : " DISK
    DISK="/dev/$DISK"

    # Noms des partitions (gère /dev/sda1 et /dev/nvme0n1p1)
    if [[ "$DISK" == *nvme* ]]; then
        PART_BOOT="${DISK}p1"
        PART_LUKS="${DISK}p2"
    else
        PART_BOOT="${DISK}1"
        PART_LUKS="${DISK}2"
    fi

    OPTS="noatime,compress=zstd,space_cache=v2,ssd,discard=async"

    # ─── 2. Détection de home / cargo existants ──────────────────────────
    # On accepte les deux conventions de nommage (transition en cours) :
    #   - ancienne : @home, @cargo (préfixe @)
    #   - nouvelle : home, cargo (convention Calamares, sans préfixe)
    USER_DATA_FOUND=false
    HOME_SUBVOL_NAME=""
    CARGO_SUBVOL_NAME=""
    LUKS_UUID=""
    LUKS_NAME=""

    if cryptsetup isLuks "$PART_LUKS" 2>/dev/null; then
        echo ""
        echo "Partition LUKS détectée. Récupération de son UUID..."
        LUKS_UUID=$(cryptsetup luksUUID "$PART_LUKS")
        LUKS_NAME="luks-${LUKS_UUID}"

        echo "Ouverture pour inspection (mapper : $LUKS_NAME)..."
        cryptsetup open "$PART_LUKS" "$LUKS_NAME"
        mount -o "$OPTS,subvol=/" "/dev/mapper/$LUKS_NAME" /mnt

        for name in home @home; do
            if btrfs subvolume show "/mnt/$name" &>/dev/null; then
                HOME_SUBVOL_NAME="$name"
                break
            fi
        done
        for name in cargo @cargo; do
            if btrfs subvolume show "/mnt/$name" &>/dev/null; then
                CARGO_SUBVOL_NAME="$name"
                break
            fi
        done

        if [[ -n "$HOME_SUBVOL_NAME" ]] || [[ -n "$CARGO_SUBVOL_NAME" ]]; then
            USER_DATA_FOUND=true
            echo "Données utilisateur détectées (home: ${HOME_SUBVOL_NAME:-absent}, cargo: ${CARGO_SUBVOL_NAME:-absent}). Elles seront conservées."
        else
            echo "Aucune donnée utilisateur détectée. Le disque sera entièrement effacé."
        fi

        umount /mnt
        cryptsetup close "$LUKS_NAME"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 3/6 — PARTITIONNEMENT DU DISQUE
#  Préparation d'un disque avec préservation de home et cargo (si existants).
#
#  Dans le chemin "réinitialisation douce", le volume btrfs est monté à sa
#  racine (subvol=/) plutôt qu'à un sous-volume spécifique, ce qui donne
#  accès à tous les sous-volumes pour pouvoir supprimer les sous-volumes
#  root et nix individuellement sans toucher à home.
#
#  Convention de nommage : sous-volumes nix et home comme le fait Calamares,
#  ainsi que root que l'on ajoute pour pouvoir gérer plus simplement 
#  (Calamares ne créé pas de sous-volume pour /).
#  Pour information, d'autres distribution nomment les sous-volumes btrfs
#  en commançant par @.
# ═══════════════════════════════════════════════════════════════════════════
partitionner_disque() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 3/6 : Partionnement du disque"
    echo "══════════════════════════════════════════"
    read -rp "Prêt à configurer le disque ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }

    # ─── 3A. Chemin "aucune donnée" → zap complet ────────────────────────
    if [[ "$USER_DATA_FOUND" == false ]]; then

        echo ""
        echo "Aucune donnée utilisateur à préserver. $DISK va être entièrement effacé."
        read -rp "Confirmer ? (oui) : " CONFIRM
        [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }

        sgdisk --zap-all "$DISK"
        sgdisk --new=1:0:+512M --typecode=1:ef00 --change-name=1:"boot" "$DISK"
        sgdisk --new=2:0:0     --typecode=2:8309 --change-name=2:"cryptroot" "$DISK"

        mkfs.fat -F32 -n BOOT "$PART_BOOT"

        echo "Chiffrement LUKS de $PART_LUKS..."
        cryptsetup luksFormat --type luks2 "$PART_LUKS"
        LUKS_UUID=$(cryptsetup luksUUID "$PART_LUKS")
        LUKS_NAME="luks-${LUKS_UUID}"
        cryptsetup open "$PART_LUKS" "$LUKS_NAME"

        mkfs.btrfs -L nixos "/dev/mapper/$LUKS_NAME"

        mount "/dev/mapper/$LUKS_NAME" /mnt
        btrfs subvolume create /mnt/root
        btrfs subvolume create /mnt/nix
        btrfs subvolume create /mnt/home

    # ─── 3B. Chemin "données présentes" → réinitialisation douce ─────────
    else

        echo ""
        echo "Home et/ou cargo seront conservés. Les sous-volumes root et nix vont être recréés."
        read -rp "Confirmer ? (oui) : " CONFIRM
        [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }

        cryptsetup open "$PART_LUKS" "$LUKS_NAME"
        mount -o "$OPTS,subvol=/" "/dev/mapper/$LUKS_NAME" /mnt

        # Suppression des anciens root/nix, ancienne ou nouvelle convention,
        # en laissant home et cargo intacts quel que soit leur nom actuel.
        for SUBVOL in root nix @ @nix; do
            if btrfs subvolume show "/mnt/$SUBVOL" &>/dev/null; then
                btrfs subvolume list -o "/mnt/$SUBVOL" 2>/dev/null |
                    awk '{print $NF}' |
                    while read -r child; do
                        btrfs subvolume delete "/mnt/$child" && echo "  → $child supprimé"
                    done
                btrfs subvolume delete "/mnt/$SUBVOL"
                echo "  → $SUBVOL supprimé"
            fi
        done

        btrfs subvolume create /mnt/root
        btrfs subvolume create /mnt/nix

    fi

    # ─── 4. Sous-volume supplémentaire (optionnel) ───────────────────────
    while true; do
        read -rp "Créer un sous-volume supplémentaire ? (oui/non) : " reponse
        if [[ "${reponse,,}" == "non" ]]; then
            break
        fi

        echo ""
        read -rp "Entrez le nom souhaité du sous-volume à créer : " SUP_SUBVOL_NAME
        btrfs subvolume create /mnt/"$SUP_SUBVOL_NAME"
    done

    # ─── 5. Montage final (commun aux deux chemins) ──────────────────────
    umount /mnt

    mount -o "$OPTS,subvol=root" "/dev/mapper/$LUKS_NAME" /mnt

    for subvol in $(btrfs subvolume list /mnt | awk '{print $NF}'); do
        [[ "$subvol" == "root" ]] && continue

        target="/mnt/${subvol#@}"
        mkdir -p "$target"
        mount -o "$OPTS,subvol=$subvol" "/dev/mapper/$LUKS_NAME" "$target"
    done

    mkdir -p /mnt/boot
    mount "$PART_BOOT" /mnt/boot -o umask=0077

    echo ""
    echo "✓ Disque prêt. Structure montée :"
    findmnt --target /mnt --submounts
}


# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 3/6 — INSTALLATION DE NIXOS
#  Collecte des informations, génération de variables.nix et de
#  hardware-configuration.nix, puis lancement de nixos-install.
# ═══════════════════════════════════════════════════════════════════════════
installer_Nixos() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 3/6 : Installation NixOS"
    echo "══════════════════════════════════════════"
    read -rp "Prêt à installer NixOS ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }

    # ─── 1. Collecte des informations ────────────────────────────────────
    echo ""
    read -rp "Version de NixOS : " NIXOS_VERSION
    read -rp "Hostname de la machine : " HOSTNAME
    read -rp "Nom d'utilisateur : " USERNAME
    USERNAME_DISPLAY="${USERNAME^}"
    read -rsp "Mot de passe : " PASSWORD
    echo ""
    read -rsp "Confirmer le mot de passe : " PASSWORD_CONFIRM
    echo ""
    read -rp "Nom d'utilisateur github (optionnel, peut être laissé vide) : " GIT_USERNAME
    read -rp "Adresse mail github (optionnel, peut être laissé vide) : " GIT_USERMAIL
    echo ""

    [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]] || { echo "Les mots de passe ne correspondent pas."; exit 1; }

    # ─── 2. Génération du hash du mot de passe ───────────────────────────
    # mkpasswd utilise l'algorythme yescrypt par défaut.
    HASHED_PASSWORD=$(mkpasswd "$PASSWORD")
    unset PASSWORD PASSWORD_CONFIRM

    # ─── 3. Génération du machine-id ─────────────────────────────────────
    MACHINEID=$(systemd-id128 new | tr -d '-')

    # ─── 4. Récupération des dotfiles ────────────────────────────────────
    echo ""
    echo "Téléchargement des dotfiles..."
    mkdir -p "/mnt/home/${USERNAME}/Git/nixos-dotfiles"
    git clone "https://github.com/binnotkari-wq/nixos-dotfiles.git" "/mnt/home/${USERNAME}/Git/nixos-dotfiles"
    echo "✓ Dotfiles téléchargés dans /mnt/home/${USERNAME}/Git/nixos-dotfiles/."

    # ─── 5. Génération de hardware-configuration.nix ─────────────────────
    echo ""
    echo "Génération de hardware-configuration.nix..."
    mkdir -p "/mnt/etc/nixos"
    nixos-generate-config --root /mnt
    echo "✓ hardware-configuration.nix généré."

    # ─── 6. Mise en place de configuration.nix ─────────────────────
    echo ""
    echo "configuration.nix généré par nixos-generate-config ne sera pas utilisé : suppression."
    rm /mnt/etc/nixos/configuration.nix
    echo "Copie de configuration.nix depuis le dépôt git vers /etc/nixos..."
    cp -ra "/mnt/home/${USERNAME}/Git/nixos-dotfiles/custom_deploy/configuration.nix" "/mnt/etc/nixos/"
    echo "✓ configuration.nix mis en place."

    # ─── 7. Génération de variables.nix ──────────────────────────────────
    echo ""
    echo "Injection des informations collectée et mise en place de variables.nix..."
    cp -ra "/mnt/home/${USERNAME}/Git/nixos-dotfiles/custom_deploy/variables.nix" "/mnt/etc/nixos/"
    sed -i \
        -e "s|@@username@@|${USERNAME}|g" \
        -e "s|@@fullname@@|${USERNAME_DISPLAY}|g" \
        -e "s|@@hashedPassword@@|${HASHED_PASSWORD}|g" \
        -e "s|@@hostname@@|${HOSTNAME}|g" \
        -e "s|@@machineid@@|${MACHINEID}|g" \
        -e "s|@@luksUuid@@|${LUKS_UUID}|g" \
        -e "s|@@nixosversion@@|${NIXOS_VERSION}|g" \
        -e "s|@@gitUsername @@|${GIT_USERNAME}|g" \
        -e "s|@@gitUsermail@@|${GIT_USERMAIL}|g" \
        "/mnt/etc/nixos/variables.nix"
    echo "✓ variables.nix mis en place."

    # ─── 8. Confirmation avant installation ──────────────────────────────
    echo ""
    echo "══════════════════════════════════════════"
    echo "  Récapitulatif avant installation"
    echo "══════════════════════════════════════════"
    echo "  Version              : $NIXOS_VERSION"
    echo "  Utilisateur          : $USERNAME ($USERNAME_DISPLAY)"
    echo "  Hostname             : $HOSTNAME"
    echo "  Machine-id           : $NIXOS_VERSION"
    echo "  Utilisateur github   : $GIT_USERNAME"
    echo "  Adresse mail github  : $GIT_USERMAIL"
    echo "  Cible                : /mnt"
    echo "══════════════════════════════════════════"
    echo ""
    read -rp "Lancer nixos-install ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }

    # ─── 9. Installation ──────────────────────────────────────────────────
    echo ""
    echo "Lancement de nixos-install..."
    nixos-install --root /mnt --no-root-passwd
}


# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 4/6 — MIGRATION DES FICHIERS PERSISTANTS (IMPERMANENCE)
#  Préparation des prérequis pour le module impermanence :
#    - création du dossier /nix/persist
#    - migration des fichiers à persister vers /nix/persist/
#
#  À exécuter UNE SEULE FOIS, avant le premier reboot avec impermanence
#  actif. Opération non destructive : ne modifie pas les sources, copie
#  uniquement. impermanence.nix devra être présent dans les imports.
#
#  Note : la restauration de @ à chaque démarrage se fait via un service
#  systemd (suppression + recréation), et non via un snapshot @blank.
# ═══════════════════════════════════════════════════════════════════════════
migrer_fichiers_persistants() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 4/6 : Migration des fichiers persistants"
    echo "  Valider uniquement si l'impermanence est à mettre en place"
    echo "══════════════════════════════════════════"
    read -rp "Prêt à migrer les fichiers à persister ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }

    # --- Couleurs -----------------------------------------------------------
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'

    # ─── 1. Création du dossier de persistance ───────────────────────────
    # /nix est un sous-volume distinct, donc hors périmètre de l'impermanence.
    mkdir -p /nix/persist

    # ─── 2. Éléments à persister ──────────────────────────────────────────
    # Format : DIRS["source"]="copier_le_contenu"
    #   true  = cp -a vers /nix/persist (données utiles à conserver)
    #   false = créer le dossier vide dans /nix/persist (se reconstruira tout seul)
    declare -A DIRS
    DIRS["/mnt/etc/lact"]="true"
    DIRS["/mnt/etc/NetworkManager"]="true"
    DIRS["/mnt/etc/nixos"]="true"
    DIRS["/mnt/etc/ssh"]="true"
    DIRS["/mnt/var/lib/AccountsService"]="true"
    DIRS["/mnt/var/lib/bluetooth"]="true"
    DIRS["/mnt/var/lib/colord"]="false"        # se reconstruit tout seul
    DIRS["/mnt/var/lib/cups"]="true"
    DIRS["/mnt/var/lib/flatpak"]="true"
    DIRS["/mnt/var/lib/fwupd"]="false"         # se reconstruit tout seul
    DIRS["/mnt/var/lib/NetworkManager"]="true"
    DIRS["/mnt/var/lib/nixos"]="true"
    DIRS["/mnt/var/lib/systemd/coredump"]="false"
    DIRS["/mnt/var/lib/upower"]="false"        # se reconstruit tout seul
    DIRS["/mnt/var/log"]="true"

    # ─── 3. Traitement ─────────────────────────────────────────────────────
    echo ""
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${BLUE}  Migration initiale vers /mnt/nix/persist${NC}"
    echo -e "${BLUE}======================================================${NC}"
    echo ""

    SUCCESS=0
    SKIPPED=0
    CREATED=0
    ERRORS=0

    for src in "${!DIRS[@]}"; do
        copy="${DIRS[$src]}"
        dest="/mnt/nix/persist${src#/mnt}"

        # Le dossier source n'existe pas sur /.
        if [[ ! -d "$src" ]]; then
            echo -e "${YELLOW}[ABSENT ]${NC} $src → dossier inexistant sur /, création vide dans /nix/persist"
            mkdir -p "$dest"
            (( CREATED++ )) || true
            continue
        fi

        # Le dossier destination existe déjà dans /persist et n'est pas vide.
        if [[ -d "$dest" ]] && [[ -n "$(ls -A "$dest" 2>/dev/null)" ]]; then
            echo -e "${BLUE}[IGNORÉ ]${NC} $dest existe déjà et n'est pas vide, on ne l'écrase pas"
            (( SKIPPED++ )) || true
            continue
        fi

        mkdir -p "$dest"

        if [[ "$copy" == "true" ]]; then
            # Copie du contenu avec préservation des permissions/ownership.
            if cp -a "$src/." "$dest/" 2>/dev/null; then
                echo -e "${GREEN}[COPIÉ  ]${NC} $src → $dest"
                (( SUCCESS++ )) || true
            else
                echo -e "${RED}[ERREUR ]${NC} $src → échec de la copie"
                (( ERRORS++ )) || true
            fi
        else
            echo -e "${BLUE}[VIDE   ]${NC} $dest créé vide (se reconstruira au boot)"
            (( CREATED++ )) || true
        fi
    done

    # Le contenu éventuel de ce dossier est nécessaire dès le premier démarrage.
    rsync -a /mnt/var/lib/nixos/ /mnt/nix/persist/var/lib/nixos/

    # ─── Résumé ────────────────────────────────────────────────────────────
    echo ""
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${BLUE}  Résumé${NC}"
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${GREEN}  Copiés    : $SUCCESS${NC}"
    echo -e "${BLUE}  Vides     : $CREATED${NC}"
    echo -e "${YELLOW}  Ignorés   : $SKIPPED${NC}"
    echo -e "${RED}  Erreurs   : $ERRORS${NC}"
    echo ""

    if [[ $ERRORS -gt 0 ]]; then
        echo -e "${RED}Des erreurs ont eu lieu, vérifier les dossiers concernés.${NC}"
        exit 1
    else
        echo -e "${GREEN}Migration terminée.${NC}"
    fi
}


# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 5/6 — PROVISIONNEMENT DE @cargo
#  Téléchargement des modèles LLM et des fichiers Kiwix (.zim) essentiels.
# ═══════════════════════════════════════════════════════════════════════════
provisionner_cargo() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 5/6 : Dataset essentiel sur @cargo"
    echo "══════════════════════════════════════════"
    read -rp "Prêt à télécharger LLM et .zim ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }

    # ─── 1. Téléchargement des LLM ────────────────────────────────────────
    echo "Installation de aria2..."
    nix-env -iA nixos.aria2

    LLM_DIR="/mnt/cargo/local_cache/LLM"
    mkdir -p "$LLM_DIR"

    echo ""
    echo "Vérification des modèles LLM..."

    PHI4="$LLM_DIR/Phi-4-mini-instruct-Q4_K_M.gguf"
    LLAMA="$LLM_DIR/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"

    if [[ ! -f "$PHI4" ]]; then
        echo "Téléchargement de Phi-4-mini..."
        aria2c --dir="$LLM_DIR" \
               --out="Phi-4-mini-instruct-Q4_K_M.gguf" \
               --continue=true \
               --max-connection-per-server=4 \
               "https://huggingface.co/unsloth/Phi-4-mini-instruct-GGUF/resolve/main/Phi-4-mini-instruct-Q4_K_M.gguf"
    else
        echo "✓ Phi-4-mini déjà présent, téléchargement ignoré."
    fi

    if [[ ! -f "$LLAMA" ]]; then
        echo "Téléchargement de Llama-3.1-8B..."
        aria2c --dir="$LLM_DIR" \
               --out="Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" \
               --continue=true \
               --max-connection-per-server=4 \
               "https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
    else
        echo "✓ Llama-3.1-8B déjà présent, téléchargement ignoré."
    fi

    # ─── 2. Téléchargement des fichiers ZIM ───────────────────────────────
    ZIM_DIR="/mnt/cargo/local_cache/Kiwix zims"
    mkdir -p "$ZIM_DIR"

    echo ""
    echo "Vérification des fichiers Kiwix..."

    WIKI_FR="$ZIM_DIR/wikipedia_fr_all_mini_2026-02.zim"
    IFIXIT="$ZIM_DIR/ifixit_en_all_2025-12.zim"

    if [[ ! -f "$WIKI_FR" ]]; then
        echo "Téléchargement de Wikipedia FR..."
        aria2c --dir="$ZIM_DIR" \
               --continue=true \
               --max-connection-per-server=4 \
               "https://download.kiwix.org/zim/wikipedia/wikipedia_fr_all_mini_2026-02.zim"
    else
        echo "✓ Wikipedia FR déjà présent, téléchargement ignoré."
    fi

    if [[ ! -f "$IFIXIT" ]]; then
        echo "Téléchargement de iFixit..."
        aria2c --dir="$ZIM_DIR" \
               --continue=true \
               --max-connection-per-server=4 \
               "https://download.kiwix.org/zim/ifixit/ifixit_en_all_2025-12.zim"
    else
        echo "✓ iFixit déjà présent, téléchargement ignoré."
    fi
}


# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 6/6 — FINALISATION
#  Récupération des scripts utiles et correction des permissions.
# ═══════════════════════════════════════════════════════════════════════════
finaliser() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 6/6 : Finalisation"
    echo "══════════════════════════════════════════"

    # ─── 1. Récupération des scripts utiles ───────────────────────────────
    echo ""
    echo "Téléchargement des scripts utiles..."
    mkdir -p "/mnt/home/${USERNAME}/Git/scripts"
    git clone "https://github.com/binnotkari-wq/scripts.git" "/mnt/home/${USERNAME}/Git/scripts/"
    echo "✓ Scripts téléchargés dans /mnt/home/${USERNAME}/Git/scripts/."

    # ─── 2. Correction des permissions ────────────────────────────────────
    echo ""
    echo "Application des permissions..."
    chown -R 1000:1000 "/mnt/home/${USERNAME}"
    chown -R 1000:1000 /mnt/cargo
    echo "✓ Permissions appliquées."

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Installation complète."
    echo "  Tu peux retirer la clé USB et redémarrer."
    echo "══════════════════════════════════════════"
}


# ═══════════════════════════════════════════════════════════════════════════
#  EXÉCUTION
# ═══════════════════════════════════════════════════════════════════════════
executer
