{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration/dell-5485_hardware-configuration.nix
    ./platform/video/APU_AMD.nix
    ./platform/cpu/CPU_AMD.nix
    ../modules/programs/steamos.nix
    ];
}
