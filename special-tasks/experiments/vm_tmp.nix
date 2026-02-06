{ config, lib, pkgs, ... }:

{

# tests de réglages et paquets avant intégration définitive dans les modules .nix dédiés

  environment.systemPackages = with pkgs; [
  # spice-vdagent       # ne fonctionne pas avec une session wayland sur l'hote.
  ];

}
