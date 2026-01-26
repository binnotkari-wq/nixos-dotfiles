{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- LOGICIELS A SUPPRIMER ---
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];
}
