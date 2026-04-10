{ config, pkgs, lib, ... }:

{

  services.xserver.excludePackages = with pkgs; [ 
    xterm
  ];

  # --- outils de diagnostic, de gestion de fichiers et de dépannage ---
  environment.systemPackages = with pkgs; [
    # --- Diagnostic & Hardware (Dell 5485 / R5-3600) ---
    pciutils          # Essentiel pour l'inventaire matériel
    lm_sensors        # Surveillance des températures
    powertop          # Vital pour optimiser la batterie de ton laptop

    # --- Système de fichiers & Réseau ---
    compsize          # Spécifique à ta structure Btrfs sur /nix
    duf               # Visualisation rapide de l'espace disque
    wget              # Utilitaire de base
    git               # Indispensable pour tes fichiers de config Nix

    # --- Utilitaires de base ---
    tree
    dialog            # Pour tes scripts de configuration système
    libnotify	      # Pour tes scripts de configuration système
    htop              # Le classique immanquable
    shellcheck	      # contrôle de syntaxe scripts bash

    # --- Développement & Data ---
    python313         # Choix judicieux pour l'économie d'espace (45 Mo)
    distrobox         # Pour tes tests Silverblue/Debian/Arch sans polluer NixOS
    vim

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
}
