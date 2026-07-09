# ============================================================
# IMPERMANENCE
# A chaque boot, remise à zéro de / soit par vidange de la ram (lorsqu'on choisi de mettre / en tmpfs) soit
# par wipe (avec un service systemd qui flash un snapshot vide), puis recréation des liens depuis les données persistées.
# C'est donc un reset de tout ce qui n'est pas déclaré dans les .nix :
# - Ce qui est impératif et qu'on veut conserver, on le gère grâce au module impermanence.
# - Ce qui est déclaratif n'est pas concerné. Si un fichier ou dossier existe dans @nix du
#   fait des déclarations, alors il n'existe pas dans @. Seul son symlink existe, et
#   celui-ci est reconstruit dynamiquement.
#
# Pour désactiver : commenter l'import dans de ce fichier
#
# Prérequis :
#   - le système de fichier BTRFS est contenu dans un volume LUKS
#   - dossier /nix/persist/ existant
#   - dossiers ci-dessous mis en place vers /nix/persist, avec cp -a. Le module impermanence se charge ensuite, à chaque démarrage, de créer les liens.
# ============================================================

{ config, lib, pkgs, vars, ... }:

let
  impermanence = builtins.fetchTarball {
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
    # sha256 = "1iip4kjrk09mnha9jhafvcg61g1d0g6pqnljzdp08zz6zk38jzyk"; (optionnel, pour verrouiller le commit qu'on va utiliser)
    # nix-prefetch-url --unpack https://github.com/nix-community/impermanence/archive/master.tar.gz # pour obtenir le SHA
  };
in

{
  imports = [ "${impermanence}/nixos.nix" ];

  # ce n'est pas vraiment une persistence ... mais cela est rendu nécessaire du fait de l'impermanence, 
  # car le lien symbolique sera créé sur un volume impersistant, et disparaitra à chaque exctinction / redémarrage.
  # Un service systemd se charge donc de le recréer au démarrage.
  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - - - - /home/${vars.username}/Mes-Donnees/Git/nixos-dotfiles/hosts/${vars.hostname}"
  ];


  # Rollback @ vers @blank à chaque boot (section inutiles lorsque / est un tmpfs qui se vide à l'exctinction / redémarrage
  # boot.initrd.systemd = {
  #  services.rollback = {
  #    description = "Rollback btrfs @ vers @blank";
  #    wantedBy = [ "initrd.target" ];
  #    after = [ "systemd-cryptsetup@cryptroot.service" ];
  #    before = [ "sysroot.mount" ];
  #    unitConfig.DefaultDependencies = "no";
  #    serviceConfig.Type = "oneshot";
  #    script = ''
  #      mkdir -p /mnt
  #      mount -t btrfs -o subvol=/ /dev/mapper/cryptroot /mnt
  #      btrfs subvolume list -o /mnt/@ | \
  #        cut -f9 -d' ' | \
  #        while read subvol; do
  #          btrfs subvolume delete "/mnt/$subvol"
  #        done
  #      btrfs subvolume delete /mnt/@
  #      btrfs subvolume create /mnt/@
  #      # btrfs subvolume snapshot /mnt/@blank /mnt/@ # alternative à la recréation de @ : son ecrasement avec une snaphot vide. Il faut créer le snapshot au préalable (un sous-volume vide)
  #      umount /mnt
  #    '';
  #  };
  # };

  # Persistence (on peut vérifier la bonne création des bind-mounts avec findmnt -n -t btrfs -o UUID,TARGET --list)
  #fileSystems."/persist".neededForBoot = true; # on s'assure que /persist sera monté très tôt lors du démarrage. Utile uniquement quand on utilise un sous-volume dédié.
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/lact" # contenu existant à copier dans persist
      "/etc/NetworkManager" # contenu existant à copier dans persist
      # "/etc/nixos" # contenu existant à copier dans persist - sauf quand /etc/nixos n'est que la cible d'un lien symbolique depuis le repo git
      "/etc/ssh" # contenu existant à copier dans persist
      "/var/lib/AccountsService"
      "/var/lib/bluetooth" # contenu existant à copier dans persist
      "/var/lib/colord" # pas la pein de copier dans persist, se reconstruira tout seul
      "/var/lib/cups"
      "/var/lib/flatpak" # contenu existant à copier dans persist
      "/var/lib/fwupd" # pas la pein de copier dans persist, se reconstruira tout seul
      "/var/lib/NetworkManager" # contenu existant à copier dans persist
      "/var/lib/nixos" # contenu existant à copier dans persist
      "/var/lib/systemd/coredump"
      "/var/lib/upower" # pas la pein de copier dans persist, se reconstruira tout seul
      "/var/log" # contenu existant à copier dans persist
    ];

    files = [
      # "/etc/machine-id" # géré en déclaratif par environment.etc."machine-id", inutile de le persister
      # "/etc/shadow"     # géré en déclaratif par hashedPassword, inutile de le persister
      # "/etc/passwd"     # géré en déclaratif par hashedPassword, inutile de le persister
      # "/etc/group"      # géré en déclaratif par hashedPassword, inutile de le persister
    ];
  };
}
