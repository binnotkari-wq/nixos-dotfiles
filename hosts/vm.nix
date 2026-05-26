{ config, pkgs, lib, ... }:

{
  # --- MODULES ---
  imports = 
    [
      # lister les imports
    ];

# Permet d'avoir un machine id déclaratif. Généré grâce à systemd-id128 new | tr -d '-'
  environment.etc."machine-id" = {
    text = "538b4138c8ab40a988d92bcb21f2e605\n";
  };


# ajouter les packets qui permettent la bonne communication avec le système hote (spice webdav?)

  environment.systemPackages = with pkgs;
    [
      spice-vdagent       # ne fonctionne pas avec une session wayland sur l'hote.
    ];


  # --- TUNING ---

}
