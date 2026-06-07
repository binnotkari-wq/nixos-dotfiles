{ config, pkgs, vars, ... }:

let
  vars = import ./variables.nix;
in

{
  _module.args = { inherit vars; };

  imports =
    [
      ./DE/niri.nix # pointer vers le D.E. à utiliser
      ./drivers/CPU_intel_pre10.nix # pointer vers divers CPU adapté
      ./drivers/iGPU_intel.nix # pointer vers divers GPU adapté
      ./home_manager/home.nix # optionnel
      ./OS/core.nix # obligatoire
      # ./roles/workstation_GTK.nix # optionnel
      # ./roles/gaming.nix # optionnel
      # ./roles/SteamOS.nix # optionnel
      
    ];

  # Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "a0768d6ce6c9403c94e014c102ca6b16\n";
  };

  # --- TUNINGS SPECIFIQUES ---
  
  # A ADAPTER POUR LE L380
  # Le X240 est parfaitement stable en stress-test avec ces valeurs (et le boost est maintenu, avec une température de moins de 70 degrés!)
  # services.undervolt = {
  #   enable = true;
  #   coreOffset = -40;       # Valeur en mV (-80 pour commencer : kernel panic lors du débranchement de l'alim)
  #   gpuOffset = -40;        # L'iGPU peut aussi être undervolté
  #   uncoreOffset = -40;     # Contrôleur mémoire, etc.
  #   analogioOffset = 0;     # Généralement laissé à 0

    # Paramètre optionnel : définit la limite de température avant throttling
    # temp = 75;
  # };
}
