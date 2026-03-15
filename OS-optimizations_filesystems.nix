{ config, lib, pkgs, ... }:

{
  # --- Optimisation des volumes BTRFS (si existants) sauf l'éventuel sous-volume /swap (d'après options de montages décrites dans https://wiki.nixos.org/wiki/Btrfs )
  # Ce fichier est inutile avec une installation scriptée (options BTRFS appliquées à l'installation)
  # mkAfter garantit que ces options sont ajoutées APRES celles du hardware-configuration
  # Il faudra y ajouter les éventuels autres volumes btrfs en cas de partitionnement custom dans Calamares, comme ils apparaissent dans hardware-configuration.nix

  fileSystems."/" = {
    options = lib.mkAfter [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  };

  fileSystems."/home" = {
    options = lib.mkAfter [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  };
}
