{ config, lib, pkgs, ... }:

{

  # Pilotes dès l'initrd, si SDDM n'arrive pas à se lancer  -> c'est le cas pour le dell_5485, donc on active
  boot.initrd.kernelModules = [ "amdgpu" ];

  # La nouvelle manière officielle de débloquer l'overclocking/undervolting
  hardware.amdgpu.overdrive.enable = true;

  # Monitoring
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd # nvtopPackages.nvidia" , nvtopPackages.intel
    radeontop
    libva-vdpau-driver
    amdgpu_top  # Un moniteur de ressources génial pour voir la charge du CPU/GPU AMD. Prends 64 Mo, dont la majorité en commun avec python 313
    ryzenadj # Gestion TDP APU (Ryzen 3500U)
  ];

  # Alias pour le confort
  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };
}
