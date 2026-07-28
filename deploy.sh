#!/usr/bin/env bash

# 27/07/2026
# RATIONNALISER COMMENTAIRES
# CLARIFIER DESCRIPTIF ETAPES


##################################################################################################
# bootstrap.sh — Configuration du live USB et lancement de l'installation NixOS.                 #
#                                                                                                #
# Usage : sudo ./bootstrap.sh                                                                    #
# Pour passer le clavier en français avant de lancer le script :                                 #
# gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]" && sudo ./bootstrap.sh #




# Script de post-installation NixOS
# À utiliser juste après une installation "standard" via l'ISO live + Calamares
#
# CE QUE FAIT CE SCRIPT :
#   1) Demande le hostname que tu veux réellement utiliser (au lieu de "nixos")
#   2) Ajoute l'import de ton fichier de config personnel dans hosts/
#   3) Applique ce hostname dans networking.hostName
#   4) Désactive services.xserver.enable
#   5/6) Déplace displayManager.gdm et desktopManager.gnome hors de l'espace
#        "xserver" (nouvelle syntaxe NixOS)
#   7) Désactive l'impression (services.printing.enable = false)
#   8) Télécharge nixos-dotfiles et génère variables.nix à partir du template
#      (demande le mot de passe à hasher, détecte machine-id, LUKS UUID,
#      subvolume racine, etc.)
#   9) Crée le sous-volume btrfs "cargo" s'il n'existe pas déjà
#
# COMMENT L'UTILISER :
#   1) Place ce script dans le même dossier que ton configuration.nix,
#      ou modifie la variable CONFIG_FILE ci-dessous si besoin.
#   2) Rends-le exécutable :
#        chmod +x post-install-nixos.sh
#   3) Lance-le avec les droits root, car il modifie un fichier système
#      (/etc/nixos/configuration.nix appartient à root) :
#        sudo ./post-install-nixos.sh
#
# Une sauvegarde du fichier original est créée automatiquement avant toute
# modification (configuration.nix.bak.AAAAMMJJ-HHMMSS).

##################################################################################################

set -euo pipefail

# ─── VÉRIFICATION DES DROITS ────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être lancé avec sudo : sudo ./deploy.sh"
    exit 1
fi

# On détecte si on est sur un live d'installation (squashfs) ou un système déjà installé.
# La logique d'éxecution adaptée au cas de figure sera lancée.
if findmnt -t squashfs -no SOURCE | grep -q .; then
    TARGET="/mnt"
    echo "Live ISO, installation"
else
    TARGET=""
    echo "Système installé, rebuild"
fi

CONFIG_FILE="${TARGET}/etc/nixos/configuration.nix"

# ═══════════════════════════════════════════════════════════════════════════
#  SEQUENCE D'EXECUTION
# ═══════════════════════════════════════════════════════════════════════════

executer_installation() {
    initialiser_environnement_installation
    configurer_disque
    creer_cargo
    definir_infos_initiales
    generer_infos_inexistantes
    telecharger_repo_git
    preparer_configuration.nix
    renseigner_configuration.nix
    generer_variables.nix
    installer_Nixos
    migrer_fichiers_persistants
    finaliser
}

executer_rebuild() {
    creer_cargo
    collecter_infos_existantes
    generer_infos_inexistantes
    telecharger_repo_git
    sauvegarder_configuration.nix
    renseigner_configuration.nix
    generer_variables.nix
    rebuilder_Nixos
    migrer_fichiers_persistants
    finaliser
}

# ═══════════════════════════════════════════════════════════════════════════
#  PREPARATION ENVIRONNEMENT (SPECIFIQUE DEPLOIEMENT PAR INSTALLATION)
# ═══════════════════════════════════════════════════════════════════════════
initialiser_environnement_installation() {
    timedatectl set-timezone Europe/Paris
    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 1/5 : Configuration du wifi"
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
#  CONFIGURATION DU DISQUE (SPECIFIQUE DEPLOIEMENT PAR INSTALLATION)
#
#  Logique générale :
#  La détection se fait avant toute action destructive : on ouvre le
#  conteneur LUKS en lecture, on sonde home avec btrfs subvolume show,
#  puis on referme proprement. 
#
#  Après cette étape d'inspection, le script choisit son chemin : zap complet
#  ou réinitialisation douce.
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
configurer_disque() {

    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 2/5 : Configuration des disques"
    echo "══════════════════════════════════════════"
    read -rp "Prêt à configurer le disque ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }

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

    # ─── 2. Détection de home / cargo ──────────────────────────────────
    USER_DATA_FOUND=false
    LUKS_UUID=""
    LUKS_NAME=""

    # On tente d'ouvrir le conteneur LUKS existant pour inspecter les sous-volumes.
    if cryptsetup isLuks "$PART_LUKS" 2>/dev/null; then
        echo ""
        echo "Partition LUKS détectée. Récupération de son UUID..."
        LUKS_UUID=$(cryptsetup luksUUID "$PART_LUKS")
        LUKS_NAME="luks-${LUKS_UUID}"
        echo "Partition LUKS détectée. Ouverture pour inspection..."
        cryptsetup open "$PART_LUKS" "$LUKS_NAME"_inspect
        mount -o "$OPTS,subvol=/" "/dev/mapper/$LUKS_NAME"_inspect /mnt

        if btrfs subvolume show /mnt/home &>/dev/null || btrfs subvolume show /mnt/cargo &>/dev/null; then
            USER_DATA_FOUND=true
            echo "Données utilisateur détectées. Elles seront conservées."
        else
            echo "Aucune donnée utilisateur détectée. Le disque sera entièrement effacé."
        fi

        umount /mnt
        cryptsetup close "$LUKS_NAME"_inspect
    fi

    # ─── 3A. Chemin "aucune donnée" → zap complet ─────────────────────────
    if [[ "$USER_DATA_FOUND" == false ]]; then
        echo ""
        echo "Aucune donnée utilisateur à préserver. $DISK va être entièrement effacé."
        read -rp "Confirmer ? (oui) : " CONFIRM
        [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }

        sgdisk --zap-all "$DISK"
        sgdisk --new=1:0:+1024M --typecode=1:ef00 --change-name=1:"boot" "$DISK"
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

        # On expose le nom du sous-volume créé pour / (sera utilisé dans variables.nix)
        ROOT_SUBVOLUME="root"

    # ─── 3B. Chemin "données présentes" → réinitialisation douce ─────────
    else
        echo ""
        echo "Home et/ou cargo seront conservés. Les sous-volumes root et nix vont être recréés."
        read -rp "Confirmer ? (oui) : " CONFIRM
        [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }

        cryptsetup open "$PART_LUKS" "$LUKS_NAME"
        mount -o "$OPTS,subvol=/" "/dev/mapper/$LUKS_NAME" /mnt

        # Suppression des anciens sous-volumes (on laisse home et cargo intacts).
        for SUBVOL in root nix; do
            if btrfs subvolume show "/mnt/$SUBVOL" &>/dev/null; then
                # Supprimer les sous-volumes imbriqués d'abord.
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

        # On expose le nom du sous-volume créé pour / (sera utilisé dans variables.nix)
        ROOT_SUBVOLUME="root"
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
    # Démontage propre des montages temporaires effectués lors de la création des sous-volumes.
    umount /mnt

    mount -o "$OPTS,subvol=root" "/dev/mapper/$LUKS_NAME" /mnt

    for subvol in $(btrfs subvolume list /mnt | awk '{print $NF}'); do
        [[ "$subvol" == "root" ]] && continue

        tmpmounts="/mnt/${subvol}"
        mkdir -p "$tmpmounts"
        mount -o "$OPTS,subvol=$subvol" "/dev/mapper/$LUKS_NAME" "$tmpmounts"
    done

    mkdir -p /mnt/boot
    mount "$PART_BOOT" /mnt/boot -o umask=0077

    # ─── Résumé ───────────────────────────────────────────────────────────
    echo ""
    echo "✓ Disque prêt. Structure montée :"
    findmnt --target /mnt --submounts
}

# ═══════════════════════════════════════════════════════════════════════════
#  CREATION DU SOUS-VOLUME BTRFS CARGO s'il n'exite pas encore physiquement
#  sur le disque. Ce volume doit être déclare dans les .nix pour être monté
# ═══════════════════════════════════════════════════════════════════════════
creer_cargo() {
    echo ""
    echo "Vérification du sous-volume btrfs 'cargo'..."

    ROOT_FSTYPE=$(findmnt -no FSTYPE "${TARGET:-/}")

    if [[ "$ROOT_FSTYPE" != "btrfs" ]]; then
        echo "⚠ Le système de fichiers racine n'est pas btrfs ($ROOT_FSTYPE détecté)."
        echo "  Le sous-volume 'cargo' n'a pas pu être créé, vérifie manuellement."
    else
        # findmnt peut renvoyer un format "device[/chemin_du_subvol]" pour une
        # racine montée sur un sous-volume : on ne garde que la partie device.
        ROOT_DEVICE=$(findmnt -no SOURCE "${TARGET:-/}" | sed 's/\[.*//')
        TMP_MOUNT=$(mktemp -d)

        # Filet de sécurité : si le script s'interrompt après le mount, on
        # démonte quand même proprement au lieu de laisser un montage orphelin.
        cleanup_cargo_mount() {
            if mountpoint -q "$TMP_MOUNT" 2>/dev/null; then
                umount "$TMP_MOUNT"
            fi
            rmdir "$TMP_MOUNT" 2>/dev/null || true
        }
        trap cleanup_cargo_mount EXIT

        # On monte le volume btrfs à son niveau racine absolu (subvolid=5), seul
        # niveau depuis lequel on peut créer un sous-volume au même rang que
        # root, home, nix, persist, etc.
        mount -o subvolid=5 "$ROOT_DEVICE" "$TMP_MOUNT"

        CARGO_EXISTS=$(btrfs subvolume list "$TMP_MOUNT" | awk '{print $NF}' | grep -xF "cargo" || true)

        if [[ -n "$CARGO_EXISTS" ]]; then
            echo "✓ Le sous-volume 'cargo' existe déjà, aucune action nécessaire."
        else
            btrfs subvolume create "$TMP_MOUNT/cargo"
            echo "✓ Sous-volume 'cargo' créé."
        fi

        cleanup_cargo_mount
        trap - EXIT
    fi
}

# ══════════════════════════════════════════════════════════════════════════════════
#  DEFINITION DES INFORMATIONS INITIALES (SPECIFIQUE DEPLOIEMENT PAR INSTALLATION)
# ══════════════════════════════════════════════════════════════════════════════════
definir_infos_initiales () {
    read -rp "Nom d'utilisateur : " USERNAME
    FULLNAME="${USERNAME^}"

    NIXOS_VERSION=$(nixos-version | cut -d. -f1,2)
    if [[ -z "$NIXOS_VERSION" ]]; then
        echo "Impossible de détecter la version NixOS automatiquement."
        read -rp "Entre-la manuellement (ex: 26.05) : " NIXOS_VERSION
    fi

    # Génération du machine-id
    MACHINE_ID=$(systemd-id128 new | tr -d '-')
}

# ═════════════════════════════════════════════════════════════════════════════
#  COLLECTE DES INFORMATIONS PREEXISTANTES (SPECIFIQUE DEPLOIEMENT PAR REBUILD)
# ═════════════════════════════════════════════════════════════════════════════
collecter_infos_existantes () {
    # Recherche du username dans le configuration.nix déjà existant
    USERNAME=$(grep -oP 'users\.users\."\K[^"]+' "$CONFIG_FILE" | head -n1 || true)
    if [[ -z "$USERNAME" ]]; then
        echo "Impossible de détecter automatiquement le nom d'utilisateur dans $CONFIG_FILE."
        read -rp "Entre manuellement ton nom d'utilisateur : " USERNAME
    fi

    # Recherche du numero de version dans le configuration.nix déjà existant
    NIXOS_VERSION=$(grep -oP 'system\.stateVersion\s*=\s*"\K[^"]+' "$CONFIG_FILE" | head -n1 || true)
    if [[ -z "$NIXOS_VERSION" ]]; then
        echo "Impossible de détecter la version NixOS automatiquement."
        read -rp "Entre-la manuellement (ex: 26.05) : " NIXOS_VERSION
    fi

    # Récupération du machine-id existant (généré imperativement par systemd)
    # pour le faire basculer en gestion déclarative.
    MACHINE_ID=$(cat /etc/machine-id)

    # Recherche du nom d'un éventuel sous-volume / distinct
    ROOT_SUBVOLUME=$(btrfs subvolume show / | head -n1 | xargs)
    if [[ -z "$ROOT_SUBVOLUME" ]]; then
        echo "⚠ Impossible de détecter le nom du subvolume racine."
        read -rp "Entre-le manuellement : " ROOT_SUBVOLUME
    fi

    # Récupération de l'UUID LUKS
    # On detecte quel volume est un volume LUKS
    LUKS_DEVICES=()
    while read -r dev; do
        if cryptsetup isLuks "/dev/$dev" 2>/dev/null; then
            LUKS_DEVICES+=("/dev/$dev")
        fi
    done < <(lsblk -rno NAME,TYPE | awk '$2 == "part" {print $1}')

    case "${#LUKS_DEVICES[@]}" in
        0)
            # Si aucun volume LUKS n'a été détecté, on ne défini pas la variables $LUKS_UUID
            echo "⚠ Aucune partition LUKS détectée. luksUuid sera laissé vide dans variables.nix."
            LUKS_UUID=""
            ;;
        1)
            # On extrait l'UUID du volume LUKS détectée
            echo "Partition LUKS détectée : ${LUKS_DEVICES[0]}"
            LUKS_UUID=$(cryptsetup luksUUID "${LUKS_DEVICES[0]}")
            ;;
        *)
            # Si plusieurs volumes LUKS ont été détectées, choix manuel de celui dont on extrait l'UUID
            echo "Plusieurs partitions LUKS détectées, laquelle utiliser ?"
            select LUKS_DEVICE in "${LUKS_DEVICES[@]}"; do
                if [[ -n "$LUKS_DEVICE" ]]; then
                    LUKS_UUID=$(cryptsetup luksUUID "$LUKS_DEVICE")
                    break
                fi
                echo "Choix invalide, réessaie."
            done
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════
#  CREER LES VARIABLES INEXISTANTES
# ═══════════════════════════════════════════════════════════════════════════
generer_infos_inexistantes () {
    echo ""
    # Nom de la machine
    while true; do
        read -rp "Hostname de cette machine : " HOSTNAME
        if [[ -z "$HOSTNAME" ]]; then
            echo "Le hostname ne peut pas être vide, réessaie."
        elif [[ "$HOSTNAME" =~ [[:space:]] ]]; then
            echo "Le hostname ne doit pas contenir d'espaces, réessaie."
        else
            break
        fi
    done

    # Mot de passe déclaratif (hashedPassword)
    while true; do
        read -rsp "Choisis le mot de passe à hasher : " PASSWORD
        echo ""
        read -rsp "Confirme le mot de passe : " PASSWORD_CONFIRM
        echo ""
        if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
            echo "Les deux saisies ne correspondent pas, réessaie."
        elif [[ -z "$PASSWORD" ]]; then
            echo "Le mot de passe ne peut pas être vide, réessaie."
        else
            break
        fi
    done

    # Utilisateur github (optionnel)
    read -rp "Nom d'utilisateur github (optionnel, peut être laissé vide) : " GIT_USERNAME
    read -rp "Adresse mail github (optionnel, peut être laissé vide) : " GIT_USERMAIL
    echo ""

    # Génération du hash du mot de passe
    # mkpasswd utilise l'algorythme yescrypt par défaut.
    HASHED_PASSWORD=$(mkpasswd "$PASSWORD")
    unset PASSWORD PASSWORD_CONFIRM
}

# ═══════════════════════════════════════════════════════════════════════════
#  TELECHARGEMENT DU REPO nixos-dotfiles
# ═══════════════════════════════════════════════════════════════════════════
telecharger_repo_git () {
    DOTFILES_DIR="${TARGET}/home/${USERNAME}/Git/nixos-dotfiles"
    echo ""
    echo "Téléchargement des dotfiles..."

    # git refuse le téléchargement s'il existe des fichiers dans le dossier cible.
    # On supprime les éventuels fichiers existants.
    rm -rf "$DOTFILES_DIR"
    mkdir -p "$DOTFILES_DIR"
    # on installe git temporairement, et on run la commande
    nix-shell -p git --run "git clone https://github.com/binnotkari-wq/nixos-dotfiles.git $DOTFILES_DIR"
    echo "✓ Dotfiles téléchargés dans ${DOTFILES_DIR}/"

    # On vérifie que le fichier "hostname".nix est bien présent
    HOST_IMPORT_PATH="${TARGET}/home/${USERNAME}/Git/nixos-dotfiles/hosts/${HOSTNAME}.nix"

    if [[ -f "$HOST_IMPORT_PATH" ]]; then
        echo "✓ Le fichier de host $HOST_IMPORT_PATH existe bien dans le dépôt."
    else
        echo ""
        echo "⚠ Attention : $HOST_IMPORT_PATH n'existe pas dans le dépôt cloné."
        echo "  Il faudra le créer maintenant sinon le build échouera."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
#  PREPARER CONFIGURATION.NIX (SPECIFIQUE DEPLOIEMENT PAR INSTALLATION)
# ═══════════════════════════════════════════════════════════════════════════
preparer_configuration.nix () {
    echo ""
    echo "Copie de configuration_template.nix depuis le dépôt git vers /etc/nixos/configuration.nix avant injection des informations collectée......"
    mkdir -p "${TARGET}/etc/nixos"
    cp -ra "$DOTFILES_DIR/nixos_auto-install/configuration_template.nix" "$CONFIG_FILE"
    # Remplacement des placeholders du numéro de version par celui détecté sur le système en cours, et du username et fullname d'après les informations saisies
    sed -i \
        -e "s|@@username@@|${USERNAME}|g" \
        -e "s|@@fullname@@|${FULLNAME}|g" \
        -e "s|@@nixosversion@@|${NIXOS_VERSION}|g" \
    "$CONFIG_FILE"
    echo "configuration.nix en place : $CONFIG_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════
#  SAUVEGARDE DE CONFIGURATION.NIX (SPECIFIQUE DEPLOIEMENT PAR REBUILD)
# ═══════════════════════════════════════════════════════════════════════════
sauvegarder_configuration.nix () {
    echo ""
    echo "Sauvegarde de configuration.nix avant injection des informations collectée......"
    BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Sauvegarde créée : $BACKUP_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════
#  RENSEIGNEMENT DE CONFIGURATION.NIX
# ═══════════════════════════════════════════════════════════════════════════
renseigner_configuration.nix () {
    # Insertion de l'import du fichier de host perso, juste après ./hardware-configuration.nix dans le bloc imports
    sed -i "/\.\/hardware-configuration\.nix/a\\      /home/${USERNAME}/Git/nixos-dotfiles/hosts/${HOSTNAME}.nix" "$CONFIG_FILE"

    # Remplacement du hostname par défaut ("nixos") par le hostname choisi
    sed -i "s/networking\.hostName = \"nixos\";/networking.hostName = \"${HOSTNAME}\";/" "$CONFIG_FILE"

    # Désactivation de services.xserver.enable
    sed -i 's/services\.xserver\.enable = true;/services.xserver.enable = false;/' "$CONFIG_FILE"

    # Déplacement du displayManager.gdm hors de l'espace xserver (syntaxe actuelle
    sed -i 's/services\.xserver\.displayManager\.gdm\.enable = true;/services.desktopManager.gnome.enable = true;/' "$CONFIG_FILE"
    sed -i 's/services\.xserver\.desktopManager\.gnome\.enable = true;/services.displayManager.gdm.enable = true;/' "$CONFIG_FILE"

    # Désactivation de l'impression
    sed -i 's/services\.printing\.enable = true;/services.printing.enable = false;/' "$CONFIG_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════
#  RENSEIGNEMENT DE VARIABLES.NIX
# ═══════════════════════════════════════════════════════════════════════════
generer_variables.nix () {
    TEMPLATE_FILE="${DOTFILES_DIR}/modules/variable_template.nix"
    VARIABLES_FILE="${DOTFILES_DIR}/modules/variables.nix"

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo "Erreur : $TEMPLATE_FILE introuvable. Vérifie que le clone du dépôt s'est bien déroulé."
        exit 1
    fi

    echo ""
    echo "Mise en place de variables.nix et injection des informations collectée..."

    # Si variables.nix existe déjà (script relancé une deuxième fois), on le
    # sauvegarde avant de l'écraser, comme pour configuration.nix.
    if [[ -f "$VARIABLES_FILE" ]]; then
        VARIABLES_BACKUP="${VARIABLES_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$VARIABLES_FILE" "$VARIABLES_BACKUP"
        echo "variables.nix existant sauvegardé : $VARIABLES_BACKUP"
    fi

    cp "$TEMPLATE_FILE" "$VARIABLES_FILE"

    # Fonction d'échappement pour sed : protège \, & et le délimiteur | dans les
    # valeurs injectées (indispensable pour hashedPassword, qui contient des $ et /
    # selon l'algorithme, et qui pourrait théoriquement contenir | ou &).
    sed_escape() {
        printf '%s' "$1" | sed -e 's/[\&|]/\\&/g'
    }

    # Subsitutions
    sed -i "s|@@username@@|$(sed_escape "$USERNAME")|"               "$VARIABLES_FILE"
    sed -i "s|@@fullname@@|$(sed_escape "$FULLNAME")|"               "$VARIABLES_FILE"
    sed -i "s|@@hashedPassword@@|$(sed_escape "$HASHED_PASSWORD")|"  "$VARIABLES_FILE"
    sed -i "s|@@hostname@@|$(sed_escape "$HOSTNAME")|"               "$VARIABLES_FILE"
    sed -i "s|@@machineid@@|$(sed_escape "$MACHINE_ID")|"            "$VARIABLES_FILE"
    sed -i "s|@@luksUuid@@|$(sed_escape "$LUKS_UUID")|"              "$VARIABLES_FILE"
    sed -i "s|@@nixosversion@@|$(sed_escape "$NIXOS_VERSION")|"      "$VARIABLES_FILE"
    sed -i "s|@@gitUsername@@|$(sed_escape "$GIT_USERNAME")|"        "$VARIABLES_FILE"
    sed -i "s|@@gitUsermail@@|$(sed_escape "$GIT_USERMAIL")|"        "$VARIABLES_FILE"
    sed -i "s|@@rootSubvolumeName@@|$(sed_escape "$ROOT_SUBVOLUME")|" "$VARIABLES_FILE"

    unset HASHED_PASSWORD
    echo "✓ variables.nix généré dans $VARIABLES_FILE"
    echo "Vérifier le contenu de variables.nix :"
    cat "$VARIABLES_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════
#  INSTALLATION DE NIXOS (SPECIFIQUE DEPLOIEMENT PAR INSTALLATION)
# ═══════════════════════════════════════════════════════════════════════════
installer_Nixos () {
    echo ""
    read -rp "Prêt à installer NixOS ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }
    # le fichier configuration.nix personnalisé ne sera pas écrasé
    echo "Génération de hardware-configuration.nix..."
    mkdir -p "/mnt/etc/nixos"
    nixos-generate-config --root /mnt
    echo "✓ hardware-configuration.nix généré."
    echo ""
    echo "Lancement de nixos-install..."
    nixos-install --root /mnt --no-root-passwd
}

# ═══════════════════════════════════════════════════════════════════════════
#  REBUILD DE NIXOS (SPECIFIQUE DEPLOIEMENT PAR REBUILD)
# ═══════════════════════════════════════════════════════════════════════════
rebuilder_Nixos () {
    echo ""
    read -rp "Prêt à installer NixOS ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }
    echo ""
    echo "Lancement du rebuild..."
    nixos-rebuild boot
}

# ═══════════════════════════════════════════════════════════════════════════
#  MIGRATION DES FICHIERS PERSISTANTS (IMPERMANENCE)
#  Préparation des prérequis pour le module impermanence :
#    - création du dossier /nix/persist
#    - migration des fichiers à persister vers /nix/persist/
#
#  À exécuter UNE SEULE FOIS, avant le premier reboot avec impermanence
#  actif. Opération non destructive : ne modifie pas les sources, copie
#  uniquement. impermanence.nix devra être présent dans les imports.
# ═══════════════════════════════════════════════════════════════════════════
migrer_fichiers_persistants() {
    echo ""
    echo "══════════════════════════════════════════"
    echo "  Étape 4/5 : Migration des fichiers persistants"
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
    mkdir -p ${TARGET}/nix/persist

    # ─── 2. Éléments à persister ──────────────────────────────────────────
    # Format : DIRS["source"]="copier_le_contenu"
    #   true  = cp -ra vers /nix/persist (données utiles à conserver)
    #   false = créer le dossier vide dans /nix/persist (se reconstruira tout seul)
    declare -A DIRS
    DIRS["${TARGET}/etc/lact"]="true"
    DIRS["${TARGET}/etc/NetworkManager"]="true"
    DIRS["${TARGET}/etc/nixos"]="true"
    DIRS["${TARGET}/etc/ssh"]="true"
    DIRS["${TARGET}/var/lib/AccountsService"]="true"
    DIRS["${TARGET}/var/lib/bluetooth"]="true"
    DIRS["${TARGET}/var/lib/colord"]="false"        # se reconstruit tout seul
    DIRS["${TARGET}/var/lib/cups"]="true"
    DIRS["${TARGET}/var/lib/flatpak"]="true"
    DIRS["${TARGET}/var/lib/fwupd"]="false"         # se reconstruit tout seul
    DIRS["${TARGET}/var/lib/NetworkManager"]="true"
    DIRS["${TARGET}/var/lib/nixos"]="true"
    DIRS["${TARGET}/var/lib/systemd/coredump"]="false"
    DIRS["${TARGET}/var/lib/upower"]="false"        # se reconstruit tout seul
    DIRS["${TARGET}/var/log"]="true"

    # ─── 3. Traitement ─────────────────────────────────────────────────────
    echo ""
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${BLUE}  Migration initiale vers ${TARGET}/nix/persist${NC}"
    echo -e "${BLUE}======================================================${NC}"
    echo ""

    SUCCESS=0
    SKIPPED=0
    CREATED=0
    ERRORS=0

    for src in "${!DIRS[@]}"; do
        copy="${DIRS[$src]}"
        dest="${TARGET}/nix/persist${src#/mnt}"

        # Le dossier source n'existe pas sur /.
        if [[ ! -d "$src" ]]; then
            echo -e "${YELLOW}[ABSENT ]${NC} $src → dossier inexistant sur ${TARGET}/, création vide dans ${TARGET}/nix/persist"
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
            if cp -ra "$src/." "$dest/" 2>/dev/null; then
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
    rsync -a ${TARGET}/var/lib/nixos/ ${TARGET}/nix/persist/var/lib/nixos/

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
#  FINALISATION
#  Récupération des scripts utiles et correction des permissions.
# ═══════════════════════════════════════════════════════════════════════════

finaliser() {
    echo ""
    echo "══════════════════════════════════════════"
    echo "  Finalisation"
    echo "══════════════════════════════════════════"

    # ─── 1. Récupération des scripts utiles ───────────────────────────────
    echo ""
    echo "Téléchargement des scripts utiles..."
    mkdir -p "${TARGET}/home/${USERNAME}/Git/scripts"
    git clone "https://github.com/binnotkari-wq/scripts.git" "${TARGET}/home/${USERNAME}/Git/scripts/"
    echo "✓ Scripts téléchargés dans ${TARGET}/home/${USERNAME}/Git/scripts/."

    # ─── 2. Application des permissions ────────────────────────────────────
    echo ""
    echo "Application des permissions..."
    chown -R "${USERNAME}:${USERNAME}" "${TARGET}/home/${USERNAME}"
    chown -R "${USERNAME}:${USERNAME}" "${TARGET}/cargo"
    echo "✓ Permissions appliquées."
    echo ""
    echo "══════════════════════════════════════════"
    echo "  Terminé. Redémarrer le PC."
    echo "══════════════════════════════════════════"
}

# ═══════════════════════════════════════════════════════════════════════════
#  EXÉCUTION
# ═══════════════════════════════════════════════════════════════════════════

# On détecte si on est sur un live d'installation (squashfs) ou un système déjà installé.
# La logique d'éxecution adaptée au cas de figure sera lancée.
if [ "$TARGET" = "/mnt" ]; then
    read -rp "Prêt à installer NixOS ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }
    executer_installation
elif [ "$TARGET" = "" ]; then
    read -rp "Prêt à rebuilder NixOS ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }
    executer_rebuild
fi
