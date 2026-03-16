{ config, pkgs, lib, ... }:

# Permet de se rapprocher d'une impermanence, mais sans avoir à définir un schéma de partitionnement adapté
# ou une mise en place en pré-installation. On peu activer ou desactiver ce module quand on veut et quel
# que soit le schéma de partitions. On peut l'activer dès l'installation avec script, ou après installation CD ...

{
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
