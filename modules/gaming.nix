{ config, pkgs, ... }:

{
  # --- LACT pour la gestion GPU AMD / Nvidia / intel ---
  services.lact.enable = true;

  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = false; # on utilise la session custom à la place
    extraPackages = with pkgs; [ mangohud ];
  };

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
