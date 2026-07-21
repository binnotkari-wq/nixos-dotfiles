#########################################################################################
# Spécifique à la machine.                                                              #
# Déclare uniquement ce qui ne peut concerner une autre machine.                        #
#########################################################################################

{ config, pkgs, ... }:

{
  # --- DISQUE SECONDAIRE ---
  fileSystems."/cargo" =
    { device = "/dev/disk/by-uuid/8cd29e3c-2aa0-4ab0-b5ee-54ac7b4752bf";
      fsType = "btrfs";
      options = [ "nofail" "noatime" "compress=zstd" "ssd" "discard=async" ];                   # nofail = le système boote même si le disque est absent
    };

  # --- TDP ---
}
