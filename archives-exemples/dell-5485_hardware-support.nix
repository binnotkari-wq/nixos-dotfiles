{ config, pkgs, ... }:

# NE RIEN MODIFIER DANS CE FICHIER

{
  imports = [
    ./hardware-configuration/dell-5485_hardware-configuration.nix # spécificités machine
    ./tunings/dell-5485_tunings.nix # ajustements spécifiques machine
    ./cpu/CPU_AMD.nix # spécificités plateforme
    ./video/APU_AMD.nix # spécificités plateforme
  ];
}
