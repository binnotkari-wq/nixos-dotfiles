{ config, lib, pkgs, ... }:

{

  # --- SWAP --- 
  # Avec 8 Go de RAM, un ZRAM (swap en ram compressée) bien dimensionné suffit largement pour une machine de bureau ou un laptop classique.
  zramSwap.enable = true;
  zramSwap.priority = 100; # sera utilisé en priorité avant le swap sur disque (s'il existe)
  zramSwap.memoryPercent = 50; # Utilise jusqu'à 50% de la RAM
  boot.kernel.sysctl = {
  "vm.swappiness" = 100; # Le noyau va commencer à envoyer des plages mémoire en zram sans attendre la saturation
  };
  # swapDevices = [ { device = "/swapfile"; size = 2048; } ]; pas utile avec le zram. Et en l'état, pas compatible si sur un volume BTRFS compressé et avec COW.

}
