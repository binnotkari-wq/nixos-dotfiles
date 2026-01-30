{ config, lib, pkgs, ... }:

{
  # 1. Gestion de l'énergie et des fréquences (P-State)
  # On active thermald pour éviter le throttling thermique brutal
  services.thermald.enable = true;

  # 2. Configuration de TLP pour un contrôle fin (optionnel mais recommandé)
  services.tlp = {
    enable = false;
    settings = {
      # Utilise le driver intel_pstate
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Energy Performance Preference (EPP)
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Fréquences limites (en pourcentage)
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60; # Limite sur batterie pour l'autonomie
    };
  };

  # 3. Paramètres du Kernel pour forcer Intel P-State si nécessaire
  boot.kernelParams = [ "intel_pstate=active" ];

  # 4. Configuration de l'Undervolting
  # ATTENTION : Commencez par des valeurs faibles (ex: -50) et testez la stabilité.
  environment.systemPackages = with pkgs; [
    undervolt      # Pour vérifier l'état actuel : sudo undervolt --read
  ];

  services.undervolt = {
    enable = true;
    # core = -80;       # Valeur en mV (ex: -80 pour commencer)
    # cache = -80;      # Souvent lié au core, il est conseillé de mettre la même valeur
    # gpu = -40;        # L'iGPU peut aussi être undervolté
    # uncore = -40;     # Contrôleur mémoire, etc.
    # analogio = 0;     # Généralement laissé à 0

    # Paramètre optionnel : définit la limite de température avant throttling
    # temp = 75;
  };
}
