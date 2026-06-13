{ config, pkgs, lib, ... }:

{
  home.file.".newsboat/url" = {
    text = ''
https://www.linuxjournal.com/node/feed
https://www.gamingonlinux.com/article_rss.php
    '';
  };
}
