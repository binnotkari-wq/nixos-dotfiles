{ config, pkgs, lib, ... }:

{
  programs.pyradio.settings = {
    use_os_media_controls = true;
    log_titles = true;
    enable_clock = true;
    enable_notifications = 0;
    theme = "gruvbox_dark_by_farparticul";
    time_format = 0;
    use_transparency = true;
    enable_mouse = true;
  };
}
