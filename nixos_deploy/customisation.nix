#############################
# Descriptif du fichier nix #
#############################

{ config, pkgs, lib, ... }:

{
    # --- 2. BOOTLOADER ---
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
  boot.initrd.systemd.enable = true;                      # true est la valeur par défaut à partir de Nixos 26.05. Déclaré au cas où.
  boot.plymouth.enable = true;
  boot.consoleLogLevel = 0;                           # pour désactiver les messages concernant les tables ACPI non documentées, lors du démarrage

  # --- 3. INTERFACES HARDWARE ---
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;                        # Vulkan
  hardware.enableRedistributableFirmware = true;
  services.upower.enable = true;                        # activé defacto sous gnome et kde, mais on le déclare dans le cas où on utilise un D.E light
  services.power-profiles-daemon.enable = true;                 # activé defacto sous gnome et kde, mais on le déclare dans le cas où on utilise un D.E light. Ne pas utiliser tlp, pas pris dans plusieurs D.E.
  services.lact.enable = true;   

  # --- 4. MAINTENANCE DU NIX STORE ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # --- 5. CONFIGURATION LOGICIELLE COMMUNE ---
  security.apparmor.enable = true;                        # l'impact d'apparmor sur les performances est imperceptible. Les flatpaks prennet en charge nativement apparmor.
  # services.fwupd.enable = true;                         # service de mise à jour de firmwares. Si besoin de flasher un firmware.
  services.orca.enable = false;                           # service de lecture ecran pour malvoyants. Activé par défaut, mais pesant.
  services.speechd.enable = false;                        # service de lecture ecran pour malvoyants. Accompage Orca. Activé par défaut, mais pesant.
  services.flatpak.enable = true;
  services.gnome.localsearch.enable = true;
  services.gnome.tinysparql.enable = true;
  
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;                                # Permet compatibilité docker si nécessaire
    defaultNetwork.settings.dns_enabled = true;         # Active le DNS interne pour les conteneurs
  };

  # Active user namespaces correctement
  security.unprivilegedUsernsClone = true;

  programs.dconf.enable = true;
  programs.bash.enable = true;

  programs.zoxide = {           # cd intelligent. Commencer par lancer zoxide add "le répertoire à intégrer dans la base de données". Puis, z remplace cd (pas immédiat, il faut déjà se promener un peu dans les dossiers)
    enable = true;
    enableBashIntegration = true;
  };

  environment.interactiveShellInit = ''
    # Intégration zoxide
    eval "$(zoxide init bash)"
  '';

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # on expose gstreamer aux plugins (qui ne peuvent pas savoir où chercher dans le FHS spécifique nixos)
  environment.sessionVariables = {
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-panel
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly  # utile pour mp3 notamment
    gst_all_1.gst-libav
    programs.gamescope.enable = true;
    btop                        # Version "esthétique" de htop (confort visuel)
    fd                          # recherche
    fzf                         # recherche intelligente
    tldr                        # astuces et conseil d'utilisation des logiciels
    bat                         # better cat. Visualisation esthetique
    mc                          # Gestionnaire de fichiers interactif
    duf                         # Visualisation rapide de l'espace disque
    tree                        # visualisation d'arborence (peut être redirigé ver sune sortie fichier texte)
    cliphist                    # Visualisation de l'historique du presse-papier
    groff
    imagemagick
    pandoc
    powertop                            # Vital pour optimiser la batterie
    pciutils                            # Essentiel pour l'inventaire matériel
    lm_sensors                          # Surveillance des températures
    stress-ng                           # Pour tester la stabilité du Ryzen
    s-tui                               # Monitoring CPU en temps réel
    libva-utils                         # Permet de lancer 'vainfo' pour tester l'accélération vidéo
    tmux                      # multiplexeur de terminal
    usbutils
    iw
    wget
    aria2                               # gestionnaire de téléchargement universel
    nix-tree                            # Analyse des paquets et dépendances
    shellcheck                          # contrôle de syntaxe scripts bash
    compsize                            # utilitaire analyse Btrfs
    git                                 # versionning, et interface avec repos en ligne
    glow                                # Lecture de documentation Markdown (supérieur à mdcat sur le rendu et la tolérance)
    dialog                              # outil boites de dialogue scripts
    zenity                              # outil boites de dialogue scripts (GTK)
    libnotify                           # outil boites de dialogue scripts
    hunspell                            # vérificateur orthographe, utilisé à l'échelle du système
    hunspellDicts.fr-any                # dictionaire français, utilisé à l'échelle du système
    hunspellDicts.fr-moderne            # dictionnaire francais, utilisé à l'échelle du système
    yt-dlp                              # téléchargement de fichiers sur youtube (complet, juste audio, etc...)
    nerd-fonts.jetbrains-mono
    ffmpeg
    kiwix-tools                         # (3.0 MiB download, 12.6 MiB unpacked) wikipedia offline
    llama-cpp-vulkan                    # (10.6 MiB download, 79.9 MiB unpacked) Pour LLM optimisée GPU/iGPU
    python313                                           # Version économiquee en espace disque (45 Mo)
    distrobox                                           # Pour tests Silverblue/Debian/Arch sans polluer NixOS
    just                                                # Exécuteur de commandes de projet
    jq
    ostree
    skopeo                                              # manipulation des images bootc (création d'un fichier OCI local)
    cosign                                              # signature des images bootc (création d'un fichier OCI local)
  ];


}
