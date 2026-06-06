{ config, pkgs, vars, ... }:

let
  vars = import ./variables.nix;
in

{
  _module.args = { inherit vars; };

  imports =
    [
      ./DE/gnome.nix # pointer vers le D.E. à utiliser
      ./drivers/CPU_AMD.nix # pointer vers divers CPU adapté
      ./drivers/GPU_AMD.nix # pointer vers divers GPU adapté
      ./home_manager/home.nix # optionnel
      ./OS/core.nix # obligatoire
      ./roles/workstation_GTK.nix # optionnel
      ./roles/gaming.nix # optionnel
      ./roles/SteamOS.nix # optionnel
      
    ];

  # Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n";
  };

    # --- TUNINGS SPECIFIQUES ---



}
