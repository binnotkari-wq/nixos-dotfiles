################################################################################
# A utiliser en tant qu'import home manager. Newsboat n'a aucune configuration #
# au niveau du système, uniquement dans l'environnement utilisateur.           #
# -> la configuration est donc déclarée par home-manager                       #
################################################################################

{ config, pkgs, lib, ... }:

{
  programs.newsboat = {
    enable = true;
    autoReload = true; # Optionnel : recharge les flux au démarrage
    urls = [
      { url = "https://www.linuxjournal.com/node/feed"; tags = [ "tech" "linux" ]; }
      { url = "https://www.gamingonlinux.com/article_rss.php"; tags = [ "gaming" "linux" ]; }
    ];
  };
}
