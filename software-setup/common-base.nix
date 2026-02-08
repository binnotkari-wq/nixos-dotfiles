{ config, pkgs, ... }:

# NE RIEN MODIFIER D'AUTRE ET NE RIEN DESACTIVER DANS CE FICHIER

{
  imports = [
    ./users/benoit.nix # définition utilisateur
    ./users/benoit_settings.nix # réglages utilisateur
    ./programs/CLI_tools.nix # logiciels supplémentaires interface terminal
    # ./programs/plasma.nix # KDE Plasma
    ./programs/gnome.nix # Gnome
    ./config/system-settings.nix # réglages sytème universels (boot, localisation, services ...)
    # ./config/mountpoints-settings.nix # réglages spécifique au partionnement custom - option générale dans system-settings, à tester
    ./config/impermanence-config.nix # fichier dédié pour la configuration de l'impermanence
  ];
}
