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

  # --- TUNING ---

}
