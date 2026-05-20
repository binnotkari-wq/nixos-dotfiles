{ config, pkgs, ... }:

let
  nix-flatpak = builtins.fetchTarball
    "https://github.com/gmodena/nix-flatpak/archive/refs/tags/v0.7.0.tar.gz";
in
{
  imports = [ "${nix-flatpak}/nixos.nix" ];

  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      "org.gnome.gitlab.somas.Apostrophe"
      # "org.libreoffice.LibreOffice"
      # "com.heroicgameslauncher.hgl"
      # "net.lutris.Lutris"
      # "com.usebottles.bottles"
      # "com.valvesoftware.Steam"
      # "com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
      # "io.github.flattool.Warehouse"
      # "com.github.tchx84.Flatseal"
    ];
    uninstallUnmanaged = true; # supprime les flatpaks absents de la liste
  };
}
