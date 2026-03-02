{ config, pkgs, ... }:

{

  # --- OUTILS EN CLI ---
  
  # --- outils de diagnostic, de gestion de fichiers et de dépannage ---
  environment.systemPackages = with pkgs; [
    # --- Diagnostic & Hardware (Dell 5485 / R5-3600) ---
    pciutils          # Essentiel pour l'inventaire matériel
    lm_sensors        # Surveillance des températures
    powertop          # Vital pour optimiser la batterie de ton laptop
    stress-ng         # Pour tester la stabilité du Ryzen
    s-tui             # Monitoring CPU en temps réel

    # --- Système de fichiers & Réseau ---
    compsize          # Spécifique à ta structure Btrfs sur /nix
    duf               # Visualisation rapide de l'espace disque
    wget              # Utilitaire de base
    git               # Indispensable pour tes fichiers de config Nix

    # --- Utilitaires de base ---
    tree
    dialog            # Pour tes scripts de configuration système
    htop              # Le classique immanquable
  ];


  # --- usage quotidien, outils de confort et expérimentations (IA/LLM) ---
  users.users.benoit.packages = with pkgs; [
    # --- Workflow & Productivité ---
    btop              # Version "esthétique" de htop (confort visuel)
    mc                # Gestionnaire de fichiers interactif
    zellij            # Ton multiplexeur de terminal (TUI Desktop)
    stow              # Gestion de tes dotfiles personnels
    just              # Ton exécuteur de commandes de projet
    mdcat             # Lecture de documentation Markdown

    # --- Développement & Data ---
    python313         # Choix judicieux pour l'économie d'espace (45 Mo)
    distrobox         # Pour tes tests Silverblue/Debian/Arch sans polluer NixOS

    # --- Services & Contenu ---
    kiwix-tools       # Ton accès Wikipedia hors-ligne
    llama-cpp-vulkan  # Ton IA locale optimisée pour ton GPU/iGPU
  ];


  # --- PODMAN ---
  virtualisation.podman = {
    enable = true;

    # Permet compatibilité docker si nécessaire
    dockerCompat = true;

    # Active le DNS interne pour les conteneurs
    defaultNetwork.settings.dns_enabled = true;
  };

  # Active user namespaces correctement
  security.unprivilegedUsernsClone = true;


  # --- LOGICIELS A EXCLURE DE BASE ---
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    gnome-music
    showtime
    gnome-software
    gnome-connections
    seahorse
  ];
}
