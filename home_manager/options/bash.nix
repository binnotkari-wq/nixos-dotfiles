{ config, pkgs, ... }:

# A utiliser en tant qu'import home manager.

{
      # ─── Message de bienvenue stocké comme fichier géré par Home Manager ───────
      home.file.".config/shell/nixos-welcome.sh" = {
        executable = true;
        text = ''
        #!/usr/bin/env bash

        # Couleurs ANSI
        RESET='\033[0m'
        BOLD='\033[1m'
        CYAN='\033[0;36m'
        GREEN='\033[0;32m'
        YELLOW='\033[0;33m'
        PURPLE='\033[0;35m'
        GRAY='\033[0;90m'
        RED='\033[0;31m'
        BLUE='\033[0;34m'

        echo ""
        echo -e "''${YELLOW}┌──────────────────────────────────────────────────────┐''${RESET}"
        echo -e "''${YELLOW}│''${RESET}  ''${PURPLE}⬡''${RESET}  ''${BOLD}''${BLUE}Bienvenue sur NixOS''${RESET}  ''${GRAY}— $HOSTNAME''${RESET}  ''${YELLOW}               │''${RESET}"
        echo -e "''${YELLOW}└──────────────────────────────────────────────────────┘''${RESET}"
        echo ""

        # ── Rebuild & mise à jour ──────────────────────────────────────────────
        echo -e "''${YELLOW}▸ REBUILD & MISE À JOUR''${RESET}"
        echo -e "  ''${CYAN}sudo nixos-rebuild switch''${RESET}           ''${GRAY}# Applique la config et active immédiatement''${RESET}"
        echo -e "  ''${CYAN}sudo nixos-rebuild boot''${RESET}             ''${GRAY}# Applique au prochain redémarrage''${RESET}"
        echo -e "  ''${CYAN}sudo nixos-rebuild test''${RESET}             ''${GRAY}# Teste sans changer le bootloader''${RESET}"
        echo ""

        # ── Nix store & paquets ────────────────────────────────────────────────
        echo -e "''${YELLOW}▸ NIX STORE & PAQUETS''${RESET}"
        echo -e "  ''${CYAN}nix search nixpkgs <paquet>''${RESET}         ''${GRAY}# Cherche un paquet dans nixpkgs''${RESET}"
        echo -e "  ''${CYAN}nix shell nixpkgs#<paquet>''${RESET}          ''${GRAY}# Shell temporaire avec le paquet''${RESET}"
        echo -e "  ''${CYAN}nix-collect-garbage -d''${RESET}              ''${GRAY}# Supprime les générations et nettoie''${RESET}"
        echo -e "  ''${CYAN}nix store gc''${RESET}                        ''${GRAY}# Garbage collect (commande moderne)''${RESET}"
        echo -e "  ''${CYAN}du -sh /nix/store''${RESET}                   ''${GRAY}# Taille occupée par le store (compression zstd ignorée)''${RESET}"
        echo ""

        # ── Générations & rollback ─────────────────────────────────────────────
        echo -e "''${YELLOW}▸ GÉNÉRATIONS & ROLLBACK''${RESET}"
        echo -e "  ''${CYAN}nixos-rebuild list-generations''${RESET}      ''${GRAY}# Liste toutes les générations''${RESET}"
        echo -e "  ''${RED}sudo nixos-rebuild switch --rollback''${RESET} ''${GRAY}# Revenir à la génération précédente''${RESET}"
        echo ""

        # ── Diagnostic ─────────────────────────────────────────────────────────
        echo -e "''${YELLOW}▸ DIAGNOSTIC''${RESET}"
        echo -e "  ''${CYAN}journalctl -b -p err''${RESET}                ''${GRAY}# Erreurs depuis le dernier boot''${RESET}"
        echo -e "  ''${CYAN}systemctl --failed''${RESET}                  ''${GRAY}# Services en échec''${RESET}"
        echo -e "  ''${CYAN}nix-store --verify --check-contents''${RESET} ''${GRAY}# Vérifie l'intégrité du store''${RESET}"
        echo ""

        # ── Utiles ─────────────────────────────────────────────────────────────
        echo -e "''${YELLOW}▸ UTILES''${RESET}"
        echo -e "  ''${CYAN}alias''${RESET}                               ''${GRAY}# Liste les commandes personnalisées''${RESET}"
        echo -e "  ''${CYAN}sudo compsize /nix''${RESET}                  ''${GRAY}# Taille occupée par l'OS (tenant compte de la compression zstd)''${RESET}"
        echo ""
        '';
      };


      # ─── Configuration bash ────────────────────────────────────────────────────
      programs.bash = {
        enable = true; # pour que home-manager puis gérer .bashrc et .profile
        sessionVariables = {};  # optionnel

        bashrcExtra = ''
          export PATH="${config.home.homeDirectory}/Mes-Donnees/Git/scripts:$PATH"
          # Message de bienvenue NixOS (uniquement en shell interactif non-login)
          if [[ $- == *i* ]]; then
            bash "$HOME/.config/shell/nixos-welcome.sh"
          fi
        '';

        # Optionnel : affiche aussi au login shell (terminal virtuel, SSH)
        profileExtra = ''
          if [[ $- == *i* ]]; then
            bash "$HOME/.config/shell/nixos-welcome.sh"
          fi
        '';
      };
}
