{ config, pkgs, ... }:

# NE RIEN MODIFIER D'AUTRE ET NE RIEN DESACTIVER DANS CE FICHIER

{
  imports = [
    ./users/benoit.nix # définition utilisateur
    ./programs/CLI_tools.nix # logiciels supplémentaires interface terminal
    # ./programs/plasma.nix # KDE Plasma
    ./programs/gnome.nix # Gnome
    ./config/system-settings.nix # réglages sytème universels (boot, localisation, services ...)
    ./config/filesystems-settings.nix # réglages ciblés de performance des systèmes de fichiers
    ./config/impermanence-config.nix # fichier dédié pour la configuration de l'impermanence
  ];
}
