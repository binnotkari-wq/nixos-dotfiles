{ config, pkgs, ... }:

{

# --- OUTILS EN LIGNE DE COMMANDE ---
  users.users.benoit = {
    packages = with pkgs; [
      # gnomeExtensions.dash-to-panel # il vaut mieux les gérer à travers l'appli flatpak Extensions
      # gnomeExtensions.arcmenu # il vaut mieux les gérer à travers l'appli flatpak Extensions
      git		# interface de versionning
      wget		# téléchargement de fichiers par http
      pciutils		# pour la commande lspci
      compsize		# analyse système de fichier btrfs : sudo compsize /nix
      lm_sensors
      tree
      dialog		# outils pratique pour créer des boites de dialogue dans les scripts
      duf		# analyse  espace disque
      powertop		# gestion d'énèrgie https://commandmasters.com/commands/powertop-linux/
      stow		# Gestionnaire de dotfiles
      stress-ng		# outil de stress CPU : stress-ng --cpu 0 --cpu-method matrixprod -v
      python313		# prend 45 Mo. Préférer à la version 315 qui prend 130 Mo
      s-tui		# Interface graphique CLI pour monitorer fréquence/température.
      htop		# gestionnaire de processus
      btop		# gestionnaire de processus, plus graphique
      mc		# gestionnaire de fichiers.
      just
      zellij		# desktop en TUI
      mdcat		# afficheur de fichiers Markdown, prend 13 Mo
      kiwix-tools	# moteur wikipedia local. Lancer avec kiwix-serve --port 8080 "/chemin/vers/fichier.zim"
      llama-cpp-vulkan	# moteur LLM, interface web type Gemini / Chat GPT. Ne prend que 80 Mo : install de base.
      distrobox
    ];
  }


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
