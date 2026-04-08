# Objectif : un OS tout inclu, deployable en une commande.
# Les .nix suivants sont nécessaires :
# - OS-configuration.nix
# - OS-configuration_addons.nix
# Une fois installé, on doit pouvoir :
# Executer une machine virtuelle : gnome boxes
# Gérer des containers : distrobox (dans le nix de soutils CLI)
# Executer une LLM (le modèle doit donc être téléchargé dans la foulée de l'installation) : llama (dans le nix de soutils CLI)
# Consulter une base wikipedia offline (le zim doit donc être téléchargé dans la foulée de l'installation) : kiwix (dans le nix de soutils CLI)

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./flatpaks.nix
    ];

  programs.firefox.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    gnome-software
    gnome-connections
  ];

  environment.systemPackages = with pkgs; [
    meld
    libreoffice
    fragments
    gnome-boxes
    handbrake
    gimp
    gnome-secrets
    impression
   ];
}
