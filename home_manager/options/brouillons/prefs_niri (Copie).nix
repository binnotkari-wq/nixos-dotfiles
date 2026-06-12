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
    sansSerif = [ "Adwaita Sans" "Noto Sans" ];
    serif     = [ "Adwaita Sans" "Noto Serif" ];
    monospace = [ "Adwaita Mono" "JetBrainsMono Nerd Font" ];
    emoji     = [ "Noto Color Emoji" ];
  };
};

  home.packages = with pkgs; [
    cantarell-fonts       # police système GNOME
    noto-fonts            # couverture unicode large
    noto-fonts-color-emoji      # emojis
    nerd-fonts.jetbrains-mono
    adwaita-fonts
  ];

  # ─── Wlogout ───────────────────────────────────────────────────────────────

xdg.configFile."wlogout/layout".text = ''
  {
    "label" : "lock",
    "action" : "swaylock",
    "text" : "Verrouiller",
    "keybind" : "l"
  }
  {
    "label" : "hibernate",
    "action" : "systemctl hibernate",
    "text" : "Hibernation",
    "keybind" : "h"
  }
  {
    "label" : "logout",
    "action" : "niri msg action quit",
    "text" : "Déconnexion",
    "keybind" : "e"
  }
  {
    "label" : "shutdown",
    "action" : "systemctl poweroff",
    "text" : "Éteindre",
    "keybind" : "s"
  }
  {
    "label" : "suspend",
    "action" : "systemctl suspend",
    "text" : "Veille",
    "keybind" : "u"
  }
  {
    "label" : "reboot",
    "action" : "systemctl reboot",
    "text" : "Redémarrer",
    "keybind" : "r"
  }
'';

xdg.configFile."wlogout/style.css".text = ''
  * {
    font-family: Cantarell, sans-serif;
    background-color: transparent;
  }

  window {
    background-color: rgba(30, 30, 46, 0.9);
  }

  button {
    color: #cdd6f4;
    background-color: rgba(49, 50, 68, 0.8);
    border: 2px solid transparent;
    border-radius: 12px;
    margin: 8px;
    font-size: 14px;
    font-weight: 600;
  }

  button:hover {
    background-color: rgba(137, 180, 250, 0.2);
    border-color: #89b4fa;
    color: #89b4fa;
  }

  #lock     { background-image: image(url("/run/current-system/sw/share/wlogout/icons/lock.png")); }
  #logout   { background-image: image(url("/run/current-system/sw/share/wlogout/icons/logout.png")); }
  #suspend  { background-image: image(url("/run/current-system/sw/share/wlogout/icons/suspend.png")); }
  #hibernate{ background-image: image(url("/run/current-system/sw/share/wlogout/icons/hibernate.png")); }
  #shutdown { background-image: image(url("/run/current-system/sw/share/wlogout/icons/shutdown.png")); }
  #reboot   { background-image: image(url("/run/current-system/sw/share/wlogout/icons/reboot.png")); }
'';






  # ─── Waybar ───────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 4;

        modules-left   = [ "niri/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" "custom/power" ];

        "custom/power" = {
           format = "";
           on-click = "wlogout";
           tooltip = false;
        };

        "niri/workspaces" = {
          format = "{name}";
        };

        "clock" = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
        };

        "cpu" = {
          format = " {usage}%";
          interval = 5;
        };

        "memory" = {
          format = " {used:.1f}G";
          interval = 10;
        };

        "battery" = {
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          states = { warning = 30; critical = 15; };
        };

        "network" = {
          format-wifi = " {signalStrength}%";
          format-ethernet = " eth";
          format-disconnected = "⚠ déconnecté";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " muet";
          format-icons = { default = [ "" "" "" ]; };
          on-click = "pavucontrol";
        };

        "tray" = {
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        font-family: Cantarell, sans-serif;
        font-size: 13px;
        min-height: 0;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: #1e1e2e;
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 8px;
        color: #6c7086;
        background: transparent;
      }

      #workspaces button.active {
        color: #cdd6f4;
        border-bottom: 2px solid #89b4fa;
      }

      #workspaces button:hover {
        color: #89b4fa;
        background: rgba(137, 180, 250, 0.1);
      }

      #clock {
        color: #cdd6f4;
        font-weight: 600;
      }

      #cpu, #memory, #battery, #network, #pulseaudio, #tray {
        padding: 0 10px;
        color: #cdd6f4;
      }

      #battery.warning  { color: #f9e2af; }
      #battery.critical { color: #f38ba8; }

      #network.disconnected { color: #f38ba8; }
    '';
  };
}
