{ config, lib, pkgs, ... }:

{
  ##############################################################################
  # NTSync — accélère les primitives de synchronisation NT utilisées par
  # Wine/Proton (équivalent moderne de esync/fsync). Gain de FPS mesurable
  # dans certains jeux Windows lancés via Proton. Nécessite un noyau récent
  # qui inclut le module (c'est le cas des noyaux mainline récents).
  ##############################################################################
  boot.kernelModules = [ "ntsync" ];


  ##############################################################################
  # earlyoom — tue les processus les plus gourmands en mémoire *avant* que
  # le système ne sature complètement et ne freeze. Filet de sécurité léger,
  # particulièrement utile en jeu où un freeze total est plus pénible qu'un
  # simple crash d'un processus.
  ##############################################################################
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # déclenche si RAM libre < 5%
  };

  services.lact.enable = true; # (en natif, car ne fonctionne pas en flatpak, ne peut pas installer le service)
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    steam-run                                   # crée un environnement FHS à la volée, pratique pour exécuter un vieux binaireo u jeu isolé natif linux, sans avoir à maintenir un container.
    SDL2                                        # pour d'anciens jeux qui utilisent SDL
    mangohud
    warzone2100
    hydralauncher
  ];

  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [ mangohud ];    # On injecte MangoHud directement dans Steam pour MangoApp
  };
}
