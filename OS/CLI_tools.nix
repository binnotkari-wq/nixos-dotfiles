{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fzf         # recherche de fichiers
    mc          # gestionnaire de fichiers
    lynx        # navigateur web
    htop        # gestionnaire de processus
    btop        # gestionnaire de processus, plus graphique
    fastfetch   # affiche les caractéristiques du PC
    duf         # analyse  espace disque
    compsize    # analyse système de fichier btrfs : sudo compsize /nix
    git         # interface de versionning
    wget        # téléchargement de fichiers par http
    powertop    # gestion d'énèrgie https://commandmasters.com/commands/powertop-linux/
    vtm         # un desktop
    zellij      # un autre desktop
    musikcube   # lecteur de musique
    mpv         # lecteur vidéo
    pyradio     # webradio
    mdcat       # afficheur de fichiers Markdown
    slides      # lecteur de fichiers Markdown
    pciutils    # pour la commande lspci
    mprime      # Pour le stress test (Prime95)
    s-tui       # Interface graphique CLI pour monitorer fréquence/température
    clinfo      # Pour vérifier le support OpenCL
    amdgpu_top  # Un moniteur de ressources génial pour voir la charge du CPU/GPU AMD
    foot        # Un terminal qui ne dépend ni de KDE ni de Gnome, parfait dans une session Gamescope
    imagemagick # traitement et conversion d'images en batch
    groff       # manipulation de contenu texte et conversion de formats
    qpdf        # manipulation de fichiers pdf
  ];
}
