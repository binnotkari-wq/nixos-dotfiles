{ config, pkgs, ... }:

{
  # LACT pour la gestion GPU AMD / Nvidia / intel (GTK)
  services.lact.enable = true;

  environment.systemPackages = with pkgs; [
    firefox                      # natif car pour une meilleure intégration système (KDE Connect, gestion des mots de passe, accélération matérielle). Le Flatpak peut parfois briser le sandboxing interne de Firefox.
    gnome-tweaks                 # paramètres Gnome supplémentaires
    gnomeExtensions.applications-menu
    gnomeExtensions.dash-to-panel
    fragments                    # Équivalent de KTorrent (Client BitTorrent GTK)
    pika-backup                  # Pour les sauvegardes, s'intègre parfaitement
    gnome-secrets                # gestionnaire de mots de passe compatible keepass
    meld                         # comparateurs de fichiers et dossiers. Trouver autre chose ?
    apostrophe                   # editeur / visualiseur Markdown
    foliate                      # lecteur ebook
    drawing                      # petit programme de dessin, identique à Paint
    lollypop                     # lecteur de musique
    celluloid                    # lecteur de vidéos
    kiwix                        # Interpréteur de fichiers wikimedia offline. Ne prend que 12 Mo : install de base.
    llama-cpp-vulkan             # moteur LLM pour IA local, avec interface web type Gemini / Chat GPT. Ne prend que 80 Mo : install de base.
    # kodi-wayland                 # plateforme multimedia
    # libreoffice-fresh            # attention, beaucoup de dépendances
    # hunspell                     # pour libreoffice
    # hunspellDicts.fr-classique   # pour libreoffice
    # hunspellDicts.fr-reforme1990 # pour libreoffice
    # hunspellDicts.fr-moderne     # pour libreoffice
    # hunspellDicts.fr-any         # pour libreoffice
    # warzone2100                  # :)
    # heroic                     # C'est l'un des rares cas où le Flatpak est souvent recommandé par la communauté NixOS. Comme Heroic gère des jeux provenant de magasins qui ne supportent pas Linux nativement (Epic/GOG), l'isolation Flatpak fournit un environnement plus "standard" que les jeux Windows apprécient.:
    # gimp                         # montage photo, retouche avancé
    # pdfarranger                  # manipulateur de fichiers pdf
    # handbrake                    # conversion de flux audio et vidéo
    # gnome-boxes                  # gestionnaire de machines virtuelles



    # zim                          # prise de notes et bobliothèque Markdown. Trouver autre chose ?
    # loupe                        # Visionneuse d'images moderne. Déjà dans Gnome.
  ];
}
