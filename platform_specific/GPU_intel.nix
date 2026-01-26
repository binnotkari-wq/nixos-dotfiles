{ config, pkgs, ... }:

{
  # 1. Chargement du pilote graphique au niveau du noyau
  # Indispensable pour que le GPU soit reconnu avant même le chargement de l'interface
  boot.initrd.kernelModules = [ "i915" ];

  # 2. Pilote d'affichage pour le serveur X (X11)
  # Le pilote "modesetting" est le standard moderne recommandé pour Intel
  services.xserver.videoDrivers = [ "modesetting" ];

  # 3. Couche d'accélération matérielle (Espace utilisateur)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial pour la compatibilité logicielle étendue

    extraPackages = with pkgs; [
      # --- Accélération Vidéo (VA-API) ---

      # Pour l'i3 de 8e gén (et tout processeur Broadwell ou plus récent)
      intel-media-driver

      # Pour l'i5 de 4e gén (et architectures Haswell/anciennes)
      intel-vaapi-driver

      # --- Calcul & Compatibilité ---

      # Support OpenCL pour le calcul assisté par GPU
      intel-compute-runtime

      # Traduction VDPAU vers VA-API (pour les anciens logiciels)
      libvdpau-va-gl
    ];
  };

  # 4. Utilitaires de diagnostic (Inclus dans l'ISO pour tests rapides)
  environment.systemPackages = with pkgs; [
    mesa-demos # Fournit glxinfo et glxgears
    libva-utils       # Permet de lancer 'vainfo' pour tester l'accélération vidéo
    intel-gpu-tools   # Permet de lancer 'intel_gpu_top' pour voir la charge GPU
  ];
}
