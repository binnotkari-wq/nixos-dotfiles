{ config, pkgs, lib, ... }:

{
  programs.gamemode.enable = true; # vérifier dans quelle mesure cela peut être bénéfique

  programs.steam = {
    enable = true;
    gamescopeSession.enable = false; # on utilise la session custom à la place
    extraPackages = with pkgs; [ mangohud ];
  };

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
