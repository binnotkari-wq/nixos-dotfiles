{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-@@NIXOSVERSION@@.tar.gz;
in

{
  imports =
    [
      (import "${home-manager}/nixos")
    ];
  
  home.username = "@@USERNAME@@";
  home.homeDirectory = "/home/@@USERNAME@@";
  home.stateVersion = "@@NIXOSVERSION@@"; # à adapter à la version NixOS
  home-manager.useGlobalPkgs = true; # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
  
  # ============================================================
  # FICHIERS DE CONFIG
  # ============================================================

  home.file.".config/user-dirs.dirs".text = ''
    XDG_DESKTOP_DIR="$HOME/Bureau"
    XDG_DOWNLOAD_DIR="$HOME/Téléchargements"
    XDG_TEMPLATES_DIR="$HOME/Modèles"
    XDG_PUBLICSHARE_DIR="$HOME/Public"
    XDG_DOCUMENTS_DIR="$HOME/Documents"
    XDG_MUSIC_DIR="$HOME/Mes-Donnees/03_Ressources_Externes/Musique"
    XDG_PICTURES_DIR="$HOME/Images"
    XDG_VIDEOS_DIR="$HOME/Vidéos"
  '';
  
  # et ca ??
    # XDG user dirs
  xdg.userDirs = {
    Documents = "Documents";
    Downloads = "Downloads";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-shellscript" = "org.gnome.TextEditor.desktop";
      "inode/symlink" = "org.gnome.TextEditor.desktop";
    };
  };

  # ============================================================
  # DCONF - GNOME
  # ============================================================

  dconf.settings = {

    # Clavier
    "org/gnome/desktop/input-sources" = {
      sources = [( "xkb" "fr+azerty" )];
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    # Raccourcis fenêtres
    "org/gnome/desktop/wm/keybindings" = {
      maximize = [ "<Super>Up" ];
      unmaximize = [ "<Super>Down" "<Alt>F5" ];
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Super>Left" ];
      toggle-tiled-right = [ "<Super>Right" ];
    };

    # Shell : extension et barre des tâches
    "org/gnome/shell" = {
      enabled-extensions = [ "dash-to-panel@jderose9.github.com" ];
      disable-user-extensions = false;
      favorite-apps = [
        "org.mozilla.firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Ptyxis.desktop"
        "org.gnome.TextEditor.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.SystemMonitor.desktop"
      ];
    };

    # Dash-to-Panel
    "org/gnome/shell/extensions/dash-to-panel" = {
      dot-position = "BOTTOM";
      intellihide = true;
      hotkeys-overlay-combo = "TEMPORARILY";
      window-preview-title-position = "TOP";
    };

    # Nautilus
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-create-link = true;
      date-time-format = "detailed";
    };
    "org/gnome/nautilus/list-view" = {
      use-tree-view = true;
      default-visible-columns = [ "name" "size" "type" "date_modified" ];
    };

    # Vie privée
    "org/gnome/desktop/privacy" = {
      report-technical-problems = false;
    };

    # Gestionnaire de fichiers GTK4
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
      sort-directories-first = true;
    };

  };
}
