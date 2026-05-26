{ config, pkgs, ... }:

{

  services.lact.enable = true; # (en natif, car ne fonctionne pas en flatpak, ne peut pas installer le service)

  environment.systemPackages = with pkgs; [
    mangohud
    warzone2100
  ];

}
