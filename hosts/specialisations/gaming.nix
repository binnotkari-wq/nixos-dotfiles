{ config, pkgs, ... }:

{

  services.lact.enable = true; # (en natif, car ne fonctionne pas en flatpak, ne peut pas installer le service)

  environment.systemPackages = with pkgs; [
    mangohud
    warzone2100
    hydralauncher
  ];

  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [ mangohud ]; # On injecte MangoHud directement dans Steam pour MangoApp
  };

}
