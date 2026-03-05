# Conditions

Une installation doit avoir été faire, en manuel ou par Calamares, sur une partition BTRFS. On suppose qu'il y a un sous-volume BTRFS pour /home (c'est ce que Calamares fait quand on choisi BTRFS).
Dans le cas contraire, ou s'il y a d'autres sous volumes, il faudra éditer le fichier ./modules/filesystems-settings.nix
On suppose que la partition est chiffrée avec LUKS. Dans le cas contraire, il faudra éditer le fichier ./modules/filesystems-settings.nix


# A faire avant de lancer le rebuild

Sauvegarder : 
sudo cp /etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.backup
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.backup


Modifier configuration.nix :

- Pour y ajouter en import le fichier .nix principal (celui qui porte le nom de la machine).

- Pour y remplacer : 
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  Par :
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
 
Les déclarations "services.xserver....." sont périmées (message d'info lorsqu'on fait un rebuild), sans toutefois être fausse. Elle sont automatiquement remplacées lors du calcul de la dérivation, mais autant corriger ça à la source (le generateur de .nix de l'installateur Calamares sera probablement mis à jour dans ce sens)

  
  
# A faire

enlever :

orca
et tout ce qui a rapport avec la synthèse vocale 

llvm ? ca prend de la place. à quoi ca sert ? reponse chatgpt : c'est un compilateur, utilisé par mesa pour compiler les shaders. Il peut aussi servir à beaucoup d'autres types de copilation (ne pas supprimer !!!...)






