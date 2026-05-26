{ config, pkgs, ... }:

{

# un fichier nix qui defini des scripts shell (il me semble que c'est une fonction permise par home manager)
# - un script qui afficherai les princiales commandes de nixos (rebuild swith, test, boot, listing des generations, le nettoyage du garbage, les fonctionnalités de nix-shell, nix-env ...), juste en tapant "sys"
# - un script  "git-sync"
# - un script bash history export



  home.packages = [

    (pkgs.writeShellScriptBin "alias_perso" ''
      awk '/environment.shellAliases = \{/ {flag=1; next} /\};/ {flag=0} flag' /etc/nixos/configuration.nix
    '')

#    (pkgs.writeShellScriptBin "sys" ''    
#      printf "
#\e[33msudo nixos-rebuild test -I nixos-config=/home/@@USERNAME@@/Mes-Donnees/Git/nixos-dotfiles/$(hostname).nix\e[0m : rebuild simple\n
#\e[33msudo nixos-rebuild boot -I nixos-config=/home/@@USERNAME@@/Mes-Donnees/Git/nixos-dotfiles/$(hostname).nix\e[0m : nouvelle entrée de boot\n
#\e[33msudo nixos-rebuild switch -I nixos-config=/home/@@USERNAME@@/Mes-Donnees/Git/nixos-dotfiles/$(hostname).nix\e[0m : rebuild système et bascule live\n
#\e[33msudo nix-env --list-generations --profile /nix/var/nix/profiles/system\e[0m : lister les générations\n
#\e[33msudo nix-collect-garbage -d\e[0m : gros nettoyage\n
#\e[33mhome-manager switch -f /home/@@USERNAME@@/Mes-Donnees/Git/home-manager/home.nix\e[0m : rebuild home manager et bascule live\n"
# alias : affiche les raccourcis vers des fonctions utiles
#    '')

#    (pkgs.writeShellScriptBin "upd" ''     
#      printf "
#\e[33mflatpak update -y\e[0m : mise à jour flatpaks\n
#\e[33mcd ~/Mes-Donnees/Git/nixos-dotfiles && git add . && git commit -m description_du_commit && git pull origin main && git push origin main\e[0m : synchro git\n"
#    '')

  ];  
 
}
