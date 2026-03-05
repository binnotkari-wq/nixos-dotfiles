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

  # 4. Hygiène du Nix Store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;
}
