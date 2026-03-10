{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./modules/tests.nix
  ./modules/configuration_addons.nix
  ./modules/filesystems-settings.nix
  # ./modules/stateless-light.nix # commenter si on utilise impermanence
  ./modules/OS-functions_impermanence.nix # NECESSITE INSTALLATION PAR SCRIPT. Commenter si on utilise stateless, sur installation classique.
  ./modules/user_apps.nix
  ];

  # --- TUNING ---

}
