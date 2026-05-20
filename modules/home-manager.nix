{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-@@NIXOSVERSION@@.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;

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

    };
  };
}
