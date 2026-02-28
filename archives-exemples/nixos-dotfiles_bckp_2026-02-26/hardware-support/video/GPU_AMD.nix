{ config, lib, pkgs, ... }:

{

  # Pilotes dès l'initrd, si SDDM n'arrive pas à se lancer
  boot.initrd.kernelModules = [ "amdgpu" ];

  # La nouvelle manière officielle de débloquer l'overclocking/undervolting
  hardware.amdgpu.overdrive.enable = true;

  # Monitoring
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd # nvtopPackages.nvidia" , nvtopPackages.intel
    radeontop
    libva-vdpau-driver
    amdgpu_top  # Un moniteur de ressources génial pour voir la charge du CPU/GPU AMD. Prends 64 Mo, dont la majorité en commun avec python 313
  ];

}
