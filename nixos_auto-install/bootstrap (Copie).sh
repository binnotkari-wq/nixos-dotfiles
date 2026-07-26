#!/usr/bin/env bash



# ═══════════════════════════════════════════════════════════════════════════
#  ÉTAPE 3/6 — INSTALLATION DE NIXOS
#  Collecte des informations, génération de variables.nix et de
#  hardware-configuration.nix, puis lancement de nixos-install.
# ═══════════════════════════════════════════════════════════════════════════
installer_Nixos() {






    # ─── 7. Génération de variables.nix ──────────────────────────────────

    # ─── 8. Confirmation avant installation ──────────────────────────────
    echo ""
    echo "══════════════════════════════════════════"
    echo "  Récapitulatif avant installation"
    echo "══════════════════════════════════════════"
    echo "  Version              : $NIXOS_VERSION"
    echo "  Utilisateur          : $USERNAME ($USERNAME_DISPLAY)"
    echo "  Hostname             : $HOSTNAME"
    echo "  Machine-id           : $MACHINEID"
    echo "  Utilisateur github   : $GIT_USERNAME"
    echo "  Adresse mail github  : $GIT_USERMAIL"
    echo "  Cible                : /mnt"
    echo "══════════════════════════════════════════"
    echo ""
    read -rp "Lancer nixos-install ? (oui) : " CONFIRM
    [[ "$CONFIRM" == "oui" ]] || { echo "Annulé."; exit 1; }


}




