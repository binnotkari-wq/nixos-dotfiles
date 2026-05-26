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

  environment.systemPackages = with pkgs; [
    # GUI
    # ne pas inclure apostrophe, heroic, bottles ou lutris ou steam en nixpkgs sur une machine service et production. Tirent trop de dépendances.
    meld
    libreoffice
    gnome-boxes
    handbrake
    gimp
    impression
    tagger
    foliate
    pinta
    morphosis
    pdfarranger
    distroshelf
    video-trimmer
    drum-machine
    gnome-sound-recorder

    # CLI
    # --- Utilitaires de base ---
    stow              # Gestion de tes dotfiles personnels
    mdcat             # Lecture de documentation Markdown
    mc                # Gestionnaire de fichiers interactif
    zellij            # Ton multiplexeur de terminal (TUI Desktop)

    # --- Développement & Data ---
    shellcheck	      # contrôle de syntaxe scripts bash
    python313         # Choix judicieux pour l'économie d'espace (45 Mo)
    distrobox         # Pour tests Silverblue/Debian/Arch sans polluer NixOS
    vim
    just              # Ton exécuteur de commandes de projet
    pandoc
    imagemagick
    groff

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
