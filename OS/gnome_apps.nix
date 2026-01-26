{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-tweaks                 # paramètres Gnome supplémentaires
    gnome-extension-manager      # Très pratique pour gérer les extensions sans passer par le navigateur
    firefox                      # natif car pour une meilleure intégration système (KDE Connect, gestion des mots de passe, accélération matérielle). Le Flatpak peut parfois briser le sandboxing interne de Firefox.
    fragments                    # Équivalent de KTorrent (Client BitTorrent GTK)
    pika-backup                  # Pour les sauvegardes, s'intègre parfaitement
    loupe                        # Visionneuse d'images moderne
    gnome-secrets                # gestionnaire de mots de passe compatible keepass
    meld                         # comparateurs de fichiers et dossiers
    zim                          # prise de notes et bobliothèque Markdown
    apostrophe                   # editeur / visualiseur avancé de Markdown
    foliate                      # lecteur ebook
    drawing                      # petit programme de dessin, identique à Paint
    lollypop                     # lecteur de musique
    celluloid                    # lecteur de vidéos
    kodi-wayland                 # plateforme multimedia
    pandoc                       # infrasctructure d'interprétation de fichiers textes et conversions
    kiwix                        # Interpréteur de fichiers wikimedia offline
    llama-cpp-vulkan             # moteur LLM pour IA local, avec interface web type Gemini / Chat GPT
    libreoffice-qt-fresh         # attention, beaucoup de dépendances
    hunspell                     # pour libreoffice
    hunspellDicts.fr-classique   # pour libreoffice
    hunspellDicts.fr-reforme1990 # pour libreoffice
    hunspellDicts.fr-moderne     # pour libreoffice
    hunspellDicts.fr-any         # pour libreoffice
    warzone2100                  # :)
    # heroic                     # C'est l'un des rares cas où le Flatpak est souvent recommandé par la communauté NixOS. Comme Heroic gère des jeux provenant de magasins qui ne supportent pas Linux nativement (Epic/GOG), l'isolation Flatpak fournit un environnement plus "standard" que les jeux Windows apprécient.:
    gimp                         # montage photo, retouche avancé
    pdfarranger                  # manipulateur de fichiers pdf
    handbrake                    # conversion de flux audio et vidéo
    gnome-boxes                  # gestionnaire de machines virtuelles
  ];
}
