{ config, lib, pkgs, ... }:

{
  # --- Optimisation des volumes BTRFS (si existants) sauf l'éventuel sous-volume /swap (d'après options de montages décrites dans https://wiki.nixos.org/wiki/Btrfs )
  # mkAfter garantit que ces options sont ajoutées APRES celles du hardware-configuration
  # Il faudra y ajouter les éventuels autres volumes btrfs en cas de partitionnement custom, comme ils apparaissent dans hardware-configuration.nix

  fileSystems."/" = {
    options = lib.mkAfter [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  };

  fileSystems."/home" = {
    options = lib.mkAfter [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  };


  # --- Optimisations des volumes LUKS
  # Il faut récupérer la valeur "luks-xxxxx..." dans hardware-configuration.nix

  boot.initrd.luks.devices."luks-400c5604-0663-4e0b-ab4e-8475af6212b8" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };
}
