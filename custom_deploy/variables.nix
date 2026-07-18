################################################################################################
# bootstrap.sh substitue les @@placeholders@@ d'après les infos saisie lors de l'intallation.  #
# Les substitutions sont réalisées APRES avoir copie de variables.nix dans /etc/nixos : ceci   #
# permet d'anonymiser le repo git et tous les autres fichiers .nix (qui restent donc figés     #
# puisqu'ils ne contiennent que le nom de la variable et non sa valeur).                       #
# Ce fichier est importé dans configuration.nix : les vars sont propagées dans tous les autres #
# fichiers .nix qui font appel à vars (quels que soient les niveaux d'imports).                #
################################################################################################

{ ... }:

{
  username        = "@@username@@";
  fullname        = "@@fullname@@";
  hashedPassword  = "@@hashedPassword@@";
  hostname        = "@@hostname@@";
  machineid       = "@@machineid@@";
  luksUuid        = "@@luksUuid@@";
  nixosVersion    = "@@nixosversion@@";
  gitUsername     = "@@gitUsername @@";
  gitUsermail     = "@@gitUsermail@@";
}
