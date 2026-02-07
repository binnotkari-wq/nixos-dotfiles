{ config, lib, pkgs, ... }:

{

# tests de réglages et paquets systèmes avant intégration définitive dans les modules .nix dédiés

  environment.systemPackages = with pkgs; [
    # --- BLACKLIST ---
    # apostrophe                                # amène des dépendances de dépendances...qui amènent les bilibothèques qt. Installer en flatpak.
    # lollipop                                  # amène des dépendances de dépendances...qui amènent les bilibothèques qt. Installer en flatpak.
    # kiwix                                     # amène des dépendances de dépendances...qui amènent les bilibothèques qt. Installer le serveur.
    # drawing                                   # GTK 3 (trouver autre chose) petit programme de dessin, identique à Paint
    # meld                                      # GTK 3 (trouver autre chose) comparateurs de fichiers et dossiers. Trouver autre chose ? moche, ne pas installer
    # inkscape                                  # GTK 3
    # gimp					# GTK 3, mais la version la 3.0 arrive en GTK4).
    # libreOffice				# GTK 3 
    # deja-dup                                  # ne sert pas à grand chose avec rsync et les snapshots
    # fastfetch					# GTK3 (par le biais de sa dépendance à xfconf
  ];

  # --- REGLAGES GNOME --- ne sert en fait à rien. Ce n'est pas ça qui créé les chemin des repertoires utilisateur standard. Amène GTK3
  # xdg.portal = {
  #  enable = true;
  #  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  #  config.common.default = "*";
  # };

}
