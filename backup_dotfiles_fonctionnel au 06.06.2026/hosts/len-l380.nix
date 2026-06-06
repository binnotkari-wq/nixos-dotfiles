{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./HW-tuning_CPU_intel.nix
  ./HW-tuning_iGPU_intel.nix
  ./tests1.nix
  ];

# Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "a0768d6ce6c9403c94e014c102ca6b16\n";
  };


  # A ADAPTER POUR LE L380 !!
  # --- TUNING ---
  # Le X240 est parfaitement stable en stress-test avec ces valeurs (et le boost est maintenu, avec une température de moins de 70 degrés!)
  services.undervolt = {
    enable = true;
    coreOffset = -40;       # Valeur en mV (-80 pour commencer : kernel panic lors du débranchement de l'alim)
    gpuOffset = -40;        # L'iGPU peut aussi être undervolté
    uncoreOffset = -40;     # Contrôleur mémoire, etc.
    analogioOffset = 0;     # Généralement laissé à 0

    # Paramètre optionnel : définit la limite de température avant throttling
    # temp = 75;
  };
}
