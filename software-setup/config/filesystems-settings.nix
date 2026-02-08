{ config, lib, pkgs, ... }:

{
  # --- SYSTEMES DE FICHIERS : ADD-ON à hardware-configuration.nix ( https://wiki.nixos.org/wiki/Btrfs )---
  fileSystems."/".options = [ "defaults" "size=2G" "mode=755" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/persist".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/swap".options = [ "noatime" "ssd"]; # pas de compression, pas de discard sur un volume qui acceuille le swap
  
    # Pour faire passer les trim et discards à travers le volume LUKS
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

    # --- SWAP supplémentaire sur disque (fichier swapfile dans le sous-volume btrfs /swap) ---
  swapDevices = [ { device = "/swap/swapfile"; } ];
}
