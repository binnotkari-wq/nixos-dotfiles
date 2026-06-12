{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    superfile         # explorateur de fichiers esthétique
    kitty             # console accelerée GPU, esthétique
    glow              # visualisateur fichiers markdown
    fzf               # recherche intelligente
    zoxide            # cd intelligent
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
  ];

}
