{ config, pkgs, ... }:

{

  # Charger le driver nvidia pour X11 et Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting est requis pour la plupart des compositeurs Wayland (Hyprland, Sway, etc.)
    modesetting.enable = true;

    # Utiliser les modules kernel open-source de NVIDIA (recommandé pour RTX 30xx)
    # Note : Si vous rencontrez des problèmes graphiques, essayez de mettre 'false'
    open = true;

    # Activer le menu de configuration NVIDIA
    nvidiaSettings = true;

    # Sélectionner le package de pilotes (stable est généralement le meilleur choix)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
