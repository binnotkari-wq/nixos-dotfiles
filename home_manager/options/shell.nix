# shell.nix — configuration du shell (bash) pour Home Manager
{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true; # Home Manager gère .bashrc et .profile

    # ── Alias ────────────────────────────────────────────────────────────
    shellAliases = {
      ll      = "ls -l";
      nrs     = "sudo nixos-rebuild switch";
      garbage = "nix-collect-garbage -d";
      bkp     = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/backup.sh";
      bh      = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/bash-history-export.sh";
      gt      = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/git-sync.sh";
    };

    # ── Historique ───────────────────────────────────────────────────────
    historySize = 100000;
    historyFileSize = 100000;

    bashrcExtra = ''
      export PATH="${config.home.homeDirectory}/Mes-Donnees/Git/scripts:$PATH"

      # Integration zoxide
      eval "$(zoxide init bash)"

      # Prompt façon GNOME Terminal
      PS1='\[\e[01;32m\][\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[01;32m\]]\$\[\e[00m\] '

      # Historique : format horodaté + append immédiat
      HISTTIMEFORMAT="%s "
      shopt -s histappend
      echo "# SESSION $(date +%s)" >> "$HISTFILE"
      PROMPT_COMMAND="history -a''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

      # Message de bienvenue NixOS (shell interactif non-login)
      if [[ $- == *i* ]]; then
        bash "$HOME/.config/shell/nixos-welcome.sh"
      fi
    '';

    profileExtra = ''
      # Message de bienvenue NixOS (terminal virtuel, SSH, login shell)
      if [[ $- == *i* ]]; then
        bash "$HOME/.config/shell/nixos-welcome.sh"
      fi
    '';
  };

  # ── Script de bienvenue ────────────────────────────────────────────────
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
      echo -e "''${PURPLE}⬡''${RESET}  ''${BOLD}''${BLUE}Bienvenue sur NixOS''${RESET}  ''${GRAY}— $HOSTNAME''${RESET}"
      echo ""

      # ── Rebuild & mise à jour ──────────────────────────────────────────────
      echo -e "''${YELLOW}▸ REBUILD & MISE À JOUR''${RESET}"
      echo -e "  ''${CYAN}sudo nixos-rebuild switch''${RESET}           ''${GRAY}# Applique la config et active immédiatement''${RESET}"
      echo -e "  ''${CYAN}sudo nixos-rebuild boot''${RESET}             ''${GRAY}# Applique au prochain redémarrage''${RESET}"
      echo -e "  ''${CYAN}sudo nixos-rebuild test''${RESET}             ''${GRAY}# Teste sans changer le bootloader''${RESET}"
      echo ""

      # ── Nix store & paquets ────────────────────────────────────────────────
      echo -e "''${YELLOW}▸ NIX STORE & PAQUETS''${RESET}"
      echo -e "  ''${CYAN}nix-shell -p <paquet>''${RESET}               ''${GRAY}# Shell temporaire avec le paquet''${RESET}"
      echo -e "  ''${CYAN}nix-collect-garbage -d''${RESET}              ''${GRAY}# Supprime les générations et nettoie''${RESET}"
      echo -e "  ''${CYAN}du -sh /nix/store''${RESET}                   ''${GRAY}# Taille occupée par le store (compression zstd ignorée)''${RESET}"
      echo ""

      # ── Générations & rollback ─────────────────────────────────────────────
      echo -e "''${YELLOW}▸ GÉNÉRATIONS & ROLLBACK''${RESET}"
      echo -e "  ''${CYAN}nixos-rebuild list-generations''${RESET}      ''${GRAY}# Liste toutes les générations''${RESET}"
      echo -e "  ''${CYAN}nix-env -p /nix/var/nix/profiles/system --delete-generations 1 2 3 5''${RESET} ''${GRAY}# Supprime ces générations''${RESET}"
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
}
