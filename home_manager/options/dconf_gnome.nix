{ config, pkgs, lib, ... }:

# A utiliser en tant qu'import home manager.

{

home.file.".local/bin/open-music-player.sh" = {
  executable = true;
  text = ''
    #!/usr/bin/env bash
    desktop=$(xdg-mime query default audio/mpeg)
    gtk-launch "''${desktop%.desktop}"
  '';
};





    dconf.settings = {

      # Clavier - disposition
      "org/gnome/desktop/input-sources" = {
        sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "fr+azerty" ]) ];
      };
      "org/gnome/desktop/peripherals/keyboard" = {
        numlock-state = true;
      };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open Gmail";
      command = "xdg-open https://mail.google.com";
      binding = "XF86Mail";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Open Music Player";
      command = "${config.home.homeDirectory}/.local/bin/open-music-player.sh";
      binding = "XF86Tools";
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
      
      "org/gnome/desktop/interface" = {
        accent-color = "yellow";
        color-scheme = "prefer-dark";
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
}
