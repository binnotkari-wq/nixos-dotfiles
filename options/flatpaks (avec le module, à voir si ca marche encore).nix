{ config, pkgs, ... }:

let
  # On récupère le module nix-flatpak directement depuis GitHub
  nix-flatpak = builtins.fetchTarball {
    url = "https://github.com/gmodena/nix-flatpak/archive/main.tar.gz";
    # Optionnel : sha256 pour plus de sécurité
  };
in
{
  imports = [
    "${nix-flatpak}/modules/home-manager.nix"
  ];


  # --- Configuration Flatpak ---
  services.flatpak = {
    enable = true;
    # C'est ici qu'on défini les flatpaks en espace utilisateur !
    target = "user"; 
    prefersOverSystem = true;
    
    update.auto.enable = true;

    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];

    packages = [
      "org.gnome.gitlab.somas.Apostrophe"
    ];
  };

}
