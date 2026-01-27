{ config, lib, pkgs, ... }:

{
  # On utilise le sous-volume /nix (déjà persistant) pour stocker les rares fichiers de /etc et /var à conserver entre chaque démarrage.
  # Les bind mount seront créés d'après cette liste.
  # Si /nix et /home ne sont pas sur une partion ou des sous-volume btrfs disincts, il faut les lister ici.
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/cups"
      "/var/lib/fwupd"
      # "/nix"
      # "/home"
    ];
    files = [
      "/etc/machine-id" # Identité unique du PC.
    ];
  };
}
