{ config, pkgs, lib, ... }:

{

  # --- outils de diagnostic, de gestion de fichiers et de dépannage ---
  environment.systemPackages = with pkgs; [
    # --- Diagnostic & Hardware (Dell 5485 / R5-3600) ---
    stress-ng         # Pour tester la stabilité du Ryzen
    s-tui             # Monitoring CPU en temps réel

    # --- Utilitaires de base ---
    nix-tree          # Analyse des paquets et dépendances
    stow              # Gestion de tes dotfiles personnels
  ];

  # --- usage quotidien, outils de confort et expérimentations (IA/LLM) ---
  users.users.benoit.packages = with pkgs; [
    # --- Workflow & Productivité ---
    btop              # Version "esthétique" de htop (confort visuel)
    mc                # Gestionnaire de fichiers interactif
    zellij            # Ton multiplexeur de terminal (TUI Desktop)
    just              # Ton exécuteur de commandes de projet
    mdcat             # Lecture de documentation Markdown

}
