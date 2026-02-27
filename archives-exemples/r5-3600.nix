{ config, pkgs, ... }:

{
  # --- VERSION NIXOS A INSTALLER ---
  system.stateVersion = "25.11";
  
  
  # NE PAS MODIFIER CES DECLARATIONS
  
  # --- IDENTIFICATION SYSTEME ---
  networking.hostName = "r5-3600";
  
  # --- DEPLOIEMENTS ---
  imports = [
    ./hardware-support/r5-3600_hardware-support.nix # paramètres matériel - spécifique machine
    ./software-setup/common-base.nix # paramètres OS, bureau, applications et compte utilisateur - pour toute machine
    ./software-setup/programs/steamos.nix # a modifier pour faire un entrée gdm
  ];
}
