#########################################################################################
# Spécifique à la machine.                                                              #
# Permet d'importer les d'options et packages .nix de façon selective                   #
#########################################################################################

{ config, pkgs, ... }:

{
  imports =
    [
      ./machine_features.nix                                                        # optionnel - intégrable sous conditions (spécificités de la machine)
      # ../../drivers/CPU_AMD.nix                                                   # optionnel - intégrable sous conditions (CPU AMD)
      # ../../drivers/GPU_AMD.nix                                                   # optionnel - intégrable sous conditions (GPU AMD)
      # ../../modules/btop.nix                                                      # optionnel - intégrable sous conditions (variables.nix ou adaptation manuelle)
      ../../modules/firefox.nix                                                     # optionnel - intégrable sans aucune condition
      # ../../modules/flatpak.nix                                                   # optionnel - intégrable sans aucune condition
      # ../../modules/git.nix                                                       # optionnel - intégrable sous conditions (variables.nix ou adaptation manuelle)
      ../../modules/gnome-dconf.nix                                                 # optionnel - intégrable sans aucune condition
      # ../../modules/home-manager.nix                                              # optionnel - intégrable sous conditions (variables.nix ou adaptation manuelle)
      ../../modules/impermanence-native.nix                                         # optionnel - intégrable sous conditions
      # ../../modules/kitty.nix                                                     # optionnel - intégrable sans aucune condition
      ../../modules/OS_options.nix                                                  # optionnel - intégrable sans aucune condition
      ../../modules/performance_addons.nix                                          # optionnel - intégrable sans aucune condition
      ../../modules/shell.nix                                                       # optionnel - intégrable sans aucune condition
      # ../../modules/SteamOS.nix                                                   # optionnel - intégrable sans aucune condition (mais utilisable seulement avec GPU AMD)
      ../../modules/xdg.nix                                                         # optionnel - intégrable sans aucune condition
      # ../../software_packs/dev_experiments.nix                                    # optionnel - intégrable sans aucune condition
      # ../../software_packs/firmwares.nix                                          # optionnel - intégrable sans aucune condition. iwlwifi est utilisé par le wifi intel 8260 (dell-5485).
      # ../../software_packs/gaming.nix                                             # optionnel - intégrable sans aucune condition
      # ../../software_packs/GTK_all.nix                                            # optionnel - intégrable sans aucune condition
      # ../../software_packs/GTK_base.nix                                           # optionnel - intégrable sans aucune condition
      # ../../software_packs/CLI_all.nix                                            # optionnel - intégrable sans aucune condition
      ../../software_packs/CLI_base.nix                                             # optionnel - intégrable sans aucune condition
      # ../../software_packs/TUI.nix                                                # optionnel - intégrable sans aucune condition
      ../../software_packs/unwanted.nix                                             # optionnel - intégrable sans aucune condition
    ];

  # Toutes les lignes de cette section sont à commenter si on utilise pas home manager.
  # On importe ici au lieu d'importer dans home.nix (ainsi home.nix n'est jamais modifié quelle que soit la selection souhaitée par machine)
  # sharedModules est une option de home manager. Tout module ajouté à cette liste sera évalué pour tout utilisateur déclarés dans home manager.
  # On n'est donc pas obligé de déclarer ici le nom de l'utilisateur ou d'importer des variables.
  # home-manager.sharedModules = 
    # [
      # ../../modules/home-manager_options/newsboat.nix                             # optionnel
      # ../../modules/home-manager_options/pyradio.nix                              # optionnel
      # ../../modules/home-manager_options/yazi.nix                                 # optionnel
    # ];
}
