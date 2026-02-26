{ config, lib, pkgs, ... }:

{
  users.users.benoit = {
    packages = with pkgs; [
        zellij
    ]
  };
}
