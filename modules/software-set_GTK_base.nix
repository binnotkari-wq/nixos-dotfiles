##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

{ config, pkgs, ... }:

{
  # Activation de la recherche contenu / metadata dans gnome
  services.gnome.localsearch.enable = true;
  services.gnome.tinysparql.enable = true;

  # on expose gstreamer aux plugins (qui ne peuvent pas savoir où chercher dans le FHS spécifique nixos)
  environment.sessionVariables = {
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-panel
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly  # utile pour mp3 notamment
    gst_all_1.gst-libav
    # gnomeExtensions.tiling-shell      # le tiling de base de gnome est tout à fait suffisant
    fragments                           # (103 MiB download, 357,4 MiB unpacked) dont 310 Mib de dépendances qui servent au reste des logiciels.
    gnome-secrets                       # (9.3 MiB download, 38.3 MiB unpacked)
    shortwave                           # (4.3 MiB download, 17.4 MiB unpacked)
    smile                               # (817 KiB download, 7.8 MiB unpacked)
    # deja-dup                          # (58.8 MiB download, 311.8 MiB unpacked) pas utilisé
    meld                                # (807 KiB download, 4.5 MiB unpacked)
    impression                          # (2.0 MiB download, 8.1 MiB unpacked)
    tagger                              # (25.6 MiB download, 86.3 MiB unpacked)
    foliate                             # (3.2 MiB download, 12.0 MiB unpacked)
    pinta                               # (32.6 MiB download, 119.0 MiB unpacked)
    pdfarranger                         # (9.5 MiB download, 35.2 MiB unpacked)
    video-trimmer                       # (731.3 KiB download, 2.7 MiB unpacked)
    gnome-sound-recorder                # (95.1 KiB download, 583.7 KiB unpacked)
    audacity                            # (19.8 MiB download, 91.0 MiB unpacked)
    marker                              # (2.8 MiB download, 8.9 MiB unpacked) éditeur / live preview markdown. Contrairement à Apostrophe, ne tire quasi aucune dépendance.
    abiword                             # (6.4 MiB download, 31.5 MiB unpacked) parfait sur pc de base, sans la lourdeur de libreoffice. Ne s'installe pas lorsqu'on active workstation_GTK.nix grâce à l'exclusion
    gnumeric                            # (14.4 MiB download, 54.6 MiB unpacked) parfait sur pc de base, sans la lourdeur de libreoffice. Ne s'installe pas lorsqu'on active workstation_GTK.nix grâce à l'exclusion
    # gnome-firmware                    # (732 KiB download, 4.1 MiB unpacked) si besoin de flasher un firmware. NB : nécessite services.fwupd.enable = true;
    heroic                              # (218.1 MiB download, 988.6 MiB unpacked) permet émulation windows avec proton GE, avec beaucoup moins de dépendances que lutris ou bottles. Agnostique : ni GTK, ni QT. Peut lancer à la fois jeux et logiciels.
  ];
}
