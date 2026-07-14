##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Diagnostic & Hardware ---
    powertop                            # Vital pour optimiser la batterie
    pciutils                            # Essentiel pour l'inventaire matériel
    lm_sensors                          # Surveillance des températures
    stress-ng                           # Pour tester la stabilité du Ryzen
    s-tui                               # Monitoring CPU en temps réel
    libva-utils                         # Permet de lancer 'vainfo' pour tester l'accélération vidéo
    usbutils
    iw

    # --- Système de fichiers & Réseau ---
    wget

    # --- Utilitaires de base ---
    aria2                               # gestionnaire de téléchargement universel
    nix-tree                            # Analyse des paquets et dépendances
    shellcheck                          # contrôle de syntaxe scripts bash
    compsize                            # utilitaire analyse Btrfs
    git                                 # versionning, et interface avec repos en ligne
    mdcat                               # Lecture de documentation Markdown
    dialog                              # outil boites de dialogue scripts
    zenity                              # outil boites de dialogue scripts (GTK)
    libnotify                           # outil boites de dialogue scripts
    hunspell                            # vérificateur orthographe, utilisé à l'échelle du système
    hunspellDicts.fr-any                # dictionaire français, utilisé à l'échelle du système
    hunspellDicts.fr-moderne            # dictionnaire francais, utilisé à l'échelle du système
    nerd-fonts.jetbrains-mono
    
    # --- Services & Contenu ---
    kiwix-tools                         # (3.0 MiB download, 12.6 MiB unpacked) wikipedia offline
    llama-cpp-vulkan                    # (10.6 MiB download, 79.9 MiB unpacked) Pour LLM optimisée GPU/iGPU
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
