{ config, lib, pkgs, ... }:

{

# PREREQUIS :
# - une partition / (chiffrée ou non, taille 512Mo suffisent. Elle ne sera plus utilisée par la suite puisque sont contenu se trouvera en grande partie en tmpfs, et l'autre partie en persistance pour les quelques éléments concernés)
# - une partition /nix (chiffrée ou non)
# !!! A noter que si on choisi un système de fichiers btrfs,
# - et bien sûr dans l'installateur graphique, ne pas oublier de créer une partition /boot de 1024 Mo, FAT32, drapeau "boot"



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
    createDirectories = true;
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/etc/nixos"
      "/home"
      "/var/lib/bluetooth"
      "/var/lib/cups"
      "/var/lib/fwupd"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
    ];

    files = [
      "/etc/machine-id" # Identité unique du PC.
      "/etc/shadow" # mots de passe   
    ];
  };

}
