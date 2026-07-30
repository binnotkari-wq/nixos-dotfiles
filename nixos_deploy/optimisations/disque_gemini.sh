#!/usr/bin/env bash
set -euo pipefail

configurer_disque() {
    echo ""
    read -rp "Prêt à configurer le disque ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; return 0; }

    # ─── 1. Sélection du disque ──────────────────────────────────────────
    echo "Disques disponibles :"
    lsblk -d -o NAME,SIZE,MODEL
    read -rp "Entrez le disque cible (ex: sda, nvme0n1) : " DISK
    DISK="/dev/${DISK#/dev/}"

    # Noms des partitions
    if [[ "$DISK" == *nvme* ]]; then
        PART_BOOT="${DISK}p1"
        PART_LUKS="${DISK}p2"
    else
        PART_BOOT="${DISK}1"
        PART_LUKS="${DISK}2"
    fi

    # Définitions
    OPTS="noatime,compress=zstd,space_cache=v2,ssd,discard=async"
    ROOT_SUBVOLUME="root"
    ROOT_SNAPSHOT="root-blank"
    KEEP_LUKS=false
    LUKS_NAME=""

    # ─── 2. Détection et préservation de home / cargo ──────────────────────────────────
    # Si un conteneur LUKS existe, on l'ouvre pour inspecter les sous-volumes.
    if cryptsetup isLuks "$PART_LUKS" 2>/dev/null; then
        LUKS_UUID=$(cryptsetup luksUUID "$PART_LUKS")
        LUKS_NAME="luks-${LUKS_UUID}"
        cryptsetup open "$PART_LUKS" "$LUKS_NAME"
        mount -o "$OPTS,subvol=/" "/dev/mapper/$LUKS_NAME" /mnt

        # Si le sous-volume home ou cargo sont détecté, on se contente de supprimer les sous-volumes système
        if btrfs subvolume show /mnt/home &>/dev/null || btrfs subvolume show /mnt/cargo &>/dev/null; then
            KEEP_LUKS=true
            echo "--> LUKS + données utilisateur détectés. Purge des sous-volumes système uniquement..."
            read -rp "Confirmer ? (oui) : " CONFIRM
            [[ "$CONFIRM" == "oui" ]] || { umount /mnt; cryptsetup close "$LUKS_NAME"; echo "Annulé."; exit 1; }
            for SV in "$ROOT_SUBVOLUME" nix "$ROOT_SNAPSHOT"; do
                if btrfs subvolume show "/mnt/$SV" &>/dev/null; then
                    btrfs subvolume delete -R "/mnt/$SV" && echo "  → $SV supprimé"
                fi
                btrfs subvolume create "/mnt/$SV"
            done

            # Création de cargo s'il n'existait pas encore
            if ! btrfs subvolume show /mnt/cargo &>/dev/null; then
                echo "  → Création du sous-volume cargo absent..."
                btrfs subvolume create /mnt/cargo
            fi

        # Si le sous-volume home ou cargo ne sont pas détecté, on libère le disque pour faire un zap complet.
        else
            KEEP_LUKS=false
            umount /mnt
            cryptsetup close "$LUKS_NAME"
        fi
    fi

    # ─── 3. Zap complet si pas de LUKS ou pas de données ────────────────
    if [[ "$KEEP_LUKS" == false ]]; then
        echo "--> Aucune donnée à préserver (ou disque non chiffré)."
        echo "    Reconstruction complète de $DISK..."
        read -rp "Confirmer ? (oui) : " CONFIRM
        [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }
        sgdisk --zap-all "$DISK"
        sgdisk --new=1:0:+1024M --typecode=1:ef00 "$DISK"
        sgdisk --new=2:0:0      --typecode=2:8309 "$DISK"
        udevadm settle

        mkfs.fat -F32 -n BOOT "$PART_BOOT"
        cryptsetup luksFormat --type luks2 "$PART_LUKS"
        LUKS_UUID=$(cryptsetup luksUUID "$PART_LUKS")
        LUKS_NAME="luks-${LUKS_UUID}"
        cryptsetup open "$PART_LUKS" "$LUKS_NAME"
        mkfs.btrfs -f -L nixos "/dev/mapper/$LUKS_NAME"
        mount -o "$OPTS,subvol=/" "/dev/mapper/$LUKS_NAME" /mnt

        for SV in $ROOT_SUBVOLUME nix $ROOT_SNAPSHOT home cargo; do
            btrfs subvolume create "/mnt/$SV"
        done
    fi

    # ─── 4. Montage final pour NixOS ────────────────────────────────────
    umount /mnt
    mount -o "$OPTS,subvol=$ROOT_SUBVOLUME" "/dev/mapper/$LUKS_NAME" /mnt
    mkdir -p /mnt/{boot,nix,home,cargo}    
    mount "$PART_BOOT" /mnt/boot -o umask=0077
    mount -o "$OPTS,subvol=nix"   "/dev/mapper/$LUKS_NAME" /mnt/nix
    mount -o "$OPTS,subvol=home"  "/dev/mapper/$LUKS_NAME" /mnt/home
    mount -o "$OPTS,subvol=cargo" "/dev/mapper/$LUKS_NAME" /mnt/cargo
    # (on ne monte pas $ROOT_SNAPSHOT qui sert uniquement pour wiper $ROOT)

    echo "✓ Terminé. Disque prêt pour l'installation."
}
