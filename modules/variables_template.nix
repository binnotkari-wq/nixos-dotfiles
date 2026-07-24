################################################################################################
# bootstrap.sh substitue les @@placeholders@@ d'après les infos saisie lors de l'intallation.  #
# bootstrap réalise la subsitution APRES avoir copié et renommé en variables.nix : ceci permet #
# d'anonymiser le repo git puisque variables.nix est dans .gitignore) et que tous les autres   #
# fichiers .nix contiennet le nom de la variable et non sa valeur (----> les .nix sont figés). #
# Si bootstrap n'est pas utilisé, modiler les @@placeholders@@ manuellement                    #
# Importer ce fichiers dans un des autres nix : les vars sont propagées dans tous les autres   #
# fichiers .nix qui font appel à vars (quels que soient les niveaux d'imports).                #
################################################################################################

{ ... }:

{
  username          = "@@username@@";
  fullname          = "@@fullname@@";
  hashedPassword    = "@@hashedPassword@@";     # remplacer par le résultat de : mkpasswd lemotdepasse (par défaut ce hash sera généré avec l'algorythme yescrypt).
  hostname          = "@@hostname@@";
  machineid         = "@@machineid@@";          # remplacer par le résultat de : systemd-id128 new | tr -d '-'
  luksUuid          = "@@luksUuid@@";           # remplacer par le résultat de : sudo cryptsetup luksUUID /dev/nvme0n1p2 (ou autre périphérique qui contient le volume luks - si le volume LUKS porte un nom personnalisé, il faut remplacer par son nom)
  nixosVersion      = "@@nixosversion@@";
  gitUsername       = "@@gitUsername@@";
  gitUsermail       = "@@gitUsermail@@";
  rootSubvolumeName = "@@rootSubvolumeName@@";  # remplacer par le résultat de : sudo btrfs subvolume show / | cut -f1
}

################################################################################################
# Import :                                                                                     #
################################################################################################
# { config, pkgs, ... }:
#
# let                                           # ces 3 lignes sont à
#   vars = import ./variables.nix { };          # insérer tout de suite
# in                                            # après { config, pkgs, ... }:
#
# {
#   _module.args.vars = vars;                   # cette ligne est à insérer tout de suite après le premier { ouvert
#
#   imports =
#     [
#       ./un/import.nix
#       ./autre/import.nix
#     ];
#   Le reste
#   du fichier nix
################################################################################################




################################################################################################
# Propagations :                                                                               #
################################################################################################
#   username          # utilisé par impermanence.nix, pseudo-impermanence.nix et home-manager.nix
#   fullname          # inutilisé
#   hashedPassword    # utilisé par impermanence.nix et pseudo-impermanence.nix
#   hostname          # utilisé par impermanence.nix et pseudo-impermanence.nix
#   machineid         # utilisé par impermanence.nix et pseudo-impermanence.nix
#   luksUuid          # utilisé par impermanence.nix
#   nixosVersion      # utilisé par home-manager.nix
#   gitUsername       # utilisé par git.nix
#   gitUsermail       # utilisé par git.nix
#   rootSubvolumeName # utilisé par impermanence.nix
################################################################################################
