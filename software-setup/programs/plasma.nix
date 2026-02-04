{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- CORECTRL pour la gestion CPU intel / AMD et GPU AMD / Nvidia / intel ---
  programs.corectrl.enable = true;

  # --- LOGICIELS SUPPLEMENTAIRES ---  
  environment.systemPackages = with pkgs; [
    firefox                                     # natif car pour une meilleure intégration système
    kdePackages.filelight                       # analyseur d'espace disque
    kdePackages.markdownpart                    # module Markdownp pour Kate
    kdePackages.kdialog                         # bibliothèque tout simple pour afficher des fenètres grâce à un script
    kdePackages.kde-cli-tools                   # bibliothèque tout simple pour afficher des fenètres grâce à un script
    kdePackages.kdeconnect-kde                  # connection avec smartphone
    kdePackages.partitionmanager                # gestionnaire de partitions disque
    kdePackages.skanpage                        # interface scanners
    kdePackages.kolourpaint                     # petit programme de dessin, identique à Paint
    kdePackages.kompare                         # comparaison de fichiers et répertoires
    kdePackages.kcalc                           # calculatrice
    kdePackages.ktorrent                        # gestionnaire de téléchargement torrents
    qownnotes                                   # prise de notes et bobliothèque Markdown
    haruna                                      # lecteur vidéo
    keepassxc                                   # portefeuille de mots de passe
    kiwix                                       # Interpréteur de fichiers wikimedia offline. Ne prend que 12 Mo : install de base.
    llama-cpp-vulkan                            # moteur LLM, interface web type Gemini / Chat GPT. Ne prend que 80 Mo : install de base.
  ]; 
 
  # --- LOGICIELS A SUPPRIMER DE BASE ---
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];
}
