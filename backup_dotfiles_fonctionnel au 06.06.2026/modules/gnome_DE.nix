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
  
  
  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-panel
    fragments
    gnome-secrets
    shortwave
    smile
    deja-dup
    # gnome-firmware # si besoin de flasher un firmware. NB : nécessite services.fwupd.enable = true;
  ];

}
