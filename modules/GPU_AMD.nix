{ config, lib, pkgs, ... }:

{

  # Pilotes dès l'initrd, prêts au lancement de SDDM ou GDM
  boot.initrd.kernelModules = [ "amdgpu" ]; # Pilote graphique et sa télémétrie

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
