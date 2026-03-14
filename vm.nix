{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  #./modules/tests.nix
  ./modules/OS-functions_base.nix
  ./modules/OS-optimizations_zram.nix
  # ./modules/OS-optimizations_stateless.nix # commenter si on utilise impermanence
  # ./modules/OS-optimizations_filesystems.nix # commenter si l'installation a été fite depuis le script
  ./modules/apps.nix
  ];

  # --- TUNING ---

}
