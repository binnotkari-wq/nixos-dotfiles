{ config, pkgs, ... }:
{

# services à activer explicitement (sous gnome par contre, ils sont activé en dépendances)
services.udev.packages = [ pkgs.brightnessctl ];

    # ─── Login manager : greetd + tuigreet ────────────────────────────────────
  # greetd est le choix de référence dans l'écosystème niri.
  # tuigreet est un frontend TUI sobre qui fonctionne sans X ni Wayland.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # ─── Compositeur Wayland ───────────────────────────────────────────────────
  programs.niri.enable = true;

  # Correctif PATH nécessaire : sans ça, le service systemd niri.service
  # reçoit un PATH tronqué qui masque celui configuré par niri-session.
  # systemd.user.services.niri.enableDefaultPath = false;

  # ─── Services complémentaires ─────────────────────────────────────────────
  # Agent Polkit indispensable pour les actions privilégiées (montage, etc.)
  security.polkit.enable = true;

  # XDG portal pour les sélecteurs de fichiers, captures d'écran, partage d'écran
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.niri.default = [ "gnome" "gtk" ];
  };

  # ─── Paquets système ──────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    
    # Shell graphique
    # noctalia-shell
    waybar # barre de statut
    swaynotificationcenter
    fuzzel # Lanceur d'applications
    mako # Notifications
    swaylock # Verrouillage d'écran
    swayidle # Verrouillage d'écran
    wl-clipboard # Presse-papier Wayland (indispensable : pas de clipboard persistant sinon)
    cliphist # Presse-papier Wayland (indispensable : pas de clipboard persistant sinon)
    # swaybg # Fond d'écran
    # grim # Captures d'écran
    # slurp # Captures d'écran
    
    
    # Terminal
    kitty
    # foot
    # alacritty
    
    # Controle de la luminosité de l'écran avec le clavier
    brightnessctl

    # Clavier virtuel (à associer à la touche clavier dans la config niri)
    wvkbd
    
    # Controle de l'écran
    wdisplays

    # Réglages visuels GTK sous Wayland
    gsettings-desktop-schemas
    gnome-themes-extra

    # Logiciels de base
    gnome-text-editor
    nautilus
    gnome-calculator
    gnome-system-monitor
    gnome-disk-utility
    baobab
    seahorse
    fragments
    gnome-secrets
    shortwave
    smile
    deja-dup
  ];
}
