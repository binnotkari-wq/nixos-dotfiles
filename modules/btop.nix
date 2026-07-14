{ config, pkgs, vars, ... }:

{

# btop va chercher sa configuration dans ~/.config/btop/btop.conf. On peut déclarer
# sa configuration en créant le fichier .conf (création possible uniqueent dans /etc/)
# puis en générant un lien à chaque démarrage
# vers ~/.config/btop/btop.conf.

# On déclare le fichier de configuration réel et immuable dans /etc
  environment.etc."btop/btop.conf".text = ''
    color_theme = "gruvbox_material_dark"
    theme_background = true
  '';

  systemd.tmpfiles.rules = [
    # Type | Chemin du lien à créer | Mode | Utilisateur | Groupe | Argument (Fichier réel pointé)
    "d  /home/${vars.username}/.config/btop 0755 ${vars.username} users - -"
    "L+ /home/${vars.username}/.config/btop/btop.conf - ${vars.username} users - /etc/btop/btop.conf"
  ];

}
