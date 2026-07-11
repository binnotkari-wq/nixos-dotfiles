# L'installation doit avoir été faite par le script, notamment :
# - les options du volume encrypté, qui est créé par le script
# - pour les différents sous-volumes btrfs, créés par le script

{ config, pkgs, vars, ... }:

let
  vars = import ../../common/variables.nix;
in

{
  _module.args = { inherit vars; };

  imports =
    [
      ./hardware-configuration.nix                                                  # obligatoire
      ../../common/standard_configuration.nix                                       # obligatoire
      ../../drivers/CPU_AMD.nix                                                     # optionnel
      ../../drivers/GPU_AMD.nix                                                     # optionnel
      ../../home_manager/home.nix                                                   # optionnel
      ../../modules/firefox.nix                                                     # optionnel
      # ../../modules/flatpak.nix                                                   # optionnel
      ../../modules/impermanence.nix                                                # optionnel
      ../../modules/OS_options.nix                                                  # optionnel
      ../../modules/performance_addons.nix                                          # optionnel
      ../../modules/shell.nix                                                       # optionnel
      ../../modules/SteamOS.nix                                                     # optionnel
      ../../software_packs/dev_experiments.nix                                      # optionnel
      ../../software_packs/gaming.nix                                               # optionnel
      ../../software_packs/GTK_all.nix                                              # optionnel
      ../../software_packs/GTK_base.nix                                             # optionnel
      ../../software_packs/TUI_all.nix                                              # optionnel
      ../../software_packs/TUI_base.nix                                             # optionnel
      ../../software_packs/unwanted.nix                                             # optionnel
    ];

  # Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "658437cc7c2542a5b5dc2c93c1af3705\n";
  };

  # --- TUNINGS SPECIFIQUES ---

  powerManagement.powertop.enable = true;                                       # met en place un service qui applique automatiquement les réglages appliqués. Utiliser seulement sur PC portables.

  # Montage du disque secondaire cargo (actuellement formaté en ext4)
  fileSystems."/cargo" =
    { device = "/dev/disk/by-uuid/1615eb5d-4346-4106-ba33-dbecf0b75b31";
      fsType = "ext4";
      options = [ "defaults" "nofail" "noatime" ];                              # nofail = le système boote même si le disque est absent
    };

  environment.systemPackages = with pkgs; [
    ryzenadj                                                                    # Gestion TDP APU (Ryzen 3500U)
  ];

  # Préreglage TDP pour le ryzen 5 3500u
  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };
}
