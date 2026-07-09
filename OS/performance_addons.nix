{ config, pkgs, lib, ... }:

{
  # --- 2. OPTIONS PERFORMANCES LUKS ---
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
  services.fstrim.enable = true;                                                # activé de facto, mais on le déclare explicitement
  fileSystems."/".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  
  
  ##############################################################################
  # NTSync — accélère les primitives de synchronisation NT utilisées par
  # Wine/Proton (équivalent moderne de esync/fsync). Gain de FPS mesurable
  # dans certains jeux Windows lancés via Proton. Nécessite un noyau récent
  # qui inclut le module (c'est le cas des noyaux mainline récents).
  ##############################################################################
  boot.kernelModules = [ "ntsync" ];


  ##############################################################################
  # earlyoom — tue les processus les plus gourmands en mémoire *avant* que
  # le système ne sature complètement et ne freeze. Filet de sécurité léger,
  # particulièrement utile en jeu où un freeze total est plus pénible qu'un
  # simple crash d'un processus.
  ##############################################################################
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # déclenche si RAM libre < 5%
  };

  ##############################################################################
  # GameMode is a daemon/lib combo for Linux that allows games to request a set
  # of optimisations be temporarily applied to the host OS and/or a game process.
  # GameMode was designed primarily as a stop-gap solution to problems with the 
  # Intel and AMD CPU powersave or ondemand governors, but is now host to a range
  # of optimisation features and configurations.
  ##############################################################################
  programs.gamemode.enable = true;
  
}
