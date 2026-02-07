{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- ESSENTIALS ---
    git         # interface de versionning
    wget        # téléchargement de fichiers par http
    duf         # analyse  espace disque
    compsize    # analyse système de fichier btrfs : sudo compsize /nix
    powertop    # gestion d'énèrgie https://commandmasters.com/commands/powertop-linux/
    stow        # Gestionnaire de dotfiles (gestion automatisée de liens symboliques vers ~/.config/  -> permet de faire un repo github rationnel)
    stress-ng   # outil de stress CPU : stress-ng --cpu 0 --cpu-method matrixprod -v

    # --- OPTIONNALS ---
    python313   # prend 45 Mo. Préférer à la version 315 qui prend 130 Mo
    pciutils    # pour la commande lspci
    s-tui       # Interface graphique CLI pour monitorer fréquence/température. Prend 49 Mo, dont la majorité en commun avec python 313
    htop        # gestionnaire de processus
    btop        # gestionnaire de processus, plus graphique
    zellij      # un autre desktop, prend 92 Mo, dont la moitié est commune aux dépendances de python313
    mc          # gestionnaire de fichiers. Prend 45 Mo, mais la majeur parti est commune aux dépendances de python313
    mplayer     # lecteur video, ne prend que 12 Mo
    pyradio     # webradio, prend 39 Mo + MPV ou mplayer
    mdcat       # afficheur de fichiers Markdown, prend 13 Mo
    # lynx        # navigateur web
    # fzf         # recherche de fichiers
    # vtm         # un desktop, prend 17 Mo
    # musikcube   # lecteur de musique, prend 24 Mo
    # mpv         # lecteur vidéo, prend 213 Mo
    # slides      # lecteur de fichiers Markdown, prend 18 Mo
    # clinfo      # Pour vérifier le support OpenCL
    # foot        # Un terminal qui ne dépend ni de KDE ni de Gnome, parfait dans une session Gamescope

    # --- SPECIALS ---
    # pandoc      # infrasctructure d'interprétation de fichiers textes et conversions
    # imagemagick # traitement et conversion d'images en batch
    # groff       # manipulation de contenu texte et conversion de formats
    # qpdf        # manipulation de fichiers pdf
  ];
}
