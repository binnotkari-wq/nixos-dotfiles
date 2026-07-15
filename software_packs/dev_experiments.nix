##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-boxes # (33.7 MiB download, 187.2 MiB unpacked)
    distroshelf # (2.8 MiB download, 15.2 MiB unpacked)

    # --- Développement & Data ---
    python313                                           # Version économiquee en espace disque (45 Mo)
    distrobox                                           # Pour tests Silverblue/Debian/Arch sans polluer NixOS
    just                                                # Exécuteur de commandes de projet
  ];

  # --- PODMAN ---
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;                                # Permet compatibilité docker si nécessaire
    defaultNetwork.settings.dns_enabled = true;         # Active le DNS interne pour les conteneurs
  };

  # Active user namespaces correctement
  security.unprivilegedUsernsClone = true;

  # --- VIRTUALISATION ---
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
