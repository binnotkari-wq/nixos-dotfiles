{ config, pkgs, ... }:

{

  services.desktopManager.gnome.enable = true; # syntaxe corrigée
  services.displayManager.gdm.enable = true; # syntaxe corrigée

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-calendar
    gnome-contacts
    gnome-software
    gnome-connections
  ];
}
