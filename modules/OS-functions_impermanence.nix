{ config, lib, pkgs, ... }:

{
  # --- SYSTEMES DE FICHIERS : options pour permettre le montage avant que le système ne cherche les fichiers persistés ---
  fileSystems."/nix".neededForBoot = true ;
  fileSystems."/persist".neededForBoot = true ;

  # --- FICHIERS A PERSISTER (via Symlinks)
  environment.etc = {
    "machine-id".source = "/persist/etc/machine-id";
    "adjtime".source = "/persist/etc/adjtime";
    "shadow".source = "/persist/etc/shadow";
    "passwd".source = "/persist/etc/passwd";
    "group".source = "/persist/etc/group";
    "subuid".source = "/persist/etc/subuid";
    "subgid".source = "/persist/etc/subgid";
  };

  # --- DOSSIERS A PERSISTER (via Bind Mounts)
  fileSystems = {

    # Matériel et GPU
    "/etc/lact" = { device = "/persist/etc/lact"; fsType = "none"; options = [ "bind" ]; };

    # Réseau
    "/etc/NetworkManager/system-connections" = {
      device = "/persist/etc/NetworkManager/system-connections";
      fsType = "none";
      options = [ "bind" ];
    };

    # Configuration Nix (pour ne pas perdre tes .nix !)
    "/etc/nixos" = { device = "/persist/etc/nixos"; fsType = "none"; options = [ "bind" ]; };

    "/var/lib/bluetooth" = {
      device = "/persist/var/lib/bluetooth";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/cups" = {
      device = "/persist/var/lib/cups";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/flatpak" = {
      device = "/persist/var/lib/flatpak";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/fwupd" = {
      device = "/persist/var/lib/fwupd";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/log" = {
      device = "/persist/var/log";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/NetworkManager" = {
      device = "/persist/var/lib/NetworkManager";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/nixos" = {
      device = "/persist/var/lib/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
}
