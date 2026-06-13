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

  home.file.".config/kitty/kitty.conf" = {
    text = ''
foreground            #c0caf5
background            #1a1b26
selection_foreground  #c0caf5
selection_background  #33467c
url_color             #9ece6a
cursor                #c0caf5
cursor_text_color     #1a1b26
active_border_color   #7aa2f7
inactive_border_color #444b6a
bell_border_color     #ff9e64

color0  #15161e
color1  #f7768e
color2  #9ece6a
color3  #e0af68
color4  #7aa2f7
color5  #bb9af7
color6  #7dcfff
color7  #a9b1d6
color8  #414868
color9  #f7768e
color10 #9ece6a
color11 #e0af68
color12 #7aa2f7
color13 #bb9af7
color14 #7dcfff
color15 #c0caf5

font_family       FiraCode Nerd Font
bold_font         auto
italic_font       auto
bold_italic_font  auto
font_size         11.0

background_opacity 0.9

window_padding_width 0
window_border_width 0

enable_audio_bell no
shell_integration yes
hide_window_decorations yes
    '';
  };
}
