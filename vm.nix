{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./modules/tests.nix
  ./modules/configuration_addons.nix
  ./modules/filesystems-settings.nix
  ./modules/stateless-light.nix
  ./modules/user_apps.nix
  ];

  # --- TUNING ---

}
