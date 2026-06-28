{ config, pkgs, lib, ... }:

# A utiliser en tant qu'import home manager.

{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "${pkgs.btop}/share/btop/themes/gruvbox_material_dark.theme";
      theme_background = true;
    };
  };
}
