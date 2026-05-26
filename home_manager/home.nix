        { config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball {
   url = "https://github.com/nix-community/home-manager/archive/release-@@NIXOSVERSION@@.tar.gz";
   # sha256 = "sha256:13sahz1mxbk7n67jvz9fi0f85ax7l6s3ffiwa6x0rfrwfwhgj7x3";
  };
in

{
  imports = [
    (import "${home-manager}/nixos")
    ./options/prefs_git.nix
    ./options/bash.nix
  ];

  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true; # également utile pour déclarer des scripts et des raccourcis .desktop

  home-manager.users.@@USERNAME@@ = { config, pkgs, lib, ... }: {
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
        exec = "/home/@@USERNAME@@/Mes-Donnees/Git/scripts/start_llm.sh";
        terminal = true;
        icon = "media-playback-start";
        type = "Application";
        comment = "Lance le serveur llama.cpp";
        categories = [ "Education" ];
      };

      llm-stop = {
        name = "Arrêter LLM";
        exec = "/home/@@USERNAME@@/Mes-Donnees/Git/scripts/stop_llm.sh";
        terminal = false;
        icon = "media-playback-stop";
        type = "Application";
        comment = "Arrête le serveur llama.cpp";
        categories = [ "Education" ];
      };

      kiwix = {
        name = "Démarrer Kiwix";
        exec = "/home/@@USERNAME@@/Mes-Donnees/Git/scripts/kiwix-launcher.sh";
        terminal = false;
        icon = "accessories-dictionary";
        type = "Application";
        comment = "Lance le serveur Kiwix";
        categories = [ "Education" ];
      };
    };

    # ============================================================
    # DCONF - GNOME
    # ============================================================

    dconf.settings = {

      # Clavier - disposition
      "org/gnome/desktop/input-sources" = {
        sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "fr+azerty" ]) ];
      };
      "org/gnome/desktop/peripherals/keyboard" = {
        numlock-state = true;
      };

      # Raccourcis fenêtres
      "org/gnome/desktop/wm/keybindings" = {
        maximize   = [ "<Super>Up" ];
        unmaximize = [ "<Super>Down" "<Alt>F5" ];
      }; 
      
      # Bouton réduire et agrandire la fenêtre     
      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":minimize,maximize,close";
      };
      
      "org/gnome/mutter" = {
        edge-tiling = true;
      };
      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left  = [ "<Super>Left" ];
        toggle-tiled-right = [ "<Super>Right" ];
      };

      # Shell : extensions et barre des tâches
      "org/gnome/shell" = {
        enabled-extensions     = [ "dash-to-panel@jderose9.github.com" ];
        disable-user-extensions = false;
        favorite-apps = [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
          "org.gnome.TextEditor.desktop"
          "org.gnome.Calculator.desktop"
          "org.gnome.SystemMonitor.desktop"
        ];
      };

      # Dash-to-Panel
      "org/gnome/shell/extensions/dash-to-panel" = {
        dot-position             = "BOTTOM";
        intellihide              = true;
        hotkeys-overlay-combo    = "TEMPORARILY";
        window-preview-title-position = "TOP";
      };

      # Nautilus
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        show-create-link      = true;
        date-time-format      = "detailed";
      };
      "org/gnome/nautilus/list-view" = {
        use-tree-view           = true;
        default-visible-columns = [ "name" "size" "type" "date_modified" ];
      };

      # Vie privée
      "org/gnome/desktop/privacy" = {
        report-technical-problems = false;
      };

      # Gestionnaire de fichiers GTK4
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden           = true;
        sort-directories-first = true;
      };

      # Editeur de texte
      "org/gnome/TextEditor" = {
        show-line-numbers     = true;
        highlight-current-line = true;
        restore-session       = false;
        # show-right-margin     = true;
        show-map              = true;    # minimap du fichier sur la droite
        auto-indent           = true;    # indentation automatique
        indent-style          = "space"; # "space" ou "tab"
        wrap-text             = false;   # pas de retour à la ligne automatique
        spellcheck            = false;   # correcteur ortho (souvent gênant pour du code)
        recolor-window        = true;    # la fenêtre prend la couleur du thème de l'éditeur
        keybindings           = "default"; # "default", "vim" ou "emacs" !
        style-variant         = "follow"; # suit le thème système ("follow", "light", "dark")
        draw-spaces	      = [ "space" "tab" "newline" "trailing" "leading" ];
      };
    };

  };
}
