{ config, pkgs, ... }:

{
  # Optimisations et settings persos

  # --- 1. BOOTLOADER & KERNEL ---
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

  # --- 5. MATÉRIEL & SERVICES ---
  security.apparmor.enable = true; # l'impact d'apparmor sur les performances est imperceptible. Les flatpaks prennet en charge nativement apparmor.
  services.flatpak.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true; # Vulkan

  # --- 6. DEFINITION UTILISATEUR ---
  users.users.benoit = {
    uid = 1000; # pour s'assurer qu'on sera bien bénéficiaire des droits sur /home dans le cas d'une réinstallation où /home est conservé
  };

  # Stateless
  # Permet de se rapprocher d'une impermanence, mais sans avoir à définir un schéma de partitionnement adapté
# ou une mise en place en pré-installation. On peu activer ou desactiver ce module quand on veut et quel
# que soit le schéma de partitions. On peut l'activer dès l'installation avec script, ou après installation CD ...

  # 0. Rigueur des comptes (Source de vérité = Code)
  # users.mutableUsers = false;
  # Note : il faut définir hashedPassword ou initialPassword ici.

# --- 1. RAM Disk natif pour /tmp ---
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G";

  # --- 2. Journalisation Volatile (Propre et limitée) ---
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=100M
  '';

  # --- 3. Règles d'hygiène automatique (Systemd-tmpfiles) ---
  systemd.tmpfiles.rules = [
    "R /var/cache/* - - - - -"
    "R /var/spool/cups/* - - - - -"
    "R /var/lib/upower/* - - - - -"
    "e /var/tmp 1777 root root 30d -"   # On nettoie /var/tmp s'il n'est pas touché pendant 30 jours
  ];

  # --- 4. Sécurité : données sudo en tmpfs, pas conservées sur disque ---
  fileSystems = {
    "/var/db/sudo" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=5M" "mode=700" ]; };
  };

  # --- 5. Hygiène du Nix Store ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;
}
