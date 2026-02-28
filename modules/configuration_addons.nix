{ config, lib, pkgs, ... }:

{
  # --- BOOTLOADER & KERNEL ---
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
  boot.plymouth.enable = true;
  # boot.initrd.systemd.enable = true; # integration de systemd dans l'initrd, perme des manipuilations complexes en phase bootloader. Pas utile en utilisation classique.


  # --- SWAP --- 
  # Avec 8 Go de RAM, un ZRAM (swap en ram compressée) bien dimensionné suffit largement pour une machine de bureau ou un laptop classique.
  zramSwap.enable = true;
  zramSwap.priority = 100; # sera utilisé en priorité avant le swap sur disque (s'il existe)
  zramSwap.memoryPercent = 50; # Utilise jusqu'à 50% de la RAM
  boot.kernel.sysctl.vm.swappiness = 100; # Le noyau va commencer à envoyer des plages mémoire en zram sans attendre la saturation
  # swapDevices = [ { device = "/swapfile"; size = 2048; } ]; pas utile avec le zram. Et en l'état, pas compatible si sur un volume BTRFS compressé et avec COW.


  # --- MATÉRIEL & SERVICES ---
  security.apparmor.enable = true; # les flatpaks ont un profil apparmor intégré : ils vont automatiquement profiter de apparmor. L'impact d'apparmor sur les performances est imperceptible.
  services.flatpak.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics = { # Vulkan
    enable = true;
    enable32Bit = true; # Souvent utile pour Steam aussi
  };


  users.users.benoit = {
    uid = 1000; # pour s'assurer qu'on sera bien bénéficiaire des droits sur /home dans le cas d'une réinstallation où /home est conservé
    extraGroups = [ "video" "render" "lp" "scanner" ];
    ]
  };

}
