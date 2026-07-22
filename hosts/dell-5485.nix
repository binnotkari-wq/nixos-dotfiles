#########################################################################################
# Spécifique à la machine.                                                              #
# Déclare uniquement ce qui ne peut concerner une autre machine.                        #
#########################################################################################

{ config, pkgs, ... }:

let
  vars = import ../modules/variables.nix { };                                    # génération par bootstrap.sh ou adaptation manuelle
in

{
  _module.args.vars = vars;

  imports =
    [
      ../drivers/CPU_AMD.nix                                                     # optionnel - intégrable sous conditions (CPU AMD)
      ../drivers/GPU_AMD.nix                                                     # optionnel - intégrable sous conditions (GPU AMD)
      ../modules/btop.nix                                                        # optionnel - intégrable sans aucune condition
      ../modules/firefox.nix                                                     # optionnel - intégrable sans aucune condition
      ../modules/flatpak.nix                                                     # optionnel - intégrable sans aucune condition
      ../modules/git.nix                                                         # optionnel - intégrable sous conditions (variables.nix ou adaptation manuelle)
      ../modules/gnome-dconf.nix                                                 # optionnel - intégrable sans aucune condition
      ../modules/impermanence.nix                                                # optionnel - intégrable sous conditions (variables.nix ou adaptation manuelle)
      ../modules/kitty.nix                                                       # optionnel - intégrable sans aucune condition
      ../modules/OS_options.nix                                                  # optionnel - intégrable sans aucune condition
      ../modules/newsboat.nix                                                    # optionnel - intégrable sans aucune condition
      ../modules/performance_addons.nix                                          # optionnel - intégrable sans aucune condition
      ../modules/pyradio.nix                                                     # optionnel - intégrable sans aucune condition
      ../modules/shell.nix                                                       # optionnel - intégrable sans aucune condition
      # ../pseudo_impermanence.nix                                               # optionnel - intégrable sous conditions (variables.nix ou adaptation manuelle)
      ../modules/SteamOS.nix                                                     # optionnel - intégrable sans aucune condition (mais utilisable seulement avec GPU AMD)
      ../modules/xdg.nix                                                         # optionnel - intégrable sans aucune condition
      ../software_packs/dev_experiments.nix                                      # optionnel - intégrable sans aucune condition
      ../software_packs/firmwares.nix                                            # optionnel - intégrable sans aucune condition. iwlwifi est utilisé par le wifi intel 8260 (dell-5485).
      ../software_packs/gaming.nix                                               # optionnel - intégrable sans aucune condition
      ../software_packs/GTK_all.nix                                              # optionnel - intégrable sans aucune condition
      ../software_packs/GTK_base.nix                                             # optionnel - intégrable sans aucune condition
      ../software_packs/CLI_all.nix                                              # optionnel - intégrable sans aucune condition
      ../software_packs/CLI_base.nix                                             # optionnel - intégrable sans aucune condition
      ../software_packs/TUI.nix                                                  # optionnel - intégrable sans aucune condition
      ../software_packs/unwanted.nix                                             # optionnel - intégrable sans aucune condition
    ];

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
