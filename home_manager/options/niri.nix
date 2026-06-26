# niri_theme.nix — Home Manager
# Thème visuel pour niri : curseur, GTK, polices, waybar
{ config, pkgs, ... }:
{

# xdg.configFile."niri/config.kdl".source = ./niri.kdl;


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
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
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
}
