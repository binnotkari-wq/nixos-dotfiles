{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.filelight        # analyseur d'espace disque
    kdePackages.kate             # éditeur de texte avancé
    kdePackages.markdownpart     # module Markdownp pour Kate
    kdePackages.kdialog          # bibliothèque tout simple pour afficher des fenètres grâce à un script
    kdePackages.kde-cli-tools    # bibliothèque tout simple pour afficher des fenètres grâce à un script
    kdePackages.kdeconnect-kde   # connection avec smartphone
    kdePackages.partitionmanager # gestionnaire de partitions disque
    kdePackages.skanpage         # interface scanners
    kdePackages.kolourpaint      # petit programme de dessin, identique à Paint
    kdePackages.kompare          # comparaison de fichiers et répertoires
    kdePackages.kcalc            # calculatrice
    kdePackages.ktorrent         # gestionnaire de téléchargement torrents
    firefox                      # natif car pour une meilleure intégration système (KDE Connect, gestion des mots de passe, accélération matérielle). Le Flatpak peut parfois briser le sandboxing interne de Firefox.
    qownnotes                    # prise de notes et bobliothèque Markdown
    haruna                       # lecteur vidéo
    keepassxc                    # portefeuille de mots de passe
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
    kdePackages.marble           # mappemonde
    kstars                       # planetarium
    librecad                     # CAO
    krita                        # peinture, sketch numérique, drawing avancé
    kdePackages.kdenlive         # montage vidéo complet
    virt-manager                 # préférer peut-être en flatpak pour éviter les services et modules système
    qemu                         # préférer peut-être en flatpak pour éviter les services et modules système
  ];
}
