{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    # GUI
    gnome-boxes # (33.7 MiB download, 187.2 MiB unpacked)
    handbrake # (60.7 MiB download, 288.1 MiB unpacked)
    gimp # (61.0 MiB download, 353.5 MiB unpacked)
    morphosis # (26.9 MiB download, 208.9 MiB unpacked) (parmis les dépendance : pandoc, qui prend le plus de place)
    distroshelf # (2.8 MiB download, 15.2 MiB unpacked)
    drum-machine # (46.5 MiB download, 258.2 MiB unpacked)
    libreoffice-fresh # (303.4 MiB download, 1.6 GiB unpacked)

    # CLI
    # --- Utilitaires de base ---
    # stow              # Gestion de tes dotfiles personnels # pas utile lorsqu'on utilise home manager

    # --- Développement & Data ---
    python313         # Choix judicieux pour l'économie d'espace (45 Mo)
    distrobox         # Pour tests Silverblue/Debian/Arch sans polluer NixOS
    just              # Ton exécuteur de commandes de projet
    pandoc
    imagemagick
    groff

    # --- Services & Contenu ---
    ffmpeg
  ];

  # Pour ne pas installer ABiword et Gnumeric qui sont inutiles lorsqu'on installe libreoffice : 
  nixpkgs.config.packageOverrides = pkgs: {
    # On vide virtuellement les paquets pour ce profil en les remplaçant par un paquet vide
    abiword = pkgs.emptyDirectory;
    gnumeric = pkgs.emptyDirectory;
  };

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
