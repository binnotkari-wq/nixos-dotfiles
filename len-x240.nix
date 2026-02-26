{ config, pkgs, ... }:

{
  # --- MODULES ---
  imports = [

  ];

  # --- TUNING ---
  # Le X240 est parfaitement stable en stress-test avec ces valeurs (et le bosst est maintenu, avec une température de moins de 70 degrés!)
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
