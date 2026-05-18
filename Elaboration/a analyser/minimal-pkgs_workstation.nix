{ config, pkgs, ... }:

{
  services.desktopManager.gnome.enable = true; # syntaxe corrigée
  services.displayManager.gdm.enable = true; # syntaxe corrigée
  services.orca.enable = false; # requires speechd
  services.speechd.enable = false; # voice files are big and fat
  services.lact.enable = true; # (en natif, car ne fonctionne pas en flatpak, ne peut pas installer le service)
  services.gnome.core-apps.enable = false; # sans le bundle des apps

  environment.systemPackages = with pkgs; [ # mais on veut celles-ci, essentielles (et présente dans silverblue -> liste flatpaks identique)
    gnome-console
    gnome-system-monitor
    gnome-disk-utility
    nautilus
    gnome-user-docs
    gnome-tour
    yelp
  ];

}
