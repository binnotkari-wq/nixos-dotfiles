{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- LOGICIELS A SUPPRIMER ---
  environment.gnome.excludePackages = with pkgs; [
  ];
}
