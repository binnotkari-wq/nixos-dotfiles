{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./modules/tests.nix
  ./modules/configuration_addons.nix
  ./modules/filesystems-settings.nix
  ./modules/stateless-light.nix
  ./modules/user_apps.nix
  ./modules/CPU_AMD.nix
  ./modules/GPU_AMD.nix
  ];

  # --- TUNING ---
  environment.systemPackages = with pkgs; [
    ryzenadj # Gestion TDP APU (Ryzen 3500U)
  ];

  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };

}
