##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

# Permet de se rapprocher d'une impermanence, mais sans avoir à définir un schéma de partitionnement adapté
# ou une mise en place en pré-installation. On peut activer ou desactiver ce module quand on veut et quel
# que soit le schéma de partitions. On peut l'activer dès l'installation avec script, ou après installation avec Calamares
# Ne pas activer si on a activé l'impermanence, qui efface ces éléments à chaque redémarrage.

{ config, pkgs, ... }:

{

  # Sécurité : données sudo en tmpfs, pas conservées sur disque ---
  fileSystems = {
    "/var/db/sudo" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=5M" "mode=700" ]; };
  };

  # RAM Disk natif pour /tmp ---
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G";

  # Journalisation Volatile (Propre et limitée) ---
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=100M
  '';

  # Règles d'hygiène automatique (Systemd-tmpfiles) ---
  # Configure systemd-tmpfiles pour supprimer ces slors de l'arrêt du système
  systemd.tmpfiles.rules = [
    "R /var/lib/upower/* - - - - -"
    "R /var/cache/* - - - - -"
    "R /var/spool/cups/* - - - - -"
    "e /var/tmp 1777 root root 30d -"                                           # On nettoie /var/tmp s'il n'est pas touché pendant 30 jours
  ];

}
