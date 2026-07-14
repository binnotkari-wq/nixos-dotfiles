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
    kitty                       # console accelerée GPU, esthétique
    btop                        # Version "esthétique" de htop (confort visuel)
    fd                          # recherche
    fzf                         # recherche intelligente
    tldr                        # astuces et conseil d'utilisation des logiciels
    dust                        # analyse graphique de l'espace disque
    bat                         # better cat. Visualisation esthetique
    mc                          # Gestionnaire de fichiers interactif
    # vim                       # Editeur avancé
    duf                         # Visualisation rapide de l'espace disque
    tree                        # visualisation d'arborence (peut être redirigé ver sune sortie fichier texte)
    yt-dlp                      # téléchargement de fichiers sur youtube (complet, juste audio, etc...)
    cliphist                    # Visualisation de l'historique du presse-papier
    # atuin                     # analyse de l'historique bash. Mais par rappor à la confidentialité ....non (synchro de l'historique en ligne, etc...)
    ffmpeg
    groff
    imagemagick
    pandoc
  ];
}
