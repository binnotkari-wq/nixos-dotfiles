{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration/vm_hardware-configuration.nix
    ../modules/config/qemu.nix # A utiliser seulement pour une VM. Aucun modules hardware.
    ];
}
