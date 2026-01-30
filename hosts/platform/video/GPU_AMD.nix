{ config, lib, pkgs, ... }:

{

  # Pilotes dès l'initrd, si SDDM n'arrive pas à se lancer
  # boot.initrd.kernelModules = [ "amdgpu" ];

  # La nouvelle manière officielle de débloquer l'overclocking/undervolting
  hardware.amdgpu.overdrive.enable = true;

  # CoreCtrl pour la gestion CPU/GPU (Qt/KDE)
  programs.corectrl.enable = true;

  # Monitoring
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd # nvtopPackages.nvidia" , nvtopPackages.intel
    radeontop
    libva-vdpau-driver
  ];

}
