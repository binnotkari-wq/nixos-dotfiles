{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # GUI
    distroshelf # (2.8 MiB download, 15.2 MiB unpacked)

    # CLI
    # --- Utilitaires de base ---
    # stow              # Gestion de tes dotfiles personnels # pas utile lorsqu'on utilise home manager

    # --- Développement & Data ---
    python313         # Choix judicieux pour l'économie d'espace (45 Mo)
    distrobox         # Pour tests Silverblue/Debian/Arch sans polluer NixOS
    just              # Ton exécuteur de commandes de projet
  ];

  # --- PODMAN ---
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Permet compatibilité docker si nécessaire
    defaultNetwork.settings.dns_enabled = true; # Active le DNS interne pour les conteneurs
  };

  # Active user namespaces correctement
  security.unprivilegedUsernsClone = true;

  # --- VIRTUALISATION ---
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
