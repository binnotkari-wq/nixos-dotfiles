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
  username        = "@@username@@";
  fullname        = "@@fullname@@";
  hashedPassword  = "@@hashedPassword@@";                                                        # remplacer par le résultat de : mkpasswd lemotdepasse (par défaut ce hash sera généré avec l'algorythme yescrypt).
  hostname        = "@@hostname@@";
  machineid       = "@@machineid@@";                                                             # remplacer par le résultat de : systemd-id128 new | tr -d '-'
  luksUuid        = "@@luksUuid@@";                                                              # utile si on utilise un des modules impermanence. Remplacer par le résultat de : sudo cryptsetup luksUUID /dev/nvme0n1p2 (ou autre périphérique qui contient le volume luks - si le volume LUKS porte un nom personnalisé, il faut remplacer par son nom)
  nixosVersion    = "@@nixosversion@@";                                                          # version Nixos installée
  gitUsername     = "@@gitUsername @@";                                                          # utile si on utilise git.nix
  gitUsermail     = "@@gitUsermail@@";                                                           # utile si on utilise git.nix
}

###########################################################################################################
# Import :                                                                                                #
###########################################################################################################
# { config, pkgs, ... }:

# let                                           # ces 3 lignes sont à
  # vars = import ./variables.nix { };          # insérer tout de suite
# in                                            # après { config, pkgs, ... }:

# {
  # _module.args.vars = vars;                   # cette ligne est à insérer tout de suite après le premier { ouvert

  # imports =
    # [
      # ./un/import.nix
      # ./autre/import.nix
    # ];
  # Le reste
  # du fichier nix
#################################################################################################################
