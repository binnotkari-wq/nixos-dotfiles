{ config, lib, pkgs, ... }:

{

  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "9p"
    "9pnet_virtio"
  ];

  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
    "virtio_gpu"
  ];

  # Pour QEMU/KVM (le plus courant avec libvirt/virt-manager)
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # Pour le copier-coller et le redimensionnement auto

  # Accélération vidéo VirtIO (essentiel pour la fluidité de l'interface)
  services.xserver.videoDrivers = [ "virtio" ];

  # Montage automatique de dossiers partagés (avec 9P : ne necessitepas de module kernel contrairement au partage virtio)
  fileSystems."/mnt/shared" = {
    fsType = "9p";
    device = "partage";
    options = [ "trans=virtio" "version=9p2000.L" ];
  };

}
