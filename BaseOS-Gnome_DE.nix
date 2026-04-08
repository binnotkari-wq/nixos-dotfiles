{ config, pkgs, ... }:

{
  services.desktopManager.gnome.enable = true; # syntaxe corrigée
  services.displayManager.gdm.enable = true; # syntaxe corrigée
  services.orca.enable = false; # requires speechd
  services.speechd.enable = false; # voice files are big and fat

  environment.systemPackages = with pkgs; [  
    gnomeExtensions.dash-to-panel
  ];

}
