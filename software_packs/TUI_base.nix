{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Diagnostic & Hardware ---
    pciutils          # Essentiel pour l'inventaire matériel
    lm_sensors        # Surveillance des températures
    stress-ng         # Pour tester la stabilité du Ryzen
    s-tui             # Monitoring CPU en temps réel
    libva-utils       # Permet de lancer 'vainfo' pour tester l'accélération vidéo
    usbutils
    iw

    # --- Système de fichiers & Réseau ---
    wget

    # --- Utilitaires de base ---
    aria2             # gestionnaire de téléchargement universel
    nix-tree          # Analyse des paquets et dépendances
    shellcheck	      # contrôle de syntaxe scripts bash

    
    # --- Services & Contenu ---
    kiwix-tools       # (3.0 MiB download, 12.6 MiB unpacked) wikipedia offline
    ffmpeg            # taille ?
    groff             # taille ?
    imagemagick       # taille ?
    pandoc            # taille ?
  ];
}
