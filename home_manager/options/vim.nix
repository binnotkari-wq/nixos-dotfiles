{ config, pkgs, lib, ... }:

# A utiliser en tant qu'import home manager.

{

programs.vim = {
  enable = true;
  
  # Active la coloration syntaxique et les numéros de ligne de base
  settings = {
    number = true;         # Affiche les numéros de ligne
    # relativenumber = true; # Numérotation relative (génial pour sauter de ligne en ligne)
    shiftwidth = 4;        # Taille de la tabulation (4 espaces)
    tabstop = 4;
    expandtab = true;      # Transforme les tabulations en espaces
  };

  # Configuration personnalisée (le fameux vimrc)
  extraConfig = ''
    colorscheme evening
    
    " Activer la coloration syntaxique
    syntax on

    " Permettre l'utilisation de la souris (très utile pour débuter !)
    set mouse=a

    " Surligner la ligne où se trouve le curseur
    set cursorline

    " Recherche intelligente (insensible à la casse sauf si une majuscule est tapée)
    set ignorecase
    set smartcase

    " Partager le presse-papiers avec ton système (Ctrl+C / Ctrl+V fonctionnent avec Vim)
    set clipboard=unnamedplus

    " Raccourci pour enlever le surlignage de la dernière recherche avec Echap
    nnoremap <Esc> :noh<CR><Esc>

    let g:airline_theme='tomorrow'

    " Personnaliser l'en-tête de la page d'accueil avec tes raccourcis clés
    let g:startify_custom_header = [
          \ '   ====================================================',
          \ '   │            MON PENSE-BÊTE VIM EN MODE NORMAL      │',
          \ '   ====================================================',
          \ '   │  i : Passer en mode Insertion (pour écrire)       │',
          \ '   │  Esc : Revenir au mode Normal                    │',
          \ '   │  :w : Sauvegarder       │  :q : Quitter           │',
          \ '   │  u  : Annuler (Ctrl+Z)  │  x  : Supprimer carac.  │',
          \ '   │  dd : Couper la ligne   │  p  : Coller            │',
          \ '   ====================================================',
          \ ]

  '';

  # Quelques plugins essentiels pour débuter sans être submergé
  plugins = with pkgs.vimPlugins; [
    vim-airline           # Une barre de statut en bas bien plus jolie et informative
    vim-airline-themes    # Thèmes pour la barre de statut
    vim-nix               # Support de la coloration syntaxique pour les fichiers .nix
    vim-which-key
    vim-startify
  ];
};


}
