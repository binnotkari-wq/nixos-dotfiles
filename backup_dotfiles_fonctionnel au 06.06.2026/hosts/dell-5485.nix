{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports =
    [
      ./drivers_settings/CPU_AMD.nix
      ./drivers_settings/GPU_AMD.nix
      ./specialisations/workstation.nix # optionnel
      ./specialisations/gaming.nix # optionnel
      ./specialisations/SteamOS.nix # optionnel
  ];

  # Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "658437cc7c2542a5b5dc2c93c1af3705\n";
  };

  boot.consoleLogLevel = 0; # pour désactiver les messages concernant les tables ACPI non documentées, lors du démarrage

  # Montage du disque secondaire CARGO (actuellement formaté en ext4)
  fileSystems."/CARGO" =
    { device = "/dev/disk/by-uuid/1615eb5d-4346-4106-ba33-dbecf0b75b31";
      fsType = "ext4";
      options = [ "defaults" "nofail" "noatime" ]; # nofail = le système boote même si le disque est absent
    };

  # --- TUNING ---

  environment.systemPackages = with pkgs; [
    ryzenadj # Gestion TDP APU (Ryzen 3500U)
  ];

  # Préreglage TDP pour le ryzen 5 3500u
  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };

}
