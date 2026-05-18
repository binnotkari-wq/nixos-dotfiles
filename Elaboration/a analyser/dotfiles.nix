{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "binnotkari-wq";
      user.email = "benoit.dorczynski@gmail.com";
      init.defaultBranch = "main";
      credential.helper = "store"; # Stocke le token de manière persistante (dans ~/.git-credentials) 
    };
  };
}
