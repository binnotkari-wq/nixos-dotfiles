# niri_theme.nix — Home Manager
# Thème visuel pour niri : curseur, GTK, polices, waybar
{ config, pkgs, ... }:
{

xdg.configFile."niri/config.kdl".source = ./prefs_niri.kdl;


  # ─── Curseur ──────────────────────────────────────────────────────────────
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = false; # on est en Wayland pur
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  # ─── Thème GTK ────────────────────────────────────────────────────────────
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3; # GTK3 dans le style Adwaita/libadwaita
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    font = {
      name = "Adwaita Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = false;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = false;
    };
  };

  # ─── Polices ──────────────────────────────────────────────────────────────
fonts.fontconfig = {
  enable = true;
  defaultFonts = {
    sansSerif = [ "Adwaita Sans" ];
    serif     = [ "Adwaita Sans" ];
    monospace = [ "Adwaita Mono" ];
    emoji     = [ "Noto Color Emoji" ];
  };
};

  home.packages = with pkgs; [
    # cantarell-fonts       # police système GNOME
    noto-fonts            # couverture unicode large
    noto-fonts-color-emoji      # emojis
    # nerd-fonts.jetbrains-mono
    adwaita-fonts
  ];


programs.kitty = {
  enable = true;
  settings = {
    hide_window_decorations = "yes";
    # Optionnel : thème, police, etc.
    dynamic_background_opacity = true;
    enable_audio_bell = false;
    mouse_hide_wait = "-1.0";
    window_padding_width = 10;
    background_opacity = "0.5";
    background_blur = 5;
    
  };
};


}
