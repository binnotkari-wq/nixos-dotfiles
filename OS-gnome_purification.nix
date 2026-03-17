{ config, pkgs, lib, ... }:

{
  # --- LOGICIELS A EXCLURE DE BASE  : car gestion 100% Flatpaks (image système la plus light et pure possible) ---
  environment.gnome.excludePackages = with pkgs; [
    gnome-calculator
    gnome-characters
    gnome-text-editor
    gnome-weather
    loupe
    snapshot
    baobab
    gnome-maps
    gnome-font-viewer
    gnome-clocks
    papers
    gnome-logs
    decibels
    simple-scan
    gnome-music
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    gnome-music
    showtime
    gnome-software
    gnome-connections
    seahorse
  ];
}
