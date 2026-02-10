{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git         # interface de versionning
    wget        # téléchargement de fichiers par http
    pciutils    # pour la commande lspci
  ];
}
