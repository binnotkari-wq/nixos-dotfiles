{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./machine_settings/@@HOSTNAME@@.nix
      ./modules/workstation.nix # optionnel
      ./modules/home-manager.nix # optionnel
      ./modules/flatpaks_list.nix # optionnel
      ./modules/gaming.nix # optionnel
      # ./modules/SteamOS.nix # optionnel
    ];

  # --- 0. NIXOS ---
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "@@NIXOSVERSION@@"; # à adapter à la version NixOS
  networking.hostName = "@@HOSTNAME@@"; # Define your hostname.

  # --- 1. BOOTLOADER & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true; # On confie à Systemd le démarrage des pilotes graphiques et Plymouth. C'est la méthode utilisée par Fedora.

  # --- 2. OPTIONS LUKS ---
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  # --- 3. SWAP / ZRAM --- 
  # Avec 8 Go de RAM, un ZRAM bien dimensionné suffit largement pour une machine de bureau ou un laptop classique. Cela rend le swap sur dique inutile
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  zramSwap.priority = 100; # sera utilisé en priorité avant le swap sur disque (s'il existe)
  zramSwap.memoryPercent = 100; # Utilise jusqu'à 100% de la RAM
  boot.kernel.sysctl = {
  "vm.swappiness" = 150; # Le noyau va commencer à envoyer des plages mémoire en zram sans attendre la saturation
  };

  # --- 4. OPTIMISATIONS BTRFS (https://wiki.nixos.org/wiki/Btrfs) ---
  fileSystems."/".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/var/mnt/cargo".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];

  # --- 5. SERVICES ---
  security.apparmor.enable = true; # l'impact d'apparmor sur les performances est imperceptible. Les flatpaks prennet en charge nativement apparmor.
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true; # Vulkan
  networking.networkmanager.enable = true;
  services.xserver.enable = true;
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- 6. LOCALISATION ---
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };
  console.keyMap = "fr";
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  # --- 7. STATELESS ---
  # Permet de se rapprocher d'une impermanence, mais sans avoir à définir un schéma de partitionnement adapté
  # ou une mise en place en pré-installation. On peu activer ou desactiver ce module quand on veut et quel
  # que soit le schéma de partitions. On peut l'activer dès l'installation avec script, ou après installation avec Calamares

  # 0. Rigueur des comptes (Source de vérité = Code)
  users.mutableUsers = false;

  # RAM Disk natif pour /tmp ---
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G";

  # Journalisation Volatile (Propre et limitée) ---
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=100M
  '';

  # Règles d'hygiène automatique (Systemd-tmpfiles) ---
  systemd.tmpfiles.rules = [
    "R /var/cache/* - - - - -"
    "R /var/spool/cups/* - - - - -"
    "R /var/lib/upower/* - - - - -"
    "e /var/tmp 1777 root root 30d -"   # On nettoie /var/tmp s'il n'est pas touché pendant 30 jours
  ];

  # Sécurité : données sudo en tmpfs, pas conservées sur disque ---
  fileSystems = {
    "/var/db/sudo" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=5M" "mode=700" ]; };
  };

  # Hygiène du Nix Store ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  # Définition utilisateur ---
  users.users.@@USERNAME@@ = {
    isNormalUser = true;
    description = "@@USERNAME_DISPLAY@@";
    extraGroups = [ "networkmanager" "wheel" ];
    uid = 1000; # pour s'assurer qu'on sera bien bénéficiaire des droits sur /home dans le cas d'une réinstallation où /home est conservé
    hashedPassword = "@@HASHED_PASSWORD@@";
  };

  # Définition D.E. ---
  services.desktopManager.gnome.enable = true; # syntaxe corrigée
  services.displayManager.gdm.enable = true; # syntaxe corrigée
  
  
  # Configuration logicielle commune
  services.orca.enable = false; # requires speechd
  services.speechd.enable = false; # voice files are big and fat
  services.flatpak.enable = true;
  
  programs.firefox = {
    enable = true;
    languagePacks = [ "fr" ];
    preferences = {
      "browser.translations.automaticallyPopup" = false;
      "browser.startup.homepage" = "https://duckduckgo.com/";
      "intl.locale.requested" = "fr";
      "intl.accept_languages" = "fr-fr,fr";
      "spellchecker.dictionary" = "fr-FR";
    };  
    policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DontCheckDefaultBrowser = true;  
        SearchEngines = {
          Remove = [
            "eBay"
            "Google"
            "Bing"
            "Ecosia"
            "Wikipedia"
            "Perplexity"
          ];
          Add = [
            {
                "Name" = "DuckDuckGo";
                "URLTemplate" = "https://duckduckgo.com/?q={searchTerms}&ia=web&assist=false";
                "IconURL" = "https://duckduckgo.com/favicon.ico";
                "Alias" = "ddg";
                "Description" = "Duckduckgo without AI integrations";
            }
          ];
          Default = "DuckDuckGo";
        };   
    };
  };

  services.xserver.excludePackages = with pkgs; [ 
    xterm
  ];

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    gnome-software
    gnome-connections
  ];
  
  environment.systemPackages = with pkgs; [
    # GUI
    gnomeExtensions.dash-to-panel
    fragments
    gnome-secrets
    shortwave
    smile
    deja-dup
    gnome-firmware
    
    # CLI
    # --- Diagnostic & Hardware ---
    pciutils          # Essentiel pour l'inventaire matériel
    lm_sensors        # Surveillance des températures
    powertop          # Vital pour optimiser la batterie
    stress-ng         # Pour tester la stabilité du Ryzen
    s-tui             # Monitoring CPU en temps réel
    libva-utils       # Permet de lancer 'vainfo' pour tester l'accélération vidéo
    
    # --- Système de fichiers & Réseau ---
    compsize          # utilitaire analyse Btrfs
    duf               # Visualisation rapide de l'espace disque
    wget
    git
    tree
    
    # --- Utilitaires de base ---
    dialog            # Pour scripts de configuration système
    libnotify	      # Pour scripts de configuration système
    htop              # Le classique immanquable
    btop              # Version "esthétique" de htop (confort visuel)
    aria2             # gestionnaire de téléchargement universel
    nix-tree          # Analyse des paquets et dépendances
  ];
}
