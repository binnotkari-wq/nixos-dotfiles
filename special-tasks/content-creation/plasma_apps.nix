{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # kodi-wayland                 # plateforme multimedia
    # libreoffice-qt-fresh         # attention, beaucoup de dépendances
    # hunspell                     # pour libreoffice
    # hunspellDicts.fr-classique   # pour libreoffice
    # hunspellDicts.fr-reforme1990 # pour libreoffice
    # hunspellDicts.fr-moderne     # pour libreoffice
    # hunspellDicts.fr-any         # pour libreoffice
    # kdePackages.marble           # mappemonde
    # kstars                       # planetarium
    # librecad                     # CAO
    # krita                        # peinture, sketch numérique, drawing avancé
    # kdePackages.kdenlive         # montage vidéo complet
    # virt-manager                 # préférer peut-être en flatpak pour éviter les services et modules système
    # qemu                         # préférer peut-être en flatpak pour éviter les services et modules système
  ];
}
