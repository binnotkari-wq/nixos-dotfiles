##############################################################################
# PAS AGNOSTIQUE. Prérequis :
# - il y a un volume LUKS et il est nommé cryptroot
# - il y a un sous-volume root et il est nommé @
# - il y a un sous-volume pour /home et pour /nix (setup standard de Calamares lorsqu'on choisi le système de fichier BRTFS)
# - /home et /nix n'ont donc pas besoin d'être persistés car sont des sous-volumes distincts
# 
# IMPERMANENCE
# A chaque boot, remise à zéro de / soit par vidange de la ram (lorsqu'on choisi de mettre / en tmpfs) soit
# par wipe (avec un service systemd qui supprime et recréé @, puis recréation des liens depuis les données persistées.
# C'est donc un reset de tout ce qui n'est pas déclaré dans les .nix :
# - Ce qui est impératif et qu'on veut conserver, on le gère grâce au module impermanence.
# - Ce qui est déclaratif n'est pas concerné. Si un fichier ou dossier existe dans @nix du
#   fait des déclarations, alors il n'existe pas dans @. Seul son symlink existe, et
#   celui-ci est reconstruit dynamiquement.
#
# MISE EN PLACE
# 0. terminal root (pour eviter les erreur lors des éventuelles operations sur /etc/shadow  et /etc/passwd
# sudo -i
#
# 1. Créer les dossier à persister dans /nix/persist/ (liste non exhaustive)
# mkdir -p /nix/persist/etc
# mkdir -p /nix/persist/var/lib
# mkdir -p /nix/persist/var/log
# etc ...

# 2. Copier les données (liste non exhaustive)
# cp -a /etc/lact /nix/persist/etc/
# cp -a /etc/nixos/nix/persist/etc/
# cp -a /etc/NetworkManager /nix/persist/etc/
# cp -a /etc/ssh /nix/persist/etc/
# mv /etc/machine-id /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)
# mv /etc/shadow /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)
# mv /etc/passwd /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)
# mv /etc/group /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)
# cp -a /var/lib/AccountsService /nix/persist/var/lib/
# cp -a /var/lib/bluetooth /nix/persist/var/lib/
# cp -a /var/lib/cups /nix/persist/var/lib/
# cp -a /var/lib/flatpak /nix/persist/var/lib/
# cp -a /var/lib/NetworkManager /nix/persist/var/lib/
# cp -a /var/lib/nixos /nix/persist/var/lib/
# cp -a /var/lib/systemd /nix/persist/var/lib/
# cp -a /var/log /nix/persist/var/

# 3. importer ce fichier .nix, et nixos-rebuild switch
# Le module impermanence se charge ensuite, à chaque démarrage, de créer les liens dans /etc/ vers tous ces éléments dans /nix/persist/
##############################################################################

{ config, lib, pkgs, ... }:

let
  impermanence = builtins.fetchTarball {
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
    # sha256 = "1iip4kjrk09mnha9jhafvcg61g1d0g6pqnljzdp08zz6zk38jzyk"; (optionnel, pour verrouiller le commit qu'on va utiliser)
    # nix-prefetch-url --unpack https://github.com/nix-community/impermanence/archive/master.tar.gz # pour obtenir le SHA
  };
in

{
  imports = [ "${impermanence}/nixos.nix" ];

  # Vidange de @ à chaque boot (section inutiles lorsque / est un tmpfs qui se vide à l'exctinction / redémarrage
  boot.initrd.systemd = {
   services.erase_root = {
     description = "Vidange de @ à chaque boot";
     wantedBy = [ "initrd.target" ];
     after = [ "systemd-cryptsetup@cryptroot.service" ];
     before = [ "sysroot.mount" ];
     unitConfig.DefaultDependencies = "no";
     serviceConfig.Type = "oneshot";
     script = ''
       mkdir -p /mnt
       mount -t btrfs -o subvol=/ /dev/mapper/cryptroot /mnt
       btrfs subvolume list -o /mnt/@ | \
         cut -f9 -d' ' | \
         while read subvol; do
           btrfs subvolume delete "/mnt/$subvol"
         done
       btrfs subvolume delete /mnt/@
       btrfs subvolume create /mnt/@
       # btrfs subvolume snapshot /mnt/@blank /mnt/@ # alternative à la recréation de @ : son ecrasement avec une snaphot vide. Il faut créer le snapshot au préalable (un sous-volume vide)
       umount /mnt
     '';
   };
  };

  # Persistence (on peut vérifier la bonne création des bind-mounts avec findmnt -n -t btrfs -o UUID,TARGET --list)
  #fileSystems."/persist".neededForBoot = true; # on s'assure que /persist sera monté très tôt lors du démarrage. Utile uniquement quand on utilise un sous-volume dédié.
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/lact" # contenu existant à copier dans persist
      "/etc/NetworkManager" # contenu existant à copier dans persist
      "/etc/nixos" # contenu existant à copier dans persist - sauf quand /etc/nixos n'est que la cible d'un lien symbolique déclaratif
      "/etc/ssh" # contenu existant à copier dans persist
      "/var/lib/AccountsService"
      "/var/lib/bluetooth" # contenu existant à copier dans persist
      "/var/lib/colord" # contenu existant à copier dans persist. Se reconstruira tout seul, mais le copier maintenant évite les avertissements au premier boot
      "/var/lib/cups"
      "/var/lib/flatpak" # contenu existant à copier dans persist
      "/var/lib/fwupd" # contenu existant à copier dans persist. Se reconstruira tout seul, mais le copier maintenant évite les avertissements au premier boot
      "/var/lib/NetworkManager" # contenu existant à copier dans persist
      "/var/lib/nixos" # contenu existant à copier dans persist
      "/var/lib/systemd/coredump"
      "/var/lib/upower" # contenu existant à copier dans persist. Se reconstruira tout seul, mais le copier maintenant évite les avertissements au premier boot
      "/var/log" # contenu existant à copier dans persist
    ];

    # fichiers existant à copier dans persist (avec cp -a)
    files = [
      # "/etc/machine-id" # géré en déclaratif par environment.etc."machine-id". Décommenter dans le cas d'une définition impérative ( installation via Calamares)
      # "/etc/shadow"     # géré en déclaratif par hashedPassword. Décommenter dans le cas d'une définition impérative ( installation via Calamares)
      # "/etc/passwd"     # géré en déclaratif par hashedPassword. Décommenter dans le cas d'une définition impérative ( installation via Calamares)
      # "/etc/group"      # géré en déclaratif par hashedPassword. Décommenter dans le cas d'une définition impérative ( installation via Calamares)
    ];
  };
}
