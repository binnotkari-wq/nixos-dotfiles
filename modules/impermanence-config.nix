{ config, lib, pkgs, ... }:

# derniere evolution : refaire un rebuild sur snapshot vierge de la vm. Apres un reboot, voir ce qui a été copié sur /nix/persist. Comparer avec le contenu original pour voir si tout y est. Et enqueter sur les éléments qui ne s'y sont pas retrouvés. Peux-être qu'il faut faire un script de copie manuel à executer avant le reboot, et ne pas bricoler de script de copie dans le fichier .nix.


# PREREQUIS :
# - une partition / (chiffrée ou non, taille 512Mo suffisent. Elle ne sera plus utilisée par la suite puisque sont contenu se trouvera en grande partie en tmpfs, et l'autre partie en persistance pour les quelques éléments concernés)
# - une partition /nix (chiffrée ou non) (ne serait peut-être pas nécessaire sur un systeme de fichier btrfs, si l'installateur de nixos créé de lui meme des sous-volumes)
# - et bien sûr dans l'installateur graphique, ne pas oublier de créer une partition /boot de 1024 Mo, FAT32, drapeau "boot"
# !!! l'intégration doit se faire avec sudo nixos-rebuild boot et non sudo nixos-rebuild switch (il faut passer par un reboot propre du fait du changement dans les systèmes de fichiers).


# --- Au préalable on place dans le dossier de persistance tous les éléments à persister

let
  # --- dossiers à persister (source → target) ---
  persistCopy = [
    { src = "/home"; target = "/nix/persist/home"; }
    { src = "/etc/nixos"; target = "/nix/persist/etc/nixos"; }
    { src = "/etc/NetworkManager/system-connections"; target = "/nix/persist/etc/NetworkManager/system-connections"; }
    { src = "/var/lib/bluetooth"; target = "/nix/persist/var/lib/bluetooth"; }
    { src = "/var/lib/cups"; target = "/nix/persist/var/lib/cups"; }
    { src = "/var/lib/fwupd"; target = "/nix/persist/var/lib/fwupd"; }
    { src = "/var/lib/NetworkManager"; target = "/nix/persist/var/lib/NetworkManager"; }
    { src = "/var/lib/nixos"; target = "/nix/persist/var/lib/nixos"; }
  ];
in

{
  # --- COPIE PRÉALABLE DU CONTENU EXISTANT ---
  system.activationScripts.copyPersistContent = {
    text = ''
      echo "Copie des contenus existants vers /nix/persist avant le premier reboot"
      mkdir -p /nix/persist
      ${lib.concatMapStringsSep "\n" (d: ''
        mkdir -p ${d.target}
        cp -a ${d.src}/. ${d.target}/ || true
      '') persistCopy}
      chown -R root:root /nix/persist
      chmod -R 755 /nix/persist
    '';
  };

  # Fichiers persistants
  environment.etc."machine-id".source = "/etc/machine-id";
  environment.etc."shadow".source = "/etc/shadow";


  # --- MODULE IMPERMANENCE
  imports = [
    (builtins.fetchTarball { url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";} + "/nixos.nix") # module impermanence à intégrer dans le store
  ];

  # --- TMPFS ---
  # Montage de / en tmpfs (ce paramétrage prend le dessus sur celui de hardware-configuration.nix)
  fileSystems."/" = lib.mkForce {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=2G" "mode=755" ];
  };


  # --- MONTAGE /nix PRIORITAIRE 
  # options pour permettre le montage avant que le système ne cherche les fichiers persistés ---
  fileSystems."/nix".neededForBoot = true ;


  # --- ELEMENTS A PERSISTER ---
  # On utilise la partition /nix pour stocker les rares fichiers de /etc et /var à conserver entre chaque démarrage.
  # Les bind mount seront créés d'après cette liste.
  # Si /home n'est pas sur une partion ou des sous-volume btrfs disincts, il faut le lister ici.
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/home"
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/cups"
      "/var/lib/fwupd"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/shadow"
    ];
  };

}
