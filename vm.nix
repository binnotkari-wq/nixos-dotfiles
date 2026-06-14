{ config, pkgs, lib, ... }:

let
  vars = import ./variables.nix;
in

{
  _module.args = { inherit vars; };

  imports =
    [
      ./OS/core.nix # obligatoire
      ./DE/gnome.nix # pointer vers le D.E. à utiliser
      # ./home_manager/home.nix # optionnel
      ./modules/impermanence.nix # optionnel
      # ./modules/prefs_firefox.nix # optionnel
      # ./modules/SteamOS.nix # optionnel
      # ./software_packs/dev_experiments.nix # optionnel
      # ./software_packs/gaming.nix # optionnel
      # ./software_packs/GTK_all.nix # optionnel
      # ./software_packs/GTK_base.nix # optionnel
      # ./software_packs/TUI_all.nix # optionnel
      # ./software_packs/TUI_base.nix # optionnel
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
