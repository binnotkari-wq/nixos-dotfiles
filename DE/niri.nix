{ config, pkgs, ... }:
{



  # ─── Login manager : greetd + tuigreet ────────────────────────────────────
  # greetd est le choix de référence dans l'écosystème niri.
  # tuigreet est un frontend TUI sobre qui fonctionne sans X ni Wayland.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        # command = ''${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session --theme "text=#d4be98;title=#d4be98;container=#282828;border=#7c6f64;greet=#a9b665;prompt=#a9b665;input=#d8a657;time=#665c54;action=#665c54;button=#ea6962"'';
        command = ''${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session --theme "border=dark-gray;text=white;greet=green;prompt=green;input=yellow;button=red;container=black;time=dark-gray;action=dark-gray;title=white"'';
        user = "greeter";
      };
    };
  };

  # ─── Compositeur Wayland ───────────────────────────────────────────────────
  programs.niri.enable = true;

  # Correctif PATH nécessaire : sans ça, le service systemd niri.service
  # reçoit un PATH tronqué qui masque celui configuré par niri-session.
  systemd.user.services.niri.enableDefaultPath = false;

  # ─── Environnement ────────────────────────────────────────────────────────
  # ─── Services complémentaires ─────────────────────────────────────────────
  # services à activer explicitement (sous gnome par contre, ils sont activé en dépendances)
  services.udev.packages = [ pkgs.brightnessctl ];
  services.udisks2.enable = true;
  # services.dbus.packages = [ pkgs.nautilus ];                                 # Ne pas activer : ne sont utiles que si on veut construire une infrastructure Gnome
  services.gvfs.enable = true;                                                  # Permet la gestion des systèmes de fichiers depuis PCManFM, entre autres.
  # services.gnome.localsearch.enable = true;                                   # Ne pas activer : ne sont utiles que si on veut construire une infrastructure Gnome
  # systemd.user.services."localsearch-3".unitConfig.ConditionEnvironment = ""; # Ne pas activer : ne sont utiles que si on veut construire une infrastructure Gnome

  # https://wiki.nixos.org/wiki/Niri - Service annexes essentiels
  services.gnome.gnome-keyring.enable = true; # secret service
  security.polkit.enable = true; # Agent Polkit indispensable pour les actions privilégiées (montage, etc.)
  security.pam.services.swaylock = {};

  # https://wiki.nixos.org/wiki/Niri - XDG portal pour les sélecteurs de fichiers, captures d'écran, partage d'écran
  xdg.portal = {
    enable = true;
    # extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # config.niri.default = [ "gnome" "gtk" ];
    config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  # Empecher l'installation de Nautilus et ses dépendances (DBUS l'emmène dans ses dépendances, alors que ce n'est pas nécessaire en soi
  nixpkgs.overlays = [
      (final: prev: {
        nautilus = prev.runCommand "nautilus-stub" {} "mkdir -p $out/bin";
      })
    ];

# On indique au système quel est legestionnaire de fichiers par défaut
xdg.mime = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "pcmanfm.desktop" ];
    };
  };


# Force le raccourci de GParted à utiliser sudo -E pour préserver l'affichage Wayland
xdg.desktopEntries = {
  gparted = {
    name = "GParted";
    genericName = "Partition Editor";
    exec = "sudo -E gparted";
    icon = "gparted";
    categories = [ "System" "Filesystem" ];
    terminal = false;
  };
};


  # ─── Paquets système ──────────────────────────────────────────────────────

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

  environment.systemPackages = with pkgs; [
    # Shell graphique
    waybar                                              # PERSO OK - barre de statut
    fuzzel                                              # PERSO OK - Lanceur d'applications
    swaybg                                              # PERSO OK - Fond d'écran
    mako                                                # PERSO NOK - Notifications
    pcmanfm                                             # PERSO NOK + A FAIRE : trouver comment associer les fichiers aux applications - explorateur de fichiers. Peu de dépendances et recherche de contenu.
    polkit_gnome                                        # interface graphique à polkit (boites de dialogue authentification)
    dex                                                 # permet de passer en autostart les fichiers .desktop
    # wlogout # pour essayer
    # gtklock # pour essayer
    # gtkgreet # pour essayer

    
    # Réglages visuels GTK sous Wayland
    # gsettings-desktop-schemas
    # gnome-themes-extra
    nerd-fonts.jetbrains-mono



    # Panneaux de configuration
    networkmanagerapplet # configuration réseau
    pavucontrol # configuration son
    wdisplays # configuration écran
    blueman # configuration bluetooth
    waypaper

    swaylock # Verrouillage d'écran                     # A FAIRE : activer à la mise en veille
    swayidle # Verrouillage d'écran                     # A FAIRE : activer à la mise en veille
    wl-clipboard                                        # Presse-papier Wayland (indispensable : pas de clipboard persistant sinon)
    

    yazi # explorateur de fichiers TUI modulaire
    yaziPlugins.mount
    yaziPlugins.chmod
    yaziPlugins.compress
    yaziPlugins.full-border
    yaziPlugins.recycle-bin
    md-tui                                              # visualisateur Markdown. Winner : le plus agréable. Permet d'editer, de rechercher...
    # mdfried                                           # visualisateur Markdown
    # glow                                              # visualisateur Markdown
    kitty
    cliphist                                            # Visualisation de l'historique du presse-papier


    # Controle de la luminosité de l'écran avec le clavier
    brightnessctl

    # Clavier virtuel (à associer à la touche clavier dans la config niri)
    wvkbd

    # Logiciels de base
    xarchiver                                # Gestionnaire d'archive standard GTK, très bien intégré par PCManFM
    # file-roller                            # NON - Tire trop de dépendances Gnome
    gucharmap  # table de selection des caractères
    gnome-text-editor
    # nautilus                               # NON - Tire trop de dépendances Gnome
    gnome-calculator
    gnome-system-monitor
    # gnome-disk-utility                     # Il est bien .... mais tire beaucoup de dépendances core de Gnome
    gparted
    baobab
    seahorse
    fragments
    gnome-secrets
    shortwave
    smile
    
    
    
    
    # Choisir entre pcmanfm et nemo
    # mate-power-manager # configuration énèrgie. Marche pas. Il faut une session mate.
    # pantheon.elementary-files # explorateur de fichiers GTK sans dépendances. Ne permet pas de faire un recherche dans le contenu des fichiers
    # caja # explorateur de fichiers GTK sans dépendances. Ne permet pas de faire un recherche dans le contenu des fichiers
    # nemo # explorateur de fichiers GTK. Mais beaucoup de dépendances
    # noctalia-shell
    # swaynotificationcenter
    # grim # Captures d'écran
    # slurp # Captures d'écran
    
    
    
  ];
}
