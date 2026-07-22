#################################################################################################################################
# PAS AGNOSTIQUE. Prérequis :
# - il y a un sous-volume pour /nix (setup standard de Calamares lorsqu'on choisi le système de fichier BRTFS)
#
# IMPERMANENCE
#
# Wipe :
# Au démarrage, la racine (/) est rendue volatile — soit via tmpfs, soit via un sous-volume btrfs supprimé puis recrée au
# démarrage. Tout ce qui n'est pas explicitement sauvé disparaît au reboot : logs, caches, fichiers générés à la volée, erreurs
# de manipulation — le système repart "propre" à chaque fois.

# Persistences :
# Une partie de ces éléments d'état impératif méritent d'être intentionnellement persistés (clés SSH, configs wifi et bluetooth,
# /var/lib de services, /home ). On désigne un sous-volume ou partition distincte, en dehors du cycle de wipe, pour placer le dossier
# de ces éléments à persister.

# Liaison / vers persistences
# Le lien entre le / éphémère et ce stockage persistant se fait de deux façons, après le wipe complet de / : par bind-mounts
# déclarés (ex. /etc/machine-id, /var/lib/bluetooth) qui exposent un chemin persistant à l'endroit attendu, et par liens
# symboliques régénérés à chaque boot via systemd.tmpfiles.rules
# 
# Non conernés :
# * Le Nix store (/nix/store) est le résultat d'un état déclaratif, immuable et versionné par hash, sur son propre sous-volume (nix).
#   Sa persistance n'est pas une exception qu'on gère, elle est structurelle.
# * Les partitions et les sous-volume distinct de / sont par défaut en dehors de toute volatilité (il faudrait les monter en tmpfs
#   ou les inclure dans le script de wipe) car voués à stocker des données stockées intentionnellement par l'utilisateur.
#
# Module communautaire vs mise en place native
# Le module nix-community/impermanence abstrait tout le mécanisme : on déclare une simple liste de chemins
# (environment.persistence."/persist".directories = [...]), et il génère lui-même les bind-mounts, l'ordre de montage, les permissions.
# Mais la logique reste cachée dans les internals du module.
# La mise en place native (bind mounts manuels via fileSystems, règles tmpfiles écrites à la main) exige de comprendre chaque mécanisme
# mis en œuvre, mais offre en retour une lecture horizontale complète de la configuration : rien n'est masqué derrière une couche
# d'abstraction, chaque montage est visible et modifiable directement, au prix d'un peu plus de verbosité. On évite aussi une
# dépendance extérieure.
#################################################################################################################################

{ config, lib, pkgs, vars, ... }:

# Les vars sont hérités de variables.nix. Si on n'utilise pas les variables, remplacer :
# - ${vars.machineid} par le résultat de : systemd-id128 new | tr -d '-'
# - ${vars.username} par le nom de l'utilisateur
# - vars.hashedPassword par le résultat de : mkpasswd lemotdepasse (par défaut ce hash sera généré avec l'algorythme yescrypt).
# - ${vars.luksUuid} par le résultat de : sudo cryptsetup luksUUID /dev/nvme0n1p2 (ou autre périphérique qui contient le volume luks)
# - ----> si le volume LUKS porte un nom personnalisé, il faut remplacer luks-${vars.luksUuid} par son nom.

let
  impermanence = builtins.fetchTarball {
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
    # sha256 = "1iip4kjrk09mnha9jhafvcg61g1d0g6pqnljzdp08zz6zk38jzyk"; (optionnel, pour verrouiller le commit qu'on va utiliser)
    # nix-prefetch-url --unpack https://github.com/nix-community/impermanence/archive/master.tar.gz # pour obtenir le SHA
  };
in

{
  imports = [ "${impermanence}/nixos.nix" ];

  # ===========================================================================
  # 1. Options systèmes
  # ===========================================================================

  # fileSystems."/persist".neededForBoot = true; # on s'assure que /persist sera monté très tôt lors du démarrage. Utile uniquement quand on utilise un sous-volume dédié.

  # --- IDENTIFIANTS DECLARATIFS ---
  # Pour que /etc/machine-id, /etc/shadow, /etc/passwd et /etc/group soient gérés déclarativement (initialement, ils sont créés de façon iméprative par Calamares).
  # En effet la séquence de boot supporte mal la mise en persistance de ces fichiers. Certains services peuvent essayer d'y accéder, alors que les liens symboliques
  # défini par impermanence ne sont pas encore reconstruits.
  # Décommenter si ces options ne sont pas déjà déclarées dans un autre .nix
  environment.etc."machine-id".text = "${vars.machineid}\n";
  users.users.${vars.username}.hashedPassword = vars.hashedPassword;
  users.mutableUsers = false;

  # ===========================================================================
  # 2. bind mount des dossiers à persister
  # ===========================================================================
  # On peut vérifier la bonne création des bind-mounts avec findmnt -n -t btrfs -o UUID,TARGET --list
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      # Commenter les éléments qui font l'objet d'une gestion déclarative ou qui existent déjà sur un volume distinct.
      # "/home"
      "/etc/lact"
      "/etc/NetworkManager"
      "/etc/nixos"
      "/etc/ssh"
      "/var/lib/AccountsService"
      "/var/lib/bluetooth"
      "/var/lib/colord"
      "/var/lib/cups"
      "/var/lib/flatpak"
      "/var/lib/fwupd"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/upower"
      "/var/log"
    ];

  # ===========================================================================
  # 3. fichiers individuels à persister
  # ===========================================================================
    files = [
      # Commenter les éléments qui font l'objet d'une gestion déclarative ou qui existent déjà sur un volume distinct.
      # /etc/machine-id                                 # identifiant unique de la machine, doit être stable dans le temps
      # /etc/adjtime                                    # dérive mesurée de l'horloge matérielle (RTC), inutile de la reperdre
      # /root/.rnd                                      # graine aléatoire OpenSSL, à ne pas régénérer à chaque boot
    ];
  };

  # ===========================================================================
  # 5. reset du root
  # ===========================================================================

  # Deux solutions :
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
  # Un service sera exécut par systemd à chaque démarrage pour vider root
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
