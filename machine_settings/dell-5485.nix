{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./drivers_settings/CPU_AMD.nix
  ./drivers_settings/GPU_AMD.nix
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
