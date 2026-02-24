{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git         # interface de versionning
    wget        # téléchargement de fichiers par http
    pciutils    # pour la commande lspci
    compsize    # analyse système de fichier btrfs : sudo compsize /nix
    lm_sensors
    tree
    dialog      # outils pratique pour créer des boites de dialogue dans les scripts
    duf         # analyse  espace disque
    powertop    # gestion d'énèrgie https://commandmasters.com/commands/powertop-linux/
    stow        # Gestionnaire de dotfiles (gestion automatisée de liens symboliques vers ~/.config/  -> permet de faire un repo github rationnel) 
    stress-ng   # outil de stress CPU : stress-ng --cpu 0 --cpu-method matrixprod -v
    python313   # prend 45 Mo. Préférer à la version 315 qui prend 130 Mo
    s-tui       # Interface graphique CLI pour monitorer fréquence/température. Prend 49 Mo, dont la majorité en commun avec python 313
    htop        # gestionnaire de processus
    btop        # gestionnaire de processus, plus graphique
    mc          # gestionnaire de fichiers. Prend 45 Mo, mais la majeur parti est commune aux dépendances de python313
    just
    zellij      # un autre desktop, prend 92 Mo, dont la moitié est commune aux dépendances de python313
    mdcat       # afficheur de fichiers Markdown, prend 13 Mo
    kiwix-tools               # moteur wikipedia local. Lancer avec kiwix-serve --port 8080 "/chemin/vers/fichier.zim"
    llama-cpp-vulkan          # moteur LLM, interface web type Gemini / Chat GPT. Ne prend que 80 Mo : install de base.
  ];
}
