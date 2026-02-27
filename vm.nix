{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./modules/tests.nix
  ./modules/configuration_addons.nix
  ./modules/filesystems-settings.nix
  ./modules/impermanence-config.nix
  ./modules/user_apps.nix
  ];

  # --- TUNING ---

}
