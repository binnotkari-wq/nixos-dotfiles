# Objectif : un environnement tout inclu, deployable en une commande.
# Une fois installé, on peut:
# Executer une machine virtuelle : gnome boxes
# Gérer des containers : distrobox (dans le nix de soutils CLI)
# Executer une LLM (le modèle doit donc être téléchargé dans la foulée de l'installation) : llama (dans le nix de soutils CLI)
# Consulter une base wikipedia offline (le zim doit donc être téléchargé dans la foulée de l'installation) : kiwix (dans le nix de soutils CLI)
# Réaliser des taches grâce a des outils appropriés (images, video, musique, documents, administratif, mails)
# N'inclut pas la partie gaming, gérée en flatpaks à cause des dépendance, ou par un fichier nix spécialisé supplémentaire.

{ config, pkgs, ... }:

{

  services.desktopManager.gnome.enable = true; # syntaxe corrigée
  services.displayManager.gdm.enable = true; # syntaxe corrigée
  services.orca.enable = false; # requires speechd
  services.speechd.enable = false; # voice files are big and fat
  services.lact.enable = true; # (en natif, car ne fonctionne pas en flatpak, ne peut pas installer le service)
  programs.firefox.enable = true;

  services.xserver.excludePackages = with pkgs; [ 
    xterm
  ];

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    gnome-software
    gnome-connections
  ];

  environment.systemPackages = with pkgs; [
    # GUI
    # ne pas inclure apostrophe, heroic, bottles ou lutris ou steam en nixpkgs sur une machine service et production. Tirent trop de dépendances.
    gnomeExtensions.dash-to-panel
    meld
    libreoffice
    fragments
    gnome-boxes
    handbrake
    gimp
    gnome-secrets
    impression
    tagger
    foliate
    fragments
    pinta
    morphosis
    pdfarranger
       
    # CLI
    # --- Diagnostic & Hardware ---
    pciutils          # Essentiel pour l'inventaire matériel
    lm_sensors        # Surveillance des températures
    powertop          # Vital pour optimiser la batterie
    stress-ng         # Pour tester la stabilité du Ryzen
    s-tui             # Monitoring CPU en temps réel

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
    btop              # Version "esthétique" de htop (confort visuel)
    shellcheck	      # contrôle de syntaxe scripts bash
    aria2             # gestionnaire de téléchargement universel
    nix-tree          # Analyse des paquets et dépendances
    stow              # Gestion de tes dotfiles personnels
    mdcat             # Lecture de documentation Markdown
    mc                # Gestionnaire de fichiers interactif
    zellij            # Ton multiplexeur de terminal (TUI Desktop)

    # --- Développement & Data ---
    python313         # Choix judicieux pour l'économie d'espace (45 Mo)
    distrobox         # Pour tests Silverblue/Debian/Arch sans polluer NixOS
    vim
    just              # Ton exécuteur de commandes de projet

    # --- Services & Contenu ---
    kiwix-tools       # Wikipedia hors-ligne
    llama-cpp-vulkan  # Pour LLM optimisée GPU/iGPU   
  ];
   
   
  # --- PODMAN ---
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Permet compatibilité docker si nécessaire
    defaultNetwork.settings.dns_enabled = true; # Active le DNS interne pour les conteneurs
  };

  # Active user namespaces correctement
  security.unprivilegedUsernsClone = true;

}
