{ config, pkgs, ... }:

{
  # --- VERSION NIXOS A INSTALLER ---
  system.stateVersion = "25.11";
  
  
  # NE PAS MODIFIER CES DECLARATIONS
  
  # --- IDENTIFICATION SYSTEME ---
  networking.hostName = "dell-5485";
  
  # --- DEPLOIEMENTS ---
  imports = [
    ./hardware-support/dell-5485_hardware-support.nix # paramètres matériel - spécifique machine
    ./software-setup/common-base.nix # paramètres OS, bureau, applications et compte utilisateur - pour toute machine
    ./special-tasks/experiments/dell-5485_tmp.nix # déclarations temporaires pour tests avant intégration (ou tmp2.nix, tmp3.nix, etc...)
  ];
}
