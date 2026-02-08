{ config, lib, pkgs, ... }:

{

  imports = [
    (builtins.fetchTarball { url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";} + "/nixos.nix") # module impermanence à intégrer dans le store
  ];
  
  # --- SYSTEMES DE FICHIERS : options pour permettre le montage avant que le système ne cherche les fichiers persistés ---
  fileSystems."/nix".neededForBoot = true ;
  fileSystems."/persist".neededForBoot = true ;
  
  
  # --- ELEMENTS A PERSISTER ---
  # On utilise le sous-volume /persist pour stocker les rares fichiers de /etc et /var à conserver entre chaque démarrage.
  # Les bind mount seront créés d'après cette liste.
  # Si /home n'est pas sur une partion ou des sous-volume btrfs disincts, il faut les lister ici (et /nix serait de toute façon persistant puisque ce serait le point de montage de la partition)
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/cups"
      "/var/lib/fwupd"
      # "/home"
    ];
    files = [
      "/etc/machine-id" # Identité unique du PC.
    ];
  };

}
