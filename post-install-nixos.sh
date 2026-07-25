#!/usr/bin/env bash
#
# ==============================================================================
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
# ==============================================================================

set -euo pipefail

CONFIG_FILE="/etc/nixos/configuration.nix"

# ------------------------------------------------------------------------------
# Vérifications préalables
# ------------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "Erreur : ce script doit être lancé avec sudo (il modifie un fichier système)."
    echo "  Exemple : sudo ./post-install-nixos.sh"
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Erreur : impossible de trouver $CONFIG_FILE"
    echo "  Adapte la variable CONFIG_FILE en haut du script si ton fichier est ailleurs."
    exit 1
fi

# ------------------------------------------------------------------------------
# Détection automatique du nom d'utilisateur défini par Calamares
# (cherche la ligne du type : users.users."benoit" = { )
# ------------------------------------------------------------------------------

USERNAME=$(grep -oP 'users\.users\."\K[^"]+' "$CONFIG_FILE" | head -n1 || true)

if [[ -z "$USERNAME" ]]; then
    echo "Impossible de détecter automatiquement le nom d'utilisateur dans $CONFIG_FILE."
    read -rp "Entre manuellement ton nom d'utilisateur : " USERNAME
fi

echo "Utilisateur détecté : $USERNAME"

# ------------------------------------------------------------------------------
# Saisie du hostname
# ------------------------------------------------------------------------------

while true; do
    read -rp "Entre le hostname que tu veux utiliser pour cette machine : " HOSTNAME
    if [[ -z "$HOSTNAME" ]]; then
        echo "Le hostname ne peut pas être vide, réessaie."
    elif [[ "$HOSTNAME" =~ [[:space:]] ]]; then
        echo "Le hostname ne doit pas contenir d'espaces, réessaie."
    else
        break
    fi
done

echo "Hostname choisi : $HOSTNAME"

# Chemin vers le fichier de host personnalisé qui sera importé
HOST_IMPORT_PATH="/home/${USERNAME}/Git/nixos-dotfiles/hosts/${HOSTNAME}.nix"

# ------------------------------------------------------------------------------
# Sauvegarde du fichier original
# ------------------------------------------------------------------------------

BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Sauvegarde créée : $BACKUP_FILE"

# ------------------------------------------------------------------------------
# 1) Insertion de l'import du fichier de host perso, juste après
#    ./hardware-configuration.nix dans le bloc imports
# ------------------------------------------------------------------------------

sed -i "/\.\/hardware-configuration\.nix/a\\      ${HOST_IMPORT_PATH}" "$CONFIG_FILE"

# ------------------------------------------------------------------------------
# 2) Remplacement du hostname par défaut ("nixos") par le hostname choisi
# ------------------------------------------------------------------------------

sed -i "s/networking\.hostName = \"nixos\";/networking.hostName = \"${HOSTNAME}\";/" "$CONFIG_FILE"

# ------------------------------------------------------------------------------
# 3) Désactivation de services.xserver.enable
# ------------------------------------------------------------------------------

sed -i 's/services\.xserver\.enable = true;/services.xserver.enable = false;/' "$CONFIG_FILE"

# ------------------------------------------------------------------------------
# 4) Déplacement du displayManager.gdm hors de l'espace xserver
#    services.xserver.displayManager.gdm.enable = true;
#      -> services.desktopManager.gnome.enable = true;
# ------------------------------------------------------------------------------

sed -i 's/services\.xserver\.displayManager\.gdm\.enable = true;/services.desktopManager.gnome.enable = true;/' "$CONFIG_FILE"

# ------------------------------------------------------------------------------
# 5) Déplacement du desktopManager.gnome hors de l'espace xserver
#    services.xserver.desktopManager.gnome.enable = true;
#      -> services.displayManager.gdm.enable = true;
# ------------------------------------------------------------------------------

sed -i 's/services\.xserver\.desktopManager\.gnome\.enable = true;/services.displayManager.gdm.enable = true;/' "$CONFIG_FILE"

# ------------------------------------------------------------------------------
# 6) Désactivation de l'impression
# ------------------------------------------------------------------------------

sed -i 's/services\.printing\.enable = true;/services.printing.enable = false;/' "$CONFIG_FILE"

# ------------------------------------------------------------------------------
# 7) Téléchargement des dotfiles
# ------------------------------------------------------------------------------

echo ""
echo "Téléchargement des dotfiles..."

if ! command -v git &> /dev/null; then
    echo "Erreur : git n'est pas installé sur ce système."
    echo "  Ajoute temporairement git avec : nix-shell -p git"
    echo "  puis relance ce script (les modifications sur $CONFIG_FILE ont déjà été appliquées)."
    exit 1
fi

DOTFILES_DIR="/home/${USERNAME}/Git/nixos-dotfiles"

# git refuse le téléchargement s'il existe des fichiers dans le dossier cible.
# On supprime les éventuels fichiers existants.
rm -rf "$DOTFILES_DIR"
mkdir -p "$DOTFILES_DIR"
git clone "https://github.com/binnotkari-wq/nixos-dotfiles.git" "$DOTFILES_DIR"

# Le script tourne en root (via sudo), donc git clone crée des fichiers
# appartenant à root. On rend la propriété à l'utilisateur.
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/Git"

echo "✓ Dotfiles téléchargés dans ${DOTFILES_DIR}/"

if [[ -f "$HOST_IMPORT_PATH" ]]; then
    echo "✓ Le fichier de host $HOST_IMPORT_PATH existe bien dans le dépôt."
else
    echo ""
    echo "⚠ Attention : $HOST_IMPORT_PATH n'existe pas dans le dépôt cloné."
    echo "  Il faudra le créer avant de lancer 'sudo nixos-rebuild switch',"
    echo "  sinon le build échouera."
fi

# ------------------------------------------------------------------------------
# 8) Génération de variables.nix à partir de variable_template.nix
# ------------------------------------------------------------------------------

echo ""
echo "Génération de variables.nix..."

MODULES_DIR="${DOTFILES_DIR}/modules"
TEMPLATE_FILE="${MODULES_DIR}/variable_template.nix"
VARIABLES_FILE="${MODULES_DIR}/variables.nix"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Erreur : $TEMPLATE_FILE introuvable. Vérifie que le clone du dépôt s'est bien déroulé."
    exit 1
fi

# --- fullname (extrait de $CONFIG_FILE, ligne "description = ...;") ---
FULLNAME=$(grep -oP 'description\s*=\s*"\K[^"]+' "$CONFIG_FILE" | head -n1 || true)
if [[ -z "$FULLNAME" ]]; then
    echo "Impossible de détecter le nom complet automatiquement."
    read -rp "Entre-le manuellement : " FULLNAME
fi

# --- nixosVersion (extrait de $CONFIG_FILE, ligne "system.stateVersion = ...;") ---
NIXOS_VERSION=$(grep -oP 'system\.stateVersion\s*=\s*"\K[^"]+' "$CONFIG_FILE" | head -n1 || true)
if [[ -z "$NIXOS_VERSION" ]]; then
    echo "Impossible de détecter la version NixOS automatiquement."
    read -rp "Entre-la manuellement (ex: 26.05) : " NIXOS_VERSION
fi

# --- machineid ---
MACHINE_ID=$(systemd-id128 new | tr -d '-')

# --- luksUuid : détection des partitions LUKS via cryptsetup isLuks ---
# (plus fiable que blkid, qui dépend d'un cache pouvant être obsolète)
LUKS_DEVICES=()
while read -r dev; do
    if cryptsetup isLuks "/dev/$dev" 2>/dev/null; then
        LUKS_DEVICES+=("/dev/$dev")
    fi
done < <(lsblk -rno NAME,TYPE | awk '$2 == "part" {print $1}')

case "${#LUKS_DEVICES[@]}" in
    0)
        echo "⚠ Aucune partition LUKS détectée. luksUuid sera laissé vide dans variables.nix."
        LUKS_UUID=""
        ;;
    1)
        echo "Partition LUKS détectée : ${LUKS_DEVICES[0]}"
        LUKS_UUID=$(cryptsetup luksUUID "${LUKS_DEVICES[0]}")
        ;;
    *)
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

# --- gitUsername / gitUsermail (saisie facultative) ---
read -rp "Nom d'utilisateur Git (laisser vide si non applicable) : " GIT_USERNAME
read -rp "Email Git (laisser vide si non applicable) : " GIT_USERMAIL

# --- rootSubvolumeName ---
ROOT_SUBVOLUME=$(btrfs subvolume show / | head -n1 | xargs)
if [[ -z "$ROOT_SUBVOLUME" ]]; then
    echo "⚠ Impossible de détecter le nom du subvolume racine."
    read -rp "Entre-le manuellement : " ROOT_SUBVOLUME
fi

# --- hashedPassword (saisie masquée, confirmation, puis hash via mkpasswd) ---
if ! command -v mkpasswd &> /dev/null; then
    echo "Erreur : mkpasswd est introuvable sur ce système."
    exit 1
fi

while true; do
    read -rsp "Choisis le mot de passe à hasher : " PASSWORD_1
    echo ""
    read -rsp "Confirme le mot de passe : " PASSWORD_2
    echo ""
    if [[ "$PASSWORD_1" != "$PASSWORD_2" ]]; then
        echo "Les deux saisies ne correspondent pas, réessaie."
    elif [[ -z "$PASSWORD_1" ]]; then
        echo "Le mot de passe ne peut pas être vide, réessaie."
    else
        break
    fi
done

HASHED_PASSWORD=$(mkpasswd "$PASSWORD_1")
unset PASSWORD_1 PASSWORD_2

# --- Génération du fichier final ---

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

# Le fichier vient d'être créé/modifié en root, on rend la propriété à l'utilisateur.
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/Git"

echo "✓ variables.nix généré dans $VARIABLES_FILE"

# ------------------------------------------------------------------------------
# 9) Création du sous-volume btrfs "cargo" (déjà déclaré côté Nix), s'il
#    n'existe pas encore physiquement sur le disque
# ------------------------------------------------------------------------------

echo ""
echo "Vérification du sous-volume btrfs 'cargo'..."

ROOT_FSTYPE=$(findmnt -no FSTYPE /)

if [[ "$ROOT_FSTYPE" != "btrfs" ]]; then
    echo "⚠ Le système de fichiers racine n'est pas btrfs ($ROOT_FSTYPE détecté)."
    echo "  Le sous-volume 'cargo' n'a pas pu être créé, vérifie manuellement."
else
    # findmnt peut renvoyer un format "device[/chemin_du_subvol]" pour une
    # racine montée sur un sous-volume : on ne garde que la partie device.
    ROOT_DEVICE=$(findmnt -no SOURCE / | sed 's/\[.*//')
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

# ------------------------------------------------------------------------------
# Résumé
# ------------------------------------------------------------------------------

echo ""
echo "Modifications terminées sur $CONFIG_FILE"
echo "Import ajouté : $HOST_IMPORT_PATH"
echo "Fichier généré : $VARIABLES_FILE"
echo ""
echo "Pour vérifier les changements sur configuration.nix :"
echo "  diff $BACKUP_FILE $CONFIG_FILE"
echo ""
echo "Pour vérifier le contenu de variables.nix :"
echo "  cat $VARIABLES_FILE"
