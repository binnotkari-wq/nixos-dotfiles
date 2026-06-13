{ config, pkgs, ... }:

{

  programs.zoxide = { # cd intelligent. Commencer par lancer zoxide add "le répertoire à intégrer dans la base de données". Puis, z remplace cd (pas immédiat, il faut déjà se promener un peu dans les dossiers)
    enable = true;
    enableBashIntegration = true;
  };

  environment.systemPackages = with pkgs; [
    superfile         # explorateur de fichiers esthétique
    kitty             # console accelerée GPU, esthétique
    fzf               # recherche intelligente
    ranger            # gestionnaire de fichiers esthétique
    tldr              # astuces et conseil d'utilisation des logiciels
    dust              # analyse graphique de l'espace disque
    bat               # better cat. Visualisation esthetique
    browsh            # browser texte esthétique
    lynx              # browser texte basique
    tmux              # Terminal multiplexé
    mdcat             # Lecture de documentation Markdown
    mc                # Gestionnaire de fichiers interactif
    zellij            # Ton multiplexeur de terminal (TUI Desktop)
    vim               # Editeur avancé
    duf               # Visualisation rapide de l'espace disque
    tree              # visualisation d'arborence (peut être redirigé ver sune sortie fichier texte)
    htop              # Le classique immanquable
    btop              # Version "esthétique" de htop (confort visuel)
    musikcube         # Lecteur mp3 esthétique
    # aerc            # client mail
    newsboat          # lecteur RSS
    # yazi            # explorateur de fichiers esthétique. Mais superfile est mieux.
    mplayer           # nécessaire à pyradio
    pyradio           # radio web
    yt-dlp            # téléchargement de fichiers sur youtube (complet, juste audio, etc...)
    gophertube        # chercher, regarder et télécharger des vidéos depuis youtube
    w3m               # navigateur internet
    # atuin           # analyse de l'historique bash. Mais par rappor à la confidentialité ....non (synchro de l'historique en ligne, etc...)
  ];

}
