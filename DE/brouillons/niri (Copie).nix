{ config, pkgs, ... }:
{
  # ─── Compositeur Wayland ───────────────────────────────────────────────────
  programs.niri.enable = true;

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

  # Correctif PATH nécessaire : sans ça, le service systemd niri.service
  # reçoit un PATH tronqué qui masque celui configuré par niri-session.
  systemd.user.services.niri.enableDefaultPath = false;

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
    # Lanceur d'applications (remplace fuzzel par défaut dans la config niri)
    fuzzel

    # Terminal (requis par la config niri par défaut)
    alacritty

    # Barre de statut
    waybar

    # Notifications
    mako

    # Verrouillage d'écran
    swaylock
    swayidle

    # Presse-papier Wayland (indispensable : pas de clipboard persistant sinon)
    wl-clipboard
    cliphist

    # Fond d'écran
    # swaybg

    # Captures d'écran
    # grim
    # slurp

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
    gnome-console
  ];
}
