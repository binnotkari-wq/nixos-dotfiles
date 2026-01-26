{ config, lib, pkgs, ... }:

{

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
