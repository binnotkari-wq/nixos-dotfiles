{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball {
   url = "https://github.com/nix-community/home-manager/archive/release-@@NIXOSVERSION@@.tar.gz";
   # sha256 = "sha256:13sahz1mxbk7n67jvz9fi0f85ax7l6s3ffiwa6x0rfrwfwhgj7x3"; (optionnel, pour verrouiller le commit qu'on, va utiliser)
   # nix-prefetch-url --unpack https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz # pour obtenir le SHA
  };
in

{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true; # également utile pour déclarer des scripts et des raccourcis .desktop

  home-manager.users.@@USERNAME@@ = { config, pkgs, lib, ... }: {
    imports = [
      ./options/prefs_git.nix
      ./options/bash.nix
      ./options/dconf_gnome.nix
    ];
    
    home.username = "@@USERNAME@@";
    home.homeDirectory = "/home/@@USERNAME@@";
    home.stateVersion = "@@NIXOSVERSION@@"; # à adapter à la version NixOS

    # ============================================================
    # XDG USER DIRS
    # ============================================================
    # xdg.userDirs gère ~/.config/user-dirs.dirs de façon déclarative.
    # Les chemins sont relatifs à $HOME, ou absolus.
    # NixOS crée les dossiers automatiquement si enable = true.

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop     = "${config.home.homeDirectory}/Bureau";
      download    = "${config.home.homeDirectory}/Téléchargements";
      templates   = "${config.home.homeDirectory}/Modèles";
      publicShare = "${config.home.homeDirectory}/Public";
      documents   = "${config.home.homeDirectory}/Documents";
      music       = "${config.home.homeDirectory}/Mes-Donnees/03_Ressources_Externes/Musique";
      pictures    = "${config.home.homeDirectory}/Images";
      videos      = "${config.home.homeDirectory}/Vidéos";
    };

    # ============================================================
    # MIME / ASSOCIATIONS
    # ============================================================

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/x-shellscript" = "org.gnome.TextEditor.desktop";
        "inode/symlink"             = "org.gnome.TextEditor.desktop";
      };
    };

    # ============================================================
    # RACCOURCIS VERS LES SCRIPTS
    # ============================================================

    xdg.desktopEntries = {
      llm-start = {
        name = "Démarrer LLM";
        exec = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/start_llm.sh";
        terminal = true;
        icon = "media-playback-start";
        type = "Application";
        comment = "Lance le serveur llama.cpp";
        categories = [ "Education" ];
      };

      llm-stop = {
        name = "Arrêter LLM";
        exec = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/stop_llm.sh";
        terminal = false;
        icon = "media-playback-stop";
        type = "Application";
        comment = "Arrête le serveur llama.cpp";
        categories = [ "Education" ];
      };

      kiwix = {
        name = "Démarrer Kiwix";
        exec = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/kiwix-launcher.sh";
        terminal = false;
        icon = "accessories-dictionary";
        type = "Application";
        comment = "Lance le serveur Kiwix";
        categories = [ "Education" ];
      };
    };
  };
}
