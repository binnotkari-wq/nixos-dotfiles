{ config, lib, pkgs, ... }:

{

# tests de réglages et paquets avant intégration définitive dans les modules .nix dédiés

  environment.systemPackages = with pkgs; [

    # --- RECOMMANDES SUR GNOME ---
    impression
    resources
    shortwave
    drum-machine
    video-trimmer


    # --- BLACKLIST ---
    # apostrophe                                # amène des dépendances de dépendances...qui amènent les bilibothèques qt. Installer en flatpak.
    # lollipop                                  # amène des dépendances de dépendances...qui amènent les bilibothèques qt. Installer en flatpak.
    # kiwix                                     # amène des dépendances de dépendances...qui amènent les bilibothèques qt. Installer le serveur.
    # drawing                                   # GTK 3 (trouver autre chose) petit programme de dessin, identique à Paint
    # meld                                      # GTK 3 (trouver autre chose) comparateurs de fichiers et dossiers. Trouver autre chose ? moche, ne pas installer
    # deja-dup                                  # ne sert pas à grand chose avec rsync et les snapshots

  ];

}
