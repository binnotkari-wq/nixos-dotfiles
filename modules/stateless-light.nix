{ config, pkgs, lib, ... }:

# Permet de se rapprocher d'une impermanence, mais sans avoir à définir un schéma de partitionnement adapté
# ou une mise en place en pré-installation. On peu activer ou desactiver ce module quand on veut et quel
# que soit le schéma de partitions.

{
  # 1. Rigueur des comptes (Source de vérité = Code)
  # users.mutableUsers = false;
  # Note : il faut définir hashedPassword ou initialPassword ici.


  # 2. Option native NixOS pour le /tmp en RAM
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G"; # On peut monter à 50% de la RAM par défaut si on ne précise pas
  boot.tmp.cleanOnBoot = true;

  # 3. Déclaration des autres montages en RAM (Tmpfs)
  fileSystems = {
    "/var/tmp" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=1G" "mode=1777" ]; };
    "/var/cache" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=1G" "mode=755" ]; };
    "/var/log" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=512M" "mode=755" ]; };
    "/var/lib/colord" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=10M" ]; };
    "/var/lib/upower" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=10M" ]; };
    "/var/lib/AccountsService" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=10M" ]; };
    "/var/spool/cups" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=512M" ]; };
    "/var/db/sudo" = { device = "none"; fsType = "tmpfs"; options = [ "defaults" "size=5M" "mode=700" ]; };
  };

  # 4. Script de "Grand Ménage" (Activation)
  # Ce script s'exécute à chaque switch/boot. 
  # Il vérifie si le dossier est sur le SSD (physique) et le vide si c'est le cas.
  system.activationScripts.purgePhysicalGarbage = {
    supportsDryRun = true;
    text = ''
      # Fonction de purge sécurisée
      purge_dir() {
        local target="$1"
        if [ -d "$target" ]; then
          # On ne purge que si ce n'est PAS encore un point de montage (donc c'est le SSD)
          if ! ${pkgs.util-linux}/bin/mountpoint -q "$target"; then
            echo "Purge du stockage physique détectée sur : $target"
            rm -rf "$target"/*
          fi
        fi
      }

      purge_dir "tmp"
      purge_dir "/var/cache"
      purge_dir "/var/tmp"
      purge_dir "/var/log"
      purge_dir "/var/lib/colord"
      purge_dir "/var/lib/upower"
      purge_dir "/var/lib/AccountsService"
      purge_dir "/var/spool/cups"
      purge_dir "/var/db/sudo"
    '';
  };

  # 5. Hygiène du Nix Store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;
}
