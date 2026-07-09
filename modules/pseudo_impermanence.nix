# Permet de se rapprocher d'une impermanence, mais sans avoir à définir un schéma de partitionnement adapté
# ou une mise en place en pré-installation. On peut activer ou desactiver ce module quand on veut et quel
# que soit le schéma de partitions. On peut l'activer dès l'installation avec script, ou après installation avec Calamares
# Ne pas activer si on a activé l'impermanence

{ config, pkgs, ... }:

{
  # Journalisation Volatile (Propre et limitée) ---
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=100M
  '';
  
    # Règles d'hygiène automatique (Systemd-tmpfiles) ---
  systemd.tmpfiles.rules = [
    "R /var/lib/upower/* - - - - -"
  ];
}
