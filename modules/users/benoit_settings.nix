{ pkgs, ... }:

{
  # Configuration de Git
  programs.git = {
    enable = true;
    config = {
      user.name  = "binnotkari-wq";
      user.email = "benoit.dorczynski@gmail.com";
      init.defaultBranch = "main";
      core.editor = "nano";
      credential.helper = "store"; # Stocke le token de manière persistante (dans ~/.git-credentials)
    };
  };

  # Configuration de bash
  programs.bash = {

    interactiveShellInit = ''
      echo -e "\e[36m=== Raccourcis =====================================\e[0m"
      echo -e "- \e[33mapps : liste des logiciels CLI / TUI astucieux"
      echo -e "- \e[33msys : commandes système spécifique Nixos"
      echo -e "- \e[33mupd : commande de mises à jour système et git"
      echo -e "\e[36m=== Installer un logiciel =====================================\e[0m"
      echo -e "- \e[33mnix-shell -p nomdulogiciel\e[0m : installer provisoirement un logiciel"
      echo -e "- \e[33mflatpak install --user flathub nomdulogiciel\e[0m" : le flatpak sera installé dans le repo flatpak userspace, depuis flathub
      echo -e "\e[36m=== outils de monitoring harware ======================================\e[0m"
      echo -e "- \e[33mradeontop - nvtop - powertop - btop\e[0m"

      if [[ $SHLVL -eq 1 ]]; then
        history -s "# SESSION $(date +%s) $$"
        history -a
      fi
    '';

    # Alias
    shellAliases = {
      ll = "ls -l";
      # Plus de --flake ! On utilise le NIX_PATH défini dans configuration.nix
      update = "sudo nixos-rebuild switch -I nixos-config=/home/benoit/Mes-Donnees/Git/nixos-dotfiles/configuration.nix";
      garbage = "nix-collect-garbage -d";
      apps = ''awk '/environment.systemPackages = with pkgs; \[/ {flag=1; next} /\];/ {flag=0} flag' ~/Mes-Donnees/Git/nixos-dotfiles/OS/CLI_tools.nix'';
      sys = ''printf "
\e[33msudo nixos-rebuild test -I nixos-config=/home/benoit/Mes-Donnees/Git/nixos-dotfiles/configuration.nix\e[0m : rebuild simple\n
\e[33msudo nixos-rebuild boot -I nixos-config=/home/benoit/Mes-Donnees/Git/nixos-dotfiles/configuration.nix\e[0m : nouvelle entrée de boot\n
\e[33msudo nixos-rebuild switch -I nixos-config=/home/benoit/Mes-Donnees/Git/nixos-dotfiles/configuration.nix\e[0m : rebuild et bascule live\n
\e[33msudo nix-env --list-generations --profile /nix/var/nix/profiles/system\e[0m : lister les générations\n\e[33msudo nix-collect-garbage -d\e[0m : gros nettoyage\n" '';
      upd = ''printf "
\e[33mflatpak update -y\e[0m : mise à jour flatpaks\n
\e[33mcd ~/Mes-Donnees/Git/nixos-dotfiles && git add . && git commit -m \"update\" && git push\e[0m : synchro git\n" '';
    };
  };

  # 5. Variables de session
  environment.sessionVariables = {
    FLATPAK_DOWNLOAD_TMPDIR = "$HOME/.flatpak-tmp";
    HISTTIMEFORMAT = "%d/%m/%y %T ";
  };
}
