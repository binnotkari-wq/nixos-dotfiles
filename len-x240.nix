{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = [
  ./drivers_settings/CPU_intel_pre10.nix
  ./drivers_settings/iGPU_intel.nix
  ];

# Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "813a1841e6d14827827edc58b5269bf1\n";
  };

  # --- TUNINGS SPECIFIQUES ---

  powerManagement.powertop.enable = true; # met en place un service qui applique automatiquement les réglages appliqués. Utiliser seulement sur PC portables.

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
