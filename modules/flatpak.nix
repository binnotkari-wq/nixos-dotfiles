##############################################################################
# 100% agnostique, applicable à toute configuration
##############################################################################

{ config, pkgs, ... }:

let
  nix-flatpak = builtins.fetchTarball {
    url = "https://github.com/gmodena/nix-flatpak/archive/refs/tags/v0.7.0.tar.gz";
    sha256 = "sha256:1jsxx20jv2dmf75563i9ldyva99d0qcls2rm424ikx83hnasx47d";
  };
in
{
  imports = [
    "${nix-flatpak}/modules/nixos.nix"
  ];

  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      # "org.gnome.gitlab.somas.Apostrophe"  # Utiliser plutot marker en pkg Contrairement à Apostrophe en pkg, ne tire quasi aucune dépendance.
      # "org.libreoffice.LibreOffice" # préférer la version pkgs nix
      # "com.heroicgameslauncher.hgl" # préférer la version pkgs nix
      # "net.lutris.Lutris" # inutile : Heroic (en pkg) gère très bien SKetchup (seul logiciel windows utilisé)
      # "com.usebottles.bottles" # inutile : Heroic (en pkg) gère très bien SKetchup (seul logiciel windows utilisé)
      # "com.valvesoftware.Steam"
      # "com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
      # "io.github.flattool.Warehouse"
      # "com.github.tchx84.Flatseal"
      # "net.retrodeck.retrodeck"
      # "org.libretro.RetroArch"
    ];
    uninstallUnmanaged = true;
  };

  # gnome-software fait partie des paquets installés automatiquement avec flatpak. Mais on en a pas besoin.
  environment.gnome.excludePackages = with pkgs; [
    gnome-software
  ];
}
