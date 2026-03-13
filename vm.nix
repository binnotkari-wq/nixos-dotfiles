{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./modules/tests.nix
  ./modules/configuration_addons.nix
  # ./modules/filesystems-settings.nix # laisser commenté si l'installation a été faite depuis le script
  ./modules/user_apps.nix
  ];

  # --- TUNING ---

}
