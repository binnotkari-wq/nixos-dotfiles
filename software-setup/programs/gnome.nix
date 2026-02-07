{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- LACT pour la gestion GPU AMD / Nvidia / intel ---
  services.lact.enable = true; # non, utilise GTK3

  # --- LOGICIELS SUPPLEMENTAIRES --- 
  environment.systemPackages = with pkgs; [
    firefox                                     # natif car pour une meilleure intégration système
    gnome-tweaks                                # paramètres Gnome supplémentaires
    gnomeExtensions.dash-to-panel               # extension : barre des taches
    gnomeExtensions.arcmenu                     # menu système
  ];

  # --- LOGICIELS A SUPPRIMER DE BASE ---
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    showtime
    gnome-software
    gnome-connections
  ];
}
