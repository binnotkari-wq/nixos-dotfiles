{ config, pkgs, lib, ... }:

# A utiliser en tant qu'import home manager.

# Ce .nix va générer une distrobox qui permet de lancer Return to Castle Wolfenstein, et probablement d'autres jeux,
# qui ont besoin d'un FHS standard.
{

  # Fichier d'assemblage déclaratif : pour la construction d'une distrobox avec ubuntu et les dépendances nécessaire à RTCW
  home.file.".config/distrobox/assemble.ini".text = ''
    [gaming]
    image=ubuntu:24.04
    volume=/cargo:/cargo
    init_hooks=dpkg --add-architecture i386 && apt update && apt install -y libsdl2-2.0-0 libsdl2-2.0-0:i386 libsdl1.2debian:i386 libgl1:i386 libopenal1:i386
  '';

  # Active/recrée la boîte si la conf a changé
  home.activation.distroboxAssemble = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="/run/current-system/sw/bin:$PATH"
    $DRY_RUN_CMD ${pkgs.distrobox}/bin/distrobox assemble create --file ${config.home.homeDirectory}/.config/distrobox/assemble.ini
  '';

  # Création du raccourci vers RTCW
  xdg.desktopEntries.rtcw = {
    name = "Return to Castle Wolfenstein";
    comment = "Lancer Return to Castle Wolfenstein";
    exec = ''distrobox-enter --name gaming -- "/cargo/Jeux natifs/iortcw-1.51c-linux-x86_64/iowolfsp.x86_64"'';
    icon = "/cargo/Jeux natifs/iortcw-1.51c-linux-x86_64/WolfSP.xpm";
    terminal = false;
    type = "Application";
    categories = [ "Game" ];
  };
}
