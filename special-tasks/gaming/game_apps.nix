{ pkgs, ... }:

{
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # protonup-qt
    # warzone2100                # :)
    # heroic                     # Flatpak est souvent recommandé par la communauté NixOS. Comme Heroic gère des jeux provenant de magasins qui ne supportent pas Linux nativement (Epic/GOG), l'isolation Flatpak fournit un environnement plus "standard" que les jeux Windows apprécient.:
  ];
}
