##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

{ config, pkgs, ... }:

{
  programs.zoxide = { # cd intelligent. Commencer par lancer zoxide add "le répertoire à intégrer dans la base de données". Puis, z remplace cd (pas immédiat, il faut déjà se promener un peu dans les dossiers)
    enable = true;
    enableBashIntegration = true;
  };

  environment.interactiveShellInit = ''
    # Intégration zoxide
    eval "$(zoxide init bash)"
  '';

  environment.systemPackages = with pkgs; [
    kitty                      # console accelerée GPU, esthétique
    yazi                       # gestionnaire de fichiers TUI modulaire
    yaziPlugins.mount
    yaziPlugins.chmod
    yaziPlugins.compress
    yaziPlugins.full-border
    yaziPlugins.recycle-bin
    # superfile                 # gestionnaire de fichiers esthétique
    # ranger                    # gestionnaire de fichiers esthétique
    fd                          # recherche
    television                  # interface TUI à fd
    fzf                         # recherche intelligente
    tldr                        # astuces et conseil d'utilisation des logiciels
    dust                        # analyse graphique de l'espace disque
    bat                         # better cat. Visualisation esthetique
    browsh                      # browser texte esthétique
    lynx                        # browser texte basique
    w3m                         # navigateur internet
    # mdcat                     # Lecture de documentation Markdown
    mc                          # Gestionnaire de fichiers interactif
    zellij                      # multiplexeur de terminal
    # tmux                      # multiplexeur de terminal
    vim                         # Editeur avancé
    duf                         # Visualisation rapide de l'espace disque
    tree                        # visualisation d'arborence (peut être redirigé ver sune sortie fichier texte)
    htop                        # Le classique immanquable
    btop                        # Version "esthétique" de htop (confort visuel)
    musikcube                   # Lecteur mp3 esthétique
    # aerc                      # client mail
    newsboat                    # lecteur RSS
    mplayer                     # nécessaire à pyradio
    pyradio                     # radio web
    yt-dlp                      # téléchargement de fichiers sur youtube (complet, juste audio, etc...)
    gophertube                  # chercher, regarder et télécharger des vidéos depuis youtube
    cliphist                    # Visualisation de l'historique du presse-papier
    # atuin                     # analyse de l'historique bash. Mais par rappor à la confidentialité ....non (synchro de l'historique en ligne, etc...)
    ffmpeg                              # taille ?
    groff                               # taille ?
    imagemagick                         # taille ?
    pandoc                              # taille ?
  ];
}
