{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports =
    [
      ./drivers_settings/CPU_AMD.nix
      ./drivers_settings/GPU_AMD.nix
      ./options/workstation.nix # optionnel
      ./options/prefs_firefox.nix # optionnel
      ./options/flatpaks_list.nix # optionnel
      # ./options/impermanence.nix # optionnel
      # ./options/gaming.nix # optionnel
      # ./options/SteamOS.nix # optionnel
  ];

# Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "658437cc7c2542a5b5dc2c93c1af3705\n";
  };

  # --- TUNING ---

  environment.systemPackages = with pkgs; [
    ryzenadj # Gestion TDP APU (Ryzen 3500U)
  ];

  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };

}
