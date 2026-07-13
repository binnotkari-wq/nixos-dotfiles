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
      ../../modules/home-manager.nix                                                # optionnel
      ../../modules/firefox.nix                                                     # optionnel - intégrable sans aucune condition
      # ../../modules/flatpak.nix                                                   # optionnel - intégrable sans aucune condition
      ../../modules/impermanence.nix                                                # optionnel - intégrable sous conditions
      ../../modules/OS_options.nix                                                  # optionnel - intégrable sans aucune condition
      ../../modules/performance_addons.nix                                          # optionnel - intégrable sans aucune condition
      ../../modules/shell.nix                                                       # optionnel - intégrable sans aucune condition
      ../../modules/SteamOS.nix                                                     # optionnel - intégrable sans aucune condition (GPU AMD)
      ../../software_packs/dev_experiments.nix                                      # optionnel - intégrable sans aucune condition
      ../../software_packs/firmwares.nix                                            # optionnel - intégrable sans aucune condition
      ../../software_packs/gaming.nix                                               # optionnel - intégrable sans aucune condition
      ../../software_packs/GTK_all.nix                                              # optionnel - intégrable sans aucune condition
      ../../software_packs/GTK_base.nix                                             # optionnel - intégrable sans aucune condition
      ../../software_packs/TUI_all.nix                                              # optionnel - intégrable sans aucune condition
      ../../software_packs/TUI_base.nix                                             # optionnel - intégrable sans aucune condition
      ../../software_packs/unwanted.nix                                             # optionnel - intégrable sans aucune condition
    ];

  # toutes les lignes de cette section sont à commenter si on utilise pas home manager.
  # cette section permet d'importer chez nix de façon selective pour chaque machine
  # au lieu de tout importer via home.nix (ainsi home.nix n'est jamais modifié)
  home-manager.users.${vars.username}.imports =
    [
      ../../modules/HM_options/btop.nix                                               # optionnel
      ../../modules/HM_options/distrobox.nix                                          # optionnel
      ../../modules/HM_options/git.nix                                                # optionnel - intégrable sous conditions
      ../../modules/HM_options/gnome.nix                                              # optionnel
      ../../modules/HM_options/newsboat.nix                                           # optionnel
      ../../modules/HM_options/pyradio.nix                                            # optionnel
      ../../modules/HM_options/vim.nix                                                # optionnel
      ../../modules/HM_options/xdg.nix                                                # optionnel
      ../../modules/HM_options/yazi.nix                                               # optionnel
    ];

  # Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "658437cc7c2542a5b5dc2c93c1af3705\n";
  };


  ##############################################################################################################
  # Un service systemd se charge de créer un lien vers les .nix du repo git : ainsi, la commande nixos-rebuild
  # n'a pas besoin d'un chemin personnalisé. Cette création est exécutée à chaque démarrage : donc tout à fait
  # adapté à l'impermanence.
  ##############################################################################################################
  systemd.tmpfiles.rules = [
    "L+ /etc/nixos/configuration.nix - - - - /home/${vars.username}/Mes-Donnees/Git/nixos-dotfiles/hosts/${vars.hostname}/configuration.nix"
    "L+ /etc/nixos/hardware-configuration.nix - - - - /home/${vars.username}/Mes-Donnees/Git/nixos-dotfiles/hosts/${vars.hostname}/hardware-configuration.nix"
  ];


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
