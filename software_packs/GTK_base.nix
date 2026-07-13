##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-panel
    gnomeExtensions.tiling-shell
    fragments
    gnome-secrets
    shortwave
    smile
    deja-dup
    meld                                # ne tire quasi aucune dépendance
    impression                          # (2.0 MiB download, 8.1 MiB unpacked)
    tagger                              # (3.7 MiB download, 14.4 MiB unpacked):
    foliate                             # (3.2 MiB download, 12.0 MiB unpacked)
    pinta                               # (32.6 MiB download, 119.0 MiB unpacked):
    pdfarranger                         # (7.7 MiB download, 42.0 MiB unpacked)
    video-trimmer                       # (731.3 KiB download, 2.7 MiB unpacked)
    gnome-sound-recorder                # (95.1 KiB download, 583.7 KiB unpacked):
    audacity                            # (19.8 MiB download, 91.0 MiB unpacked)
    marker                              # éditeur / live preview markdown. Contrairement à Apostrophe, ne tire quasi aucune dépendance.
    abiword                             # (6.4 MiB download, 31.5 MiB unpacked) parfait sur pc de base, sans la lourdeur de libreoffice. Ne s'installe pas lorsqu'on active workstation_GTK.nix grâce à l'exclusion
    gnumeric                            # (12.4 MiB download, 45.6 MiB unpacked) parfait sur pc de base, sans la lourdeur de libreoffice. Ne s'installe pas lorsqu'on active workstation_GTK.nix grâce à l'exclusion
    # gnome-firmware                    # si besoin de flasher un firmware. NB : nécessite services.fwupd.enable = true;
    heroic                              # permet émulation windows avec proton GE, avec peu de dépendances (contrairement à heroic et bottles). Agnostique : ni GTK, ni QT. Peut lancer à la fois jeux et logiciels.
  ];
}
