{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ 
    # kodi-wayland                 # plateforme multimedia
    # libreoffice-fresh            # attention, beaucoup de dépendances
    # hunspell                     # pour libreoffice
    # hunspellDicts.fr-classique   # pour libreoffice
    # hunspellDicts.fr-reforme1990 # pour libreoffice
    # hunspellDicts.fr-moderne     # pour libreoffice
    # hunspellDicts.fr-any         # pour libreoffice
    # pika-backup                  # Pour les sauvegardes, s'intègre parfaitement. Mais les snpashots manuels sont mieux.
    # gimp                         # montage photo, retouche avancé
    # pdfarranger                  # manipulateur de fichiers pdf
    # handbrake                    # conversion de flux audio et vidéo
    # gnome-boxes                  # gestionnaire de machines virtuelles
    # zim                          # prise de notes et bobliothèque Markdown. Trouver autre chose ?
  ];
}
