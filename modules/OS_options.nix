##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

{ config, pkgs, lib, ... }:

{

  options = {
    # --- 1. UTILISATEUR ---

    ##############################################################################
    # Définit les options à passer par défaut à tout dont l'UID est 1000.
    ##############################################################################
    users.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
        config = lib.mkIf (config.uid == 1000) {
          shell = pkgs.bash;
          extraGroups = [ "libvirtd" "kvm" ];                                   # pour donner l'accès aux fonction avancées de virtualisation
        };
      }));
    };
  };

  config = {
    # --- 2. BOOTLOADER ---
    boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
    boot.plymouth.enable = true;
    boot.consoleLogLevel = 0;                                                     # pour désactiver les messages concernant les tables ACPI non documentées, lors du démarrage

    # --- 3. INTERFACES HARDWARE ---
    hardware.bluetooth.enable = true;
    hardware.graphics.enable = true;                                              # Vulkan
    services.upower.enable = true;                                                # activé defacto sous gnome et kde, mais on le déclare dans le cas où on utilise un D.E light
    services.power-profiles-daemon.enable = true;                                 # activé defacto sous gnome et kde, mais on le déclare dans le cas où on utilise un D.E light. Ne pas utiliser tlp, pas pris dans plusieurs D.E.

    # --- 4. STATELESS ---
    users.mutableUsers = false;                                                   # Rigueur des comptes (Source de vérité = Code). Passer à true si le mot de passe n'est pas déclaratif.

    # RAM Disk natif pour /tmp ---
    boot.tmp.useTmpfs = true;
    boot.tmp.tmpfsSize = "2G";

    # Règles d'hygiène automatique (Systemd-tmpfiles) ---
    systemd.tmpfiles.rules = [
      "R /var/cache/* - - - - -"
      "R /var/spool/cups/* - - - - -"
      "e /var/tmp 1777 root root 30d -"                                           # On nettoie /var/tmp s'il n'est pas touché pendant 30 jours
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

    # --- 5. CONFIGURATION LOGICIELLE COMMUNE ---
    security.apparmor.enable = true;                                              # l'impact d'apparmor sur les performances est imperceptible. Les flatpaks prennet en charge nativement apparmor.
    # services.fwupd.enable = true;                                               # service de mise à jour de firmwares. Si besoin de flasher un firmware.
    services.orca.enable = false;                                                 # service de lecture ecran pour malvoyants. Activé par défaut, mais pesant.
    services.speechd.enable = false;                                              # service de lecture ecran pour malvoyants. Accompage Orca. Activé par défaut, mais pesant.
  };
}
