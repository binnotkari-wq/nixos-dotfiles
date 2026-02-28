{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- LACT pour la gestion GPU AMD / Nvidia / intel ---
  services.lact.enable = true;

  # --- LOGICIELS SUPPLEMENTAIRES --- 
  environment.systemPackages = with pkgs; [
    firefox                                     # natif car pour une meilleure intégration système
    gnomeExtensions.dash-to-panel               # extension : barre des taches
    gnomeExtensions.arcmenu                     # menu système
  ];

  # --- LOGICIELS A EXCLURE DE BASE ---
  environment.gnome.excludePackages = with pkgs; [
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
