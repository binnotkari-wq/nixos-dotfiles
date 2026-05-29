{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = 
    [

    ];

  boot.initrd.kernelModules = [ "virtio_gpu" ];

# Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "538b4138c8ab40a988d92bcb21f2e605\n";
  };

  # Optimisations spécifiques pour les invités QEMU/KVM
  services.qemuGuest.enable = true;

  # Active l'agent SPICE pour le copier-coller et le redimensionnement d'écran automatique
  services.spice-vdagentd.enable = true; # ne fonctionne pas avec une session wayland sur l'hote.
  services.spice-webdavd.enable = true; # partage de dossier en indiquant (machine invitée) le chemin dav://localhost:9843 dans Nautilus. Et enregistrer le signet.
}
