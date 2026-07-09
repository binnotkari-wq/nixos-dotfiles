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
  ./modules/gaming.nix
  ./modules/gamescope-session.nix

  ];

# Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "87f4f793002d450cbac014a28903f1fc\n";
  };


  # --- TUNING ---

}
