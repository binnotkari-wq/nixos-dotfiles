{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration/len-x240_hardware-configuration.nix
    ./platform/video/iGPU_intel.nix
    ./platform/cpu/CPU_intel.nix
    ];
}
