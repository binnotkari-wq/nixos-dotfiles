{ config, lib, pkgs, ... }:

{
  # --- Optimisation des volumes BTRFS (si existants) sauf l'éventuel sous-volume /swap (d'après options de montages décrites dans https://wiki.nixos.org/wiki/Btrfs )
  fileSystems = lib.mapAttrs (name: fs: {
    options = if (fs.fsType == "btrfs") then
      if (name == "/swap") 
      then [ "noatime" "ssd" ] ++ (fs.options or [])
      else [ "noatime" "compress=zstd" "ssd" "discard=async" ] ++ (fs.options or [])
    else fs.options;
  }) config.fileSystems;


  # --- Optimisations des volumes LUKS (si existants)
  boot.initrd.luks.devices = builtins.filterAttrs (_: v: v != null) (
    builtins.mapAttrs (_: dev: if dev != null then {
      allowDiscards = true;
      bypassWorkqueues = true;
    } else null) config.boot.initrd.luks.devices
  );
}
