##############################################################################
# PAS AGNOSTIQUE. Prérequis :
# - variables.nix existe et est renseigné
# - ou édition manuelle de tous les vars + commenter les inherits et 
#   imports de variables.nix
##############################################################################

{ config, pkgs, lib, ... }:

let
  vars = import /etc/nixos/variables.nix { };
  home-manager = builtins.fetchTarball {
   url = "https://github.com/nix-community/home-manager/archive/release-${vars.nixosVersion}.tar.gz";
   # sha256 = "sha256:13sahz1mxbk7n67jvz9fi0f85ax7l6s3ffiwa6x0rfrwfwhgj7x3"; (optionnel, pour verrouiller le commit qu'on, va utiliser)
   # nix-prefetch-url --unpack https://github.com/nix-community/home-manager/archive/release-xx.xx.tar.gz # pour obtenir le SHA
  };
in

{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;                                          # également utile pour déclarer des scripts et des raccourcis .desktop
  home-manager.extraSpecialArgs = { inherit vars; };
  home-manager.users.${vars.username} = { config, pkgs, lib, ... }: {           # hérité de variables.nix
    home.username = vars.username;                                              # hérité de variables.nix
    home.homeDirectory = "/home/${vars.username}";                              # hérité de variables.nix
    home.stateVersion = vars.nixosVersion;                                      # hérité de variables.nix
  };
}
