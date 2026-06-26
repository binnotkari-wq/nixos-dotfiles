{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    plugins = {
      inherit (pkgs.yaziPlugins) mount;
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          run = "plugin mount";
          on = [ "M" ];
          desc = "Mount/unmount manager";
        }
      ];
    };
  };

  xdg.configFile = {
    "yazi/flavors/gruvbox-material.yazi".source = ./yazi;

    "yazi/theme.toml".text = ''
      [flavor]
      dark  = "gruvbox-material"
      light = "gruvbox-material"
    '';
  };
}
