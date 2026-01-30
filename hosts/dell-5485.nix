{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration/dell-5485_hardware-configuration.nix
    ./platform/video/APU_AMD.nix
    # ./platform/video/CPU_AMD.nix
    ];
}
