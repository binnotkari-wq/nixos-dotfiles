{ config, pkgs, vars, ... }:

# L'installation doit avoir été faite par le script, notamment :
# - les options du volume encrypté, qui est créé par le script
# - pour les différents sous-volumes btrfs, créés par le script

let
  vars = import ./variables.nix;
in

{
  _module.args = { inherit vars; };

  imports =
    [ # Include the results of the hardware scan.
      ./hosts/${vars.hostname}.nix  # hérité de variables.nix
      ./home_manager/home.nix # optionnel. 100% indépendant, auxcune déclaratio Nixos, que des déclaration home-manager.
      ./modules/gnome_DE.nix
      # ./modules/flatpak.nix # optionnel.
      ./modules/prefs_firefox.nix # optionnel.
      ./modules/impermanence.nix # optionnel. Ne pas activer en même temps que pseudo_impermanence.nix
      # ./modules/pseudo_impermanence.nix # optionnel. Ne pas activer en même temps que impermanence.nix
    ];

  # --- 0. NIXOS ---
  nixpkgs.config.allowUnfree = true;
  system.stateVersion  = vars.nixosVersion; # hérité de variables.nix
  networking.hostName  = vars.hostname; # hérité de variables.nix

  # --- 1. BOOTLOADER & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
  boot.plymouth.enable = true;
  hardware.enableRedistributableFirmware = true; # pour avoir des firmware supplémentaire open-source (wifi...)
  # hardware.enableAllFirmware = true; # pour avoir des firmware closed source (matériel spécifique...)

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
  fileSystems."/persist".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/mnt/cargo".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];

  # --- 5. SERVICES ---
  security.apparmor.enable = true; # l'impact d'apparmor sur les performances est imperceptible. Les flatpaks prennet en charge nativement apparmor.
  # services.fwupd.enable = true; # service de mise à jour de firmwares. Si besoin de flasher un firmware. 
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true; # Vulkan
  networking.networkmanager.enable = true;
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
  console.keyMap = "fr";
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

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
    };

  # --- 7. STATELESS ---
  # Rigueur des comptes (Source de vérité = Code) - à activer après étude
  users.mutableUsers = false;

  # RAM Disk natif pour /tmp ---
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G";

  # Règles d'hygiène automatique (Systemd-tmpfiles) ---
  systemd.tmpfiles.rules = [
    "R /var/cache/* - - - - -"
    "R /var/spool/cups/* - - - - -"
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

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
    };

  # --- 8. DEFINITION UTILISATEUR ---
  users.users.${vars.username} = {  # hérité de variables.nix
    shell = pkgs.bash;
    isNormalUser = true;
    description = vars.usernameDisplay;  # hérité de variables.nix
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
    uid = 1000; # pour s'assurer qu'on sera bien bénéficiaire des droits sur /home dans le cas d'une réinstallation où /home est conservé
    hashedPassword = vars.hashedPassword;  # hérité de variables.nix
  };

  # --- 9. CONFIGURATION LOGICIELLE COMMUNE ---

  services.orca.enable = false; # requires speechd
  services.speechd.enable = false; # voice files are big and fat

  programs.firefox = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # GUI
    heroic # permet émulation windows avec proton GE, avec peu de dépendances (contrairement à heroic et bottles). Peut lancer à la fois jeux et logiciels.

    # CLI
    # --- Diagnostic & Hardware ---
    pciutils          # Essentiel pour l'inventaire matériel
    lm_sensors        # Surveillance des températures
    powertop          # Vital pour optimiser la batterie
    stress-ng         # Pour tester la stabilité du Ryzen
    s-tui             # Monitoring CPU en temps réel
    libva-utils       # Permet de lancer 'vainfo' pour tester l'accélération vidéo
    usbutils
    iw

    # --- Système de fichiers & Réseau ---
    compsize          # utilitaire analyse Btrfs
    duf               # Visualisation rapide de l'espace disque
    wget
    git
    tree

    # --- Utilitaires de base ---
    dialog            # outil boites de dialogue scripts
    zenity            # outil boites de dialogue scripts (GTK)
    libnotify	      # outil boites de dialogue scripts
    htop              # Le classique immanquable
    btop              # Version "esthétique" de htop (confort visuel)
    aria2             # gestionnaire de téléchargement universel
    nix-tree          # Analyse des paquets et dépendances
    hunspell
    hunspellDicts.fr-any
    hunspellDicts.fr-moderne
    mdcat             # Lecture de documentation Markdown
    mc                # Gestionnaire de fichiers interactif
    zellij            # Ton multiplexeur de terminal (TUI Desktop)
    vim
  ];

  environment.shellAliases = { 
    ll = "ls -l";
    nrs = "sudo nixos-rebuild switch";
    garbage = "nix-collect-garbage -d";
    backup       = "$HOME/Mes-Donnees/Git/scripts/backup.sh";
    bash-history = "$HOME/Mes-Donnees/Git/scripts/bash-history-export.sh";
    git-sync     = "$HOME/Mes-Donnees/Git/scripts/git-sync.sh";
  };

  environment.interactiveShellInit = ''
    HISTTIMEFORMAT="%s "
    HISTSIZE=100000
    HISTFILESIZE=100000
    shopt -s histappend
    echo "# SESSION $(date +%s)" >> "$HISTFILE"
    PROMPT_COMMAND="history -a''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  '';
}
