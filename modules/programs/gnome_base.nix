{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;


  # --- ADD ONS INTERFACE UTILISATEUR --- 
  environment.systemPackages = with pkgs; [
    gnome-tweaks                                # paramètres Gnome supplémentaires
    # gnomeExtensions.applications-menu         # pénible, le menu disparait avec la barre des taches
    gnomeExtensions.dash-to-panel               # extension : barre des taches
    gnomeExtensions.gtk4-desktop-icons-ng-ding  # icones sur le bureau
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
    gnome-music
    gnome-connections
  ];
}
