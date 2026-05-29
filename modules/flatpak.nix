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
      "org.gnome.gitlab.somas.Apostrophe"
      # "org.gnome.meld"
      # "org.libreoffice.LibreOffice" # préférer la version pkgs nix
      # "com.heroicgameslauncher.hgl"
      # "net.lutris.Lutris"
      # "com.usebottles.bottles"
      # "com.valvesoftware.Steam"
      # "com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
      # "io.github.flattool.Warehouse"
      # "com.github.tchx84.Flatseal"
    ];
    uninstallUnmanaged = true;
  };
}
