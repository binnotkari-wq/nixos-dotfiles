{ config, lib, pkgs, ... }:

# Nixos active de base le firewall. Inutile de le déclarer.

{
  # --- BOOTLOADER & KERNEL ---
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true; # integration de systemd dans l'initrd, Gestion native, systemd-ask-password-plymouth.service prend en charge la demande du mot de passe. Systemd démarre les pilotes graphiques et Plymouth de manière beaucoup plus propre et synchronisée que le script par défaut. C'est la méthode utilisée par Fedora ou Ubuntu.

  # --- OPTIONS LUKS ---
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  # --- MATÉRIEL & SERVICES ---
  security.apparmor.enable = true; # les flatpaks ont un profil apparmor intégré : ils vont automatiquement profiter de apparmor. L'impact d'apparmor sur les performances est imperceptible.
  services.flatpak.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true; # Vulkan

  # --- UTILISATEUR ---
  users.users.benoit = {
    uid = 1000; # pour s'assurer qu'on sera bien bénéficiaire des droits sur /home dans le cas d'une réinstallation où /home est conservé
    extraGroups = [ "video" "render" "lp" "scanner" ];
  };

}
