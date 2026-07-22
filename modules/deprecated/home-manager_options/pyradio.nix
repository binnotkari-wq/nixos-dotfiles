################################################################################
# A utiliser en tant qu'import home manager. Pyradio n'a aucune configuration  #
# au niveau du système, uniquement dans l'environnement utilisateur.           #
# -> la configuration est donc déclarée par home-manager                       #
################################################################################

{ config, pkgs, lib, ... }:

{
  programs.pyradio = {
    enable = true;
    settings = {
      # use_os_media_controls = true;
      log_titles = true;
      enable_clock = true;
      enable_notifications = 0;
      theme = "gruvbox_dark_by_farparticul";
      time_format = 0;
      use_transparency = true;
      enable_mouse = true;
    };
  };
}
