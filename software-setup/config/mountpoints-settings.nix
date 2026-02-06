{ config, lib, pkgs, ... }:

{
  # --- SYSTEMES DE FICHIERS : ADD-ON à hardware-configuration.nix ---
  # la génération automatique de harware-configuration ne detecte pas automatiquement les options de montage à l'installation (https://wiki.nixos.org/wiki/Btrfs)
  fileSystems = {
  "/".options = [ "defaults" "size=2G" "mode=755" ]; # / est un tmpfs : son contenu est donc effacé au redémarrage. Quelques fichiers doivent persister,voir fichier impermanence-config.nix.
  "/swap".options = [ "noatime" "ssd"];
  "/home".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  "/nix" = {
      options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
      neededForBoot = true; # Autorise le montage AVANT que le système ne cherche les fichiers persistés
    };
   "/persist" = {
      options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
      neededForBoot = true; # Autorise le montage AVANT que le système ne cherche les fichiers persistés
    };
  };
  
    # Pour faire passer les trim et discards à travers le volume LUKS
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

    # --- SWAP supplémentaire sur disque (fichier swapfile dans le sous-volume btrfs /swap) ---
  swapDevices = [ { device = "/swap/swapfile"; } ];
}
