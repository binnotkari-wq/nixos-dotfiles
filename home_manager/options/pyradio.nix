{ config, pkgs, lib, ... }:

{

  home.file.".newsboat/url" = {
    text = ''
theme = everforest-hard
    '';
  };
}
