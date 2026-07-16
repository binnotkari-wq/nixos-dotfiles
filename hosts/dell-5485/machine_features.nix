#########################################################################################
# Spécifique à la machine.                                                              #
# Déclare uniquement ce qui ne peut concerner une autre machine.                        #
#########################################################################################

{ config, pkgs, ... }:

{
  # --- IDENTIFIANT MACHINE DECLARATIF ---
  environment.etc."machine-id".text = "658437cc7c2542a5b5dc2c93c1af3705\n";                     # Généré grâce à systemd-id128 new | tr -d '-'

  # --- DISQUE SECONDAIRE ---
  fileSystems."/cargo" =
    { device = "/dev/disk/by-uuid/6790e467-032e-4021-b1b7-330fc873378f";
      fsType = "btrfs";
      options = [ "nofail" "noatime" "compress=zstd" "ssd" "discard=async" ];                   # nofail = le système boote même si le disque est absent
    };

  # --- TDP ---
  powerManagement.powertop.enable = true;                                                       # met en place un service qui applique automatiquement les réglages appliqués. Utiliser seulement sur PC portables.




  environment.systemPackages = [ pkgs.ryzenadj ];                                               # spécifique aux APU Ryzen



  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000";      # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000";  # TDP par défaut du 3500U : 25W
  };
}
