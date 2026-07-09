{ config, pkgs, ... }:

{
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-calendar
    gnome-contacts
    gnome-software
    gnome-connections
  ];
}
