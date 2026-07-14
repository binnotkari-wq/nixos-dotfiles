{ config, pkgs, ... }:

# A utiliser en tant qu'import home manager.
# Des données propre à l'utilisateur sont générées.
# -> c'est donc à home-manager qu'on confie cette opération.

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "alphabetical";
        sort_dir_first = true;
        linemode = "mtime";
        show_symlink = true;
      };
    };
    plugins = {
      inherit (pkgs.yaziPlugins) mount;
      inherit (pkgs.yaziPlugins) full-border;
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

    # Le plugin full border nécessite d'être référencé dans le fichier init.lua
    "yazi/init.lua".text = ''
      require("full-border"):setup()
    '';

  };
}
