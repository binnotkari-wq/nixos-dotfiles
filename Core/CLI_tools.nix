{ config, pkgs, lib, ... }:

{

  services.xserver.excludePackages = with pkgs; [ 
    xterm
  ];

  # --- outils de diagnostic, de gestion de fichiers et de dépannage ---
  environment.systemPackages = with pkgs; [
    # --- Diagnostic & Hardware ---
    pciutils          # Essentiel pour l'inventaire matériel
    lm_sensors        # Surveillance des températures
    powertop          # Vital pour optimiser la batterie

    # --- Système de fichiers & Réseau ---
    compsize          # utilitaire analyse Btrfs
    duf               # Visualisation rapide de l'espace disque
    wget
    git

    # --- Utilitaires de base ---
    tree
    dialog            # Pour scripts de configuration système
    libnotify	      # Pour scripts de configuration système
    htop              # Le classique immanquable
    shellcheck	      # contrôle de syntaxe scripts bash
    aria2             # gestionnaire de téléchargement universel

    # --- Développement & Data ---
    python313         # Choix judicieux pour l'économie d'espace (45 Mo)
    distrobox         # Pour tests Silverblue/Debian/Arch sans polluer NixOS
    vim

    # --- Services & Contenu ---
    kiwix-tools       # Wikipedia hors-ligne
    llama-cpp-vulkan  # Pour LLM optimisée GPU/iGPU
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
}
