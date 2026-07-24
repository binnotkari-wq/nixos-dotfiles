#########################################################################################
# Spécifique à la machine.                                                              #
# Permet d'importer les d'options et packages .nix de façon selective                   #
#########################################################################################

{ config, pkgs, ... }:

{
  # --- TUNINGS SPECIFIQUES ---
  boot.initrd.kernelModules = [ "virtio_gpu" ];                                                 # GPU virtuel

  services.qemuGuest.enable = true;                                                             # Optimisations spécifiques pour les invités QEMU/KVM

  services.spice-vdagentd.enable = true;                                                        # copier-coller hôte / invité. Ne fonctionne pas avec une session wayland sur l'hote.
  services.spice-webdavd.enable = true;  
}
