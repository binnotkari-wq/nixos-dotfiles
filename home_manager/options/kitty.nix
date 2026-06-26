{ config, pkgs, ... }:

{
  dconf.settings = {
    # Shell : extensions et barre des tâches
    "org/gnome/shell" = {
      favorite-apps = [
        "kitty.desktop"
      ];
    };
  };


  xdg.configFile = {
    "kitty".source = ./kitty;
  };
}
