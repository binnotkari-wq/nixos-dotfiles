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


  # --- TUNINGS SPECIFIQUES ---
  boot.initrd.kernelModules = [ "virtio_gpu" ];                                                 # GPU virtuel

  services.qemuGuest.enable = true;                                                             # Optimisations spécifiques pour les invités QEMU/KVM

  services.spice-vdagentd.enable = true;                                                        # copier-coller hôte / invité. Ne fonctionne pas avec une session wayland sur l'hote.
  services.spice-webdavd.enable = true;                                                         # partage de dossier en indiquant (machine invitée) le chemin dav://localhost:9843 dans Nautilus. Et enregistrer le signet.
}
