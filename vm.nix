{ config, pkgs, ... }:

{
  # --- VERSION NIXOS A INSTALLER ---
  system.stateVersion = "25.11";
  
  
  # NE PAS MODIFIER CES DECLARATIONS
  
  # --- IDENTIFICATION SYSTEME ---
  networking.hostName = "vm";
  
  # --- DEPLOIEMENTS ---
  imports = [
    ./hardware-support/vm_hardware-support.nix # paramètres matériel - spécifique machine
    ./software-setup/common-base.nix # paramètres OS, bureau, applications et compte utilisateur - pour toute machine
    ./special-tasks/experiments/vm_tmp.nix # déclarations temporaires pour tests avant intégration (ou tmp2.nix, tmp3.nix, etc...)
  ];
}
