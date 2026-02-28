{ config, pkgs, ... }:

# NE RIEN MODIFIER DANS CE FICHIER

{
  imports = [
    ./hardware-configuration/r5-3600_hardware-configuration.nix # spécificités machine
    ./tunings/r5-3600_tunings.nix # ajustements spécifiques machine
    ./cpu/CPU_AMD.nix # spécificités plateforme
    ./video/GPU_AMD.nix # spécificités plateforme
  ];
}
