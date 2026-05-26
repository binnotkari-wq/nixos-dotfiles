{ config, lib, pkgs, ... }:

{
  # ============================================================
  # IMPERMANENCE
  # Rollback btrfs @ vers @blank à chaque boot.
  # Pour désactiver : commenter l'import dans configuration.nix.
  #
  # Prérequis :
  #   - sous-volume @blank existant (snapshot readonly de @ vide)
  #   - sous-volume @persist monté sur /persist (neededForBoot = true)
  #   - données existantes migrées vers /persist avant premier boot
  # ============================================================

  # --- 1. SERVICE INITRD : rollback @ vers @blank ---

  boot.initrd.systemd.services.rollback = {
    description = "Rollback btrfs @ vers @blank";
    wantedBy = [ "initrd.target" ];
    after = [ "dev-mapper-cryptroot.device" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir /btrfs_tmp
      mount -o subvolid=5,noatime /dev/mapper/cryptroot /btrfs_tmp

      if [ -e /btrfs_tmp/@blank ]; then

        # Supprimer les sous-volumes imbriqués dans @
        btrfs subvolume list -o /btrfs_tmp/@ |
          cut -f9 -d' ' |
          while read subvolume; do
            echo "Suppression sous-volume imbriqué : $subvolume"
            btrfs subvolume delete "/btrfs_tmp/$subvolume"
          done

        # Supprimer @
        echo "Suppression @"
        btrfs subvolume delete /btrfs_tmp/@

        # Recréer @ depuis @blank
        echo "Restauration @ depuis @blank"
        btrfs subvolume snapshot /btrfs_tmp/@blank /btrfs_tmp/@

      else
        echo "WARN : @blank introuvable, rollback ignoré, démarrage normal"
      fi

      umount /btrfs_tmp
    '';
  };

  # --- 2. CRÉATION DES DOSSIERS DANS /persist ---
  # Reproduit l'arborescence standard de /
  # Exécuté au démarrage par systemd, avant les services

  systemd.tmpfiles.rules = [
    # /var/lib
    "d /persist/var/lib/nixos           0755 root root -"
    "d /persist/var/lib/NetworkManager  0755 root root -"
    "d /persist/var/lib/bluetooth       0755 root root -"
    "d /persist/var/lib/flatpak         0755 root root -"
    "d /persist/var/lib/colord          0755 root root -"
    "d /persist/var/lib/upower          0755 root root -"
    "d /persist/var/lib/AccountsService 0755 root root -"
    # /var/log
    "d /persist/var/log                 0755 root root -"
    # /etc/ssh (préparation pour usage futur)
    "d /persist/etc/ssh                 0755 root root -"
  ];

  # --- 3. BIND MOUNTS vers /persist ---

  fileSystems = {

    # CRITIQUE : UIDs/GIDs NixOS
    "/var/lib/nixos" = {
      device = "/persist/var/lib/nixos";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };

    "/var/lib/NetworkManager" = {
      device = "/persist/var/lib/NetworkManager";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/bluetooth" = {
      device = "/persist/var/lib/bluetooth";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/flatpak" = {
      device = "/persist/var/lib/flatpak";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/colord" = {
      device = "/persist/var/lib/colord";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/upower" = {
      device = "/persist/var/lib/upower";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/lib/AccountsService" = {
      device = "/persist/var/lib/AccountsService";
      fsType = "none";
      options = [ "bind" ];
    };

    "/var/log" = {
      device = "/persist/var/log";
      fsType = "none";
      options = [ "bind" ];
    };

  };

}
