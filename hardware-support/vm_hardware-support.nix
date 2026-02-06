{ config, pkgs, ... }:

# NE RIEN MODIFIER DANS CE FICHIER

{
  imports = [
    ./hardware-configuration/vm_hardware-configuration.nix # spécificités machine
    ./tunings/qemu.nix # ajustements spécifiques machine
  ];
}
