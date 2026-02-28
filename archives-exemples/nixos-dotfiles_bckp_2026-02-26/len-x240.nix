{ config, pkgs, ... }:

{
  # --- VERSION NIXOS A INSTALLER ---
  system.stateVersion = "25.11";
  
  
  # NE PAS MODIFIER CES DECLARATIONS
  
  # --- IDENTIFICATION SYSTEME ---
  networking.hostName = "len-x240";
  
  # --- DEPLOIEMENTS ---
  imports = [
    ./hardware-support/len-x240_hardware-support.nix # paramètres matériel - spécifique machine
    ./software-setup/common-base.nix # paramètres OS, bureau, applications et compte utilisateur - pour toute machine
  ];
}
