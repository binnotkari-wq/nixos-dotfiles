# MISE EN PLACE
# 0. terminal root (pour eviter les erreur lors des éventuelles operations sur /etc/shadow  et /etc/passwd
# sudo -i
#

# 2. Créer les dossiers dans nix/persist
# mkdir -p /nix/persist/etc/lact
# mkdir -p /nix/persist/etc/nixos
# mkdir -p /nix/persist/etc/NetworkManager
# mkdir -p /nix/persist/etc/ssh
# mkdir -p /nix/persist/var/lib/AccountsService
# mkdir -p /nix/persist/var/lib/bluetooth
# mkdir -p /nix/persist/var/lib/cups
# mkdir -p /nix/persist/var/lib/flatpak
# mkdir -p /nix/persist/var/lib/NetworkManager
# mkdir -p /nix/persist/var/lib/nixos
# mkdir -p /nix/persist/var/lib/systemd
# mkdir -p /nix/persist/var/log


# 3. Copier les données (liste non exhaustive) -r : créé l'arborescence sur la cible si elle n'existe pas déjà. -a : preserve les propriété et attributs existantes
# cp -ra /etc/lact /nix/persist/etc/
# cp -ra /etc/nixos /nix/persist/etc/
# cp -ra /etc/NetworkManager /nix/persist/etc/
# cp -ra /etc/ssh /nix/persist/etc/
# cp -ra /var/lib/AccountsService /nix/persist/var/lib/
# cp -ra /var/lib/bluetooth /nix/persist/var/lib/
# cp -ra /var/lib/cups /nix/persist/var/lib/
# cp -ra /var/lib/flatpak /nix/persist/var/lib/
# cp -ra /var/lib/NetworkManager /nix/persist/var/lib/
# cp -ra /var/lib/nixos /nix/persist/var/lib/
# cp -ra /var/lib/systemd /nix/persist/var/lib/
# cp -ra /var/log /nix/persist/var/
# cp -ra /etc/machine-id /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)
# cp -ra /etc/shadow /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)
# cp -ra /etc/passwd /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)
# cp -ra /etc/group /nix/persist/etc/ (dans le cas d'une définition impérative, avec Calamares)

# 3. importer ce fichier .nix, et nixos-rebuild boot (ne pas faire nixos-rebuild switch : le démontage / remontage de / en tmpfs en live peut mal se passer)


# Rappel :
# Ne pas créer de liens pour cibler configuration.nix. Cela entrerait en conflit avec la persistance de /etc/nixos
#   systemd.tmpfiles.rules = [
#     "L+ /etc/nixos/configuration.nix - - - - /home/${vars.username}/Mes-Donnees/Git/nixos-dotfiles/configuration.nix"
#     "L+ /etc/nixos/hardware-configuration.nix - - - - /home/${vars.username}/Mes-Donnees/Git/nixos-dotfiles/hardware-configuration.nix"
#   ];


{ config, lib, ... }:

let
  persistRoot = "/nix/persist";
  hideMounts = true;

  persistedDirs = [
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

    ##########################################################################
    # IDENTITÉ SYSTÈME — cas particulier, à ne PAS traiter comme le reste
    #
    # machine-id / passwd / group / shadow sont, par choix assumé, gérés
    # en déclaratif (cf. module identity.nix : environment.etc."machine-id",
    # users.users.*, users.groups.*, hashedPasswordFile).
    #
    # Décommenter les lignes ci-dessous UNIQUEMENT si :
    #   - installation fraîche pas encore passée par bootstrap.sh / migration
    #   - ET module identity.nix volontairement non importé pour cette machine
    # Dans ce cas, ces 4 éléments redeviennent impératifs (hérités de Calamares)
    # et DOIVENT être persistés, sous peine de perte à chaque boot (tmpfs root).
    #
    # Ne jamais avoir les deux actifs en même temps (déclaratif ET persisté) :
    # cela crée une double définition concurrente du même chemin (cf. discussion
    # symlinks orphelins / non-déterminisme entre activation script et tmpfiles).
    ##########################################################################
    
  ];

  files = [
    # "/etc/machine-id"
    # "/etc/shadow"
    # "/etc/passwd"
    # "/etc/group"
  ];

  # Permissions mesurées sur une installation NixOS de référence (Calamares, X240),
  # après sollicitation réelle des services concernés (bluetooth appairé, wifi connecté,
  # cups configuré, flatpak+fwupd actifs). Seules les déviations du défaut 0755 root root
  # sont listées ici.
  customPerms = {
    "/var/lib/AccountsService" = "0775 root root";
    "/var/lib/bluetooth"       = "0700 root root";
    "/var/lib/colord"          = "0755 colord colord";
  };

  defaultPerm = "0755 root root";

  permOf = dir: customPerms.${dir} or defaultPerm;

  mountUnitOf = dir:
    "${lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" dir)}.mount";
in
{
  # 1. Bind mounts : @ (root, jetable, tmpfs) <- /nix/persist (persistant)
  fileSystems = lib.listToAttrs (map (dir: {
    name = dir;
    value = {
      device = "${persistRoot}${dir}";
      fsType = "none";
      options = [ "bind" ] ++ lib.optional hideMounts "x-gvfs-hide";
      neededForBoot = true;
    };
  }) persistedDirs);

  # 2. Garantie auto-réparatrice de l'existence + permissions des dossiers sources
  #    et création des liens symboliques vers les fichiers persistés (exemple : L+ /etc/machine-id - - - - /nix/persist/etc/machine-id)
  #    L'option L+ garanti que tant que le fichier existe à la cible, le lien n'est pas créé (il y aurait conflit).
  #    Mais après le wipe de / au redémarrage, ces fichiers n'existent, plus, systemd.tmpfiles pourra les créer à ce moment.
  systemd.tmpfiles.rules =
    (map (dir: "d ${persistRoot}${dir} ${permOf dir} -") persistedDirs)
    ++ (map (f: "L+ ${f} - - - - ${persistRoot}${f}") files);  
  

  # 3. Ordonnancement explicite : tmpfiles-setup doit finir avant chaque mount unit concerné
  systemd.services.systemd-tmpfiles-setup.before =
    map mountUnitOf persistedDirs;
}
