#!/usr/bin/env bash
#






# ------------------------------------------------------------------------------
# 8) Génération de variables.nix à partir de variable_template.nix
# ------------------------------------------------------------------------------





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



# --- rootSubvolumeName ---
ROOT_SUBVOLUME=$(btrfs subvolume show / | head -n1 | xargs)
if [[ -z "$ROOT_SUBVOLUME" ]]; then
    echo "⚠ Impossible de détecter le nom du subvolume racine."
    read -rp "Entre-le manuellement : " ROOT_SUBVOLUME
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
