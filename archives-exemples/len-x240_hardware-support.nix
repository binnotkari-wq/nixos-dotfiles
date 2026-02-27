{ config, pkgs, ... }:

# NE RIEN MODIFIER DANS CE FICHIER

{
  imports = [
    ./hardware-configuration/len-x240_hardware-configuration.nix # spécificités machine
    ./tunings/len-x240_tunings.nix # ajustements spécifiques machine
    ./cpu/CPU_intel.nix # spécificités plateforme
    ./video/iGPU_intel.nix # spécificités plateforme
  ];
}
