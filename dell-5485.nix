{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  #./modules/tests.nix
  ./modules/OS-functions_base.nix
  ./modules/OS-optimizations_zram.nix
  # ./modules/OS-optimizations_stateless.nix # commenter si on utilise impermanence
  # ./modules/OS-optimizations_filesystems.nix # commenter si l'installation a été fite depuis le script
  ./modules/OS-functions_impermanence.nix # NECESSITE INSTALLATION PAR SCRIPT. Commenter si on utilise stateless, sur installation classique.
  ./modules/apps.nix
  ./modules/HW-tuning_CPU_AMD.nix
  ./modules/HW-tuning_GPU_AMD.nix
  ];

  # --- TUNING ---
  # --- Optimisations des volumes LUKS
  # Il faut récupérer la valeur "luks-xxxxx..." dans hardware-configuration.nix
  boot.initrd.luks.devices."luks-400c5604-0663-4e0b-ab4e-8475af6212b8" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  environment.systemPackages = with pkgs; [
    ryzenadj # Gestion TDP APU (Ryzen 3500U)
  ];

  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };

}
