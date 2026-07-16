#########################################################################################
# Spécifique à la machine.                                                              #
# Déclare uniquement ce qui ne peut concerner une autre machine.                        #
#########################################################################################

{ config, pkgs, ... }:

{
  # --- IDENTIFIANT MACHINE DECLARATIF ---
  environment.etc."machine-id".text = "87f4f793002d450cbac014a28903f1fc\n";                     # Généré grâce à systemd-id128 new | tr -d '-'

  # --- DISQUE SECONDAIRE ---
  fileSystems."/cargo" =
    { device = "/dev/disk/by-uuid/AAAA COOOOOOOMPLETEEEEEEEEER"; # récupérer uuid suite à conversion en btrfs
      fsType = "btrfs"; # convertir le disque de ext4 à btrfs
      options = [ "nofail" "noatime" "compress=zstd" "ssd" "discard=async" ];                   # nofail = le système boote même si le disque est absent
    };

  # --- TDP ---
}
