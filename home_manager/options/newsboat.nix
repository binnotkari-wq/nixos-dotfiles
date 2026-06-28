{ config, pkgs, lib, ... }:

{
  home.file.".newsboat/urls" = {
    text = ''
https://www.linuxjournal.com/node/feed
https://www.gamingonlinux.com/article_rss.php
    '';
  };
}
