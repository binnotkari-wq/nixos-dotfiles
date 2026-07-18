# ATTENTION A ADAPTER EN REPRENANT vars.luksUuid pour le script de wipe !
# AJOUTER LES OPTIONS DECLARATIVES D'IDENTITE (en cours d emise en lace dans pseudo-impermanence.nix)
# AJOUTER LA POSSIBILITE TMPFS


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

# Les vars sont hérités de variables.nix. Si on n'utilise pas les variables, remplacer :
# - ${vars.machineid} par le résultat de : systemd-id128 new | tr -d '-'
# - ${vars.username} par le nom de l'utilisateur
# - vars.hashedPassword par le résultat de : mkpasswd lemotdepasse (par défaut ce hash sera généré avec l'algorythme yescrypt).
# - ${vars.luksUuid} par le résultat de : sudo cryptsetup luksUUID /dev/nvme0n1p2 (ou autre périphérique qui contient le volume luks)
# - ----> si le volume LUKS porte un nom personnalisé, il faut remplacer luks-${vars.luksUuid} par son nom.

  # --- IDENTIFIANTS DECLARATIFS ---
  # Pour que /etc/machine-id, /etc/shadow, /etc/passwd et /etc/group soient gérés déclarativement (initialement, ils sont créés de façon iméprative par Calamares).
  # En effet la séquence de boot supporte mal la mise en persistance de ces fichiers. Certains services peuvent essayer d'y accéder, alors que les liens symboliques
  # défini par impermanence ne sont pas encore reconstruits.
  environment.etc."machine-id".text = "${vars.machineid}\n";
  users.users.${vars.username}.hashedPassword = vars.hashedPassword;

  # --- IDENTIFIANTS DECLARATIFS ---
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

  # --- PERSISTENCE ---

  # fileSystems."/persist".neededForBoot = true; # on s'assure que /persist sera monté très tôt lors du démarrage. Utile uniquement quand on utilise un sous-volume dédié.

  # On peut vérifier la bonne création des bind-mounts avec findmnt -n -t btrfs -o UUID,TARGET --list
  environment.persistence."/nix/persist" = {
    hideMounts = true;

    # Commenter les éléments qui font l'objet d'une gestion déclarative. 
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
  
    # Commenter les éléments qui font l'objet d'une gestion déclarative.
    files = [
      # "/exemple/de/fichier"
    ];
  };
}
