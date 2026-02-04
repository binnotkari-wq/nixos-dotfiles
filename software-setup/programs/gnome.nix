{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- LACT pour la gestion GPU AMD / Nvidia / intel ---
  services.lact.enable = true;

  # --- LOGICIELS SUPPLEMENTAIRES --- 
  environment.systemPackages = with pkgs; [
    firefox                                     # natif car pour une meilleure intégration système
    gnome-tweaks                                # paramètres Gnome supplémentaires
    gnomeExtensions.dash-to-panel               # extension : barre des taches
    gnomeExtensions.arcmenu                     # menu système
    fragments                                   # Équivalent de KTorrent (Client BitTorrent GTK)
    gnome-secrets                               # gestionnaire de mots de passe compatible keepass
    meld                                        # comparateurs de fichiers et dossiers. Trouver autre chose ?
    apostrophe                                  # editeur / visualiseur Markdown
    foliate                                     # lecteur ebook
    drawing                                     # petit programme de dessin, identique à Paint
    lollypop                                    # lecteur de musique
    celluloid                                   # lecteur de vidéos
    kiwix                                       # Interpréteur de fichiers wikimedia offline. Ne prend que 12 Mo : install de base.
    llama-cpp-vulkan                            # moteur LLM, interface web type Gemini / Chat GPT. Ne prend que 80 Mo : install de base.
  ];

  # --- LOGICIELS A SUPPRIMER DE BASE ---
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    showtime
    gnome-software
    gnome-music
    gnome-connections
  ];
}
