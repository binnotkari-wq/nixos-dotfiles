#########################################################################################
# Spécifique à la machine.                                                              #
# Déclare uniquement ce qui ne peut concerner une autre machine.                        #
#########################################################################################

{ config, pkgs, ... }:

{
  # --- SOUS-VOLUME BTRFS SUPPLEMENTAIRE ---
  fileSystems."/cargo" =
    {
      options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
    };


  # --- TDP ---
  powerManagement.powertop.enable = true;                                                       # met en place un service qui applique automatiquement les réglages appliqués. Utiliser seulement sur PC portables.
  # A ADAPTER POUR LE L380
  # Le X240 est parfaitement stable en stress-test avec ces valeurs (et le boost est maintenu, avec une température de moins de 70 degrés!)
  # services.undervolt = {
    # enable = true;
    # coreOffset = -40;                                                                         # Valeur en mV (-80 pour commencer : kernel panic lors du débranchement de l'alim)
    # gpuOffset = -40;                                                                          # L'iGPU peut aussi être undervolté
    # uncoreOffset = -40;                                                                       # Contrôleur mémoire, etc.
    # analogioOffset = 0;                                                                       # Généralement laissé à 0
    # temp = 75;                                                                                # Paramètre optionnel : définit la limite de température avant throttling
  # };
}
