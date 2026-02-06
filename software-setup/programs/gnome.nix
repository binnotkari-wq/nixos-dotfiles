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
    gnome-secrets                               # gestionnaire de mots de passe compatible keepass
    fragments                                   # Équivalent de KTorrent (Client BitTorrent GTK)
    foliate                                     # lecteur ebook
    celluloid                                   # lecteur de vidéos
    pinta                                       # logiciel de dessin
    kiwix-tools                                  # moteur wikipedia local. Lancer avec kiwix-serve --port 8080 "/chemin/vers/fichier.zim"
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
    gnome-connections
  ];
  
  # --- REGLAGES GNOME ---
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
