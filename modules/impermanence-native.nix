# =============================================================================
# Module impermanence "maison" - version dépliée, sans abstractions
# -----------------------------------------------------------------------------
# Principe général :
#   - "/" est monté en tmpfs (RAM) : tout ce qui n'est pas explicitement
#     persisté disparaît au redémarrage.
#   - Les DOSSIERS qu'on veut garder survivent grâce à un bind mount entre
#     /nix/persist/<chemin> (source, sur disque) et <chemin> (destination, sur le tmpfs).
#   - Les FICHIERS isolés qu'on veut garder survivent grâce à un LIEN SYMBOLIQUE
#     créé par systemd-tmpfiles vers /nix/persist/<chemin>.
#
# Différence bind mount vs lien symbolique :
#   - bind mount  -> pour un dossier entier (ex: /var/log). Le dossier "/var/log"
#                    devient littéralement le même dossier que
#                    "/nix/persist/var/log" (deux points de montage du même inode).
#   - lien symbolique -> pour UN fichier isolé (ex: /etc/machine-id). Le fichier
#                    "/etc/machine-id" pointe vers "/nix/persist/etc/machine-id".
#                    On ne peut pas "bind mounter" un fichier unique aussi
#                    proprement qu'un dossier, d'où l'usage du lien.
# =============================================================================



##############################################################################
# PAS AGNOSTIQUE. Prérequis :

# - il y a un sous-volume pour /home et pour /nix (setup standard de Calamares lorsqu'on choisi le système de fichier BRTFS)
# - /home et /nix n'ont donc pas besoin d'être persistés car sont des sous-volumes distincts
# 
# IMPERMANENCE
# A chaque boot, remise à zéro de / soit par vidange de la ram (lorsqu'on choisi de mettre / en tmpfs) soit
# par wipe (avec un service systemd qui supprime et recréé root, puis recréation des liens depuis les données persistées.
# C'est donc un reset de tout ce qui n'est pas déclaré dans les .nix :
# - Ce qui est impératif et qu'on veut conserver, on le gère grâce au module impermanence.
# - Ce qui est déclaratif n'est pas concerné. Si un fichier ou dossier existe dans /nix/store du
#   fait des déclarations, alors il n'existe pas dans root . Seul son symlink existe, et
#   celui-ci est reconstruit dynamiquement.
#
# Le module impermanence se charge ensuite, à chaque démarrage, de créer les liens dans /etc/ vers tous ces éléments dans /nix/persist/
##############################################################################













# Les vars sont hérités de variables.nix. Si on n'utilise pas les variables, remplacer :
# - ${vars.machineid} par le résultat de : systemd-id128 new | tr -d '-'
# - ${vars.username} par le nom de l'utilisateur
# - vars.hashedPassword par le résultat de : mkpasswd lemotdepasse (par défaut ce hash sera généré avec l'algorythme yescrypt).
# - ${vars.luksUuid} par le résultat de : sudo cryptsetup luksUUID /dev/nvme0n1p2 (ou autre périphérique qui contient le volume luks)
# - ----> si le volume LUKS porte un nom personnalisé, il faut remplacer luks-${vars.luksUuid} par son nom.


{ config, lib, vars, ... }:

{

  # --- IDENTIFIANTS DECLARATIFS ---
  # Pour que /etc/machine-id, /etc/shadow, /etc/passwd et /etc/group soient gérés déclarativement (initialement, ils sont créés de façon iméprative par Calamares).
  # En effet la séquence de boot supporte mal la mise en persistance de ces fichiers. Certains services peuvent essayer d'y accéder, alors que les liens symboliques
  # défini par impermanence ne sont pas encore reconstruits.
  environment.etc."machine-id".text = "${vars.machineid}\n";
  users.users.${vars.username}.hashedPassword = vars.hashedPassword;
  users.mutableUsers = false;



  # fileSystems."/persist".neededForBoot = true; # on s'assure que /persist sera monté très tôt lors du démarrage. Utile uniquement quand on utilise un sous-volume dédié.

  # ===========================================================================
  # 1. fileSystems : "/" en tmpfs + un bind mount PAR dossier à persister
  # ===========================================================================




  # (x-gvfs-hide : cache le point de montage dans les gestionnaires de fichiers GNOME)
  fileSystems = {
    "/etc/lact"                 = { device = "/nix/persist/etc/lact"                    ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/etc/NetworkManager"       = { device = "/nix/persist/etc/NetworkManager"          ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/etc/nixos"                = { device = "/nix/persist/etc/nixos"                   ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/etc/ssh"                  = { device = "/nix/persist/etc/ssh"                     ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/AccountsService"  = { device = "/nix/persist/var/lib/AccountsService"     ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/bluetooth"        = { device = "/nix/persist/var/lib/bluetooth"           ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/colord"           = { device = "/nix/persist/var/lib/colord"              ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/cups"             = { device = "/nix/persist/var/lib/cups"                ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/flatpak"          = { device = "/nix/persist/var/lib/flatpak"             ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/fwupd"            = { device = "/nix/persist/var/lib/fwupd"               ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/NetworkManager"   = { device = "/nix/persist/var/lib/NetworkManager"      ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/nixos"            = { device = "/nix/persist/var/lib/nixos"               ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/systemd/coredump" = { device = "/nix/persist/var/lib/systemd/coredump"    ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/lib/upower"           = { device = "/nix/persist/var/lib/upower"              ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
    "/var/log"                  = { device = "/nix/persist/var/log"                     ; fsType = "none"; options = [ "bind" "x-gvfs-hide" ]; neededForBoot = true; };
  };

  # ===========================================================================
  # 2. systemd.tmpfiles.rules
  #    Deux familles de règles bien séparées, chacune commentée ligne par ligne.
  # ===========================================================================
  systemd.tmpfiles.rules = [


    # SECURITES : systemd vérifiera à chaque démarrage que les dossiers persistés existent bien, ont les bonnes permissions.
    # Dans le cas contraire, il créé les dossier et / ou aplique les bonnes pemrissions.
    # --- 2a. Création des dossiers SOURCES dans /nix/persist ---
    # Sans ça, le bind mount échouerait au premier démarrage : la cible du
    # bind (/nix/persist/xxx) doit exister AVANT que systemd ne monte dessus.
    # Format : "d <chemin> <perms> <user> <group> -"

    "d /nix/persist/etc/lact 0755 root root -"
    "d /nix/persist/etc/NetworkManager 0755 root root -"
    "d /nix/persist/etc/nixos 0755 root root -"
    "d /nix/persist/etc/ssh 0755 root root -"
    "d /nix/persist/var/lib/AccountsService 0775 root root -"   # perm custom : lue par accounts-daemon en 0775
    "d /nix/persist/var/lib/bluetooth 0700 root root -"          # perm custom : données bluetooth sensibles, 0700
    "d /nix/persist/var/lib/colord 0755 colord colord -"         # perm custom : appartient à l'utilisateur système colord
    "d /nix/persist/var/lib/cups 0755 root root -"
    "d /nix/persist/var/lib/flatpak 0755 root root -"
    "d /nix/persist/var/lib/fwupd 0755 root root -"
    "d /nix/persist/var/lib/NetworkManager 0755 root root -"
    "d /nix/persist/var/lib/nixos 0755 root root -"
    "d /nix/persist/var/lib/systemd/coredump 0755 root root -"
    "d /nix/persist/var/lib/upower 0755 root root -"
    "d /nix/persist/var/log 0755 root root -"

    # --- 2b. Liens symboliques pour les FICHIERS individuels persistés ---
    # "L+" force la (re)création du lien si la cible n'existe pas déjà à cet
    # emplacement (donc jamais de conflit après le wipe de "/" au reboot).
    # Format : "L+ <chemin destination> - - - - <chemin source dans /nix/persist>"
    #
    # ⚠ Ici il n'y a actuellement AUCUN fichier isolé à persister dans ta config.
    # Voici 2-3 exemples fictifs pour illustrer le mécanisme (à adapter/supprimer) :

    # "L+ /etc/machine-id - - - - /nix/persist/etc/machine-id"
    #   exemple : identifiant unique de la machine, doit être stable dans le temps

    # "L+ /etc/adjtime - - - - /nix/persist/etc/adjtime"
    #   exemple : dérive mesurée de l'horloge matérielle (RTC), inutile de la reperdre

    # "L+ /root/.rnd - - - - /nix/persist/root/.rnd"
    #   exemple : graine aléatoire OpenSSL, à ne pas régénérer à chaque boot
  ];

  # ===========================================================================
  # 3. Ordonnancement : systemd-tmpfiles-setup doit avoir fini de CRÉER
  #    les dossiers sources (règles "d ..." ci-dessus) AVANT que les .mount
  #    correspondants ne tentent de monter dessus.
  #    Un nom de .mount = chemin absolu, "/" remplacé par "-", sans le "/" initial.
  #    Ex : "/var/lib/AccountsService" -> "var-lib-AccountsService.mount"
  # ===========================================================================
  systemd.services.systemd-tmpfiles-setup.before = [
    "etc-lact.mount"
    "etc-NetworkManager.mount"
    "etc-nixos.mount"
    "etc-ssh.mount"
    "var-lib-AccountsService.mount"
    "var-lib-bluetooth.mount"
    "var-lib-colord.mount"
    "var-lib-cups.mount"
    "var-lib-flatpak.mount"
    "var-lib-fwupd.mount"
    "var-lib-NetworkManager.mount"
    "var-lib-nixos.mount"
    "var-lib-systemd-coredump.mount"
    "var-lib-upower.mount"
    "var-log.mount"
  ];



  # --- ROOT VOLATILE---
  # Deux solution :
  # - tmpfs : universel, pas de prérequis
  # - wipe btrfs : sous-volume btrfs pour /

  # ROOT EN TMPFS
  # Section inutile lorsque root est un sous-volume BTRFS qu'on wipe au démarrage du PC, à commenter dans ce cas.
  # Montage de / en tmpfs (ce paramétrage prend le dessus sur celui de hardware-configuration.nix)
  # fileSystems."/" = lib.mkForce {
  #   device = "tmpfs";
  #   fsType = "tmpfs";
  #   options = [ "size=2G" "mode=755" ];
  # };

  # WIPE DU SOUS-VOUME BTRFS ROOT - POSSIBLE UNIQUEMENT SI INSTALLATION PAR BOOTSTRAP.SH
  # Section inutile lorsque / est un tmpfs qui se vide à l'exctinction / redémarrage, à commenter dans ce cas.
  # L'activation de cette section suppose que :
  # - il y a un volume LUKS
  # - il y a un sous-volume root et il est nommé root
  # Cette configuration de système de fichier est créée par bootstrap.sh mais pas par Calamares, qui ne créé pas de sous-solume distinct pour root.
  boot.initrd.systemd = {
   services.erase_root = {
     description = "Vidange du filesystem root à chaque boot";
     wantedBy = [ "initrd.target" ];
     after = [ "systemd-cryptsetup@${lib.replaceStrings ["-"] ["\\x2d"] "luks-${vars.luksUuid}"}.service" ]; # lib.replaceStrings ["-"] ["\\x2d"] car systemd echappe les - dans les noms de services
     before = [ "sysroot.mount" ];
     unitConfig.DefaultDependencies = "no";
     serviceConfig.Type = "oneshot";
     script = ''
       mkdir -p /mnt
       mount -t btrfs -o subvol=/ /dev/mapper/luks-${vars.luksUuid} /mnt
       btrfs subvolume list -o /mnt/root | \
         cut -f9 -d' ' | \
         while read subvol; do
           btrfs subvolume delete "/mnt/$subvol"
         done
       btrfs subvolume delete /mnt/root
       btrfs subvolume create /mnt/root
       # btrfs subvolume snapshot /mnt/blank /mnt/root # alternative à la recréation de root : son ecrasement avec une snaphot vide. Il faut créer le snapshot au préalable (un sous-volume vide)
       umount /mnt
     '';
   };
  };

}
