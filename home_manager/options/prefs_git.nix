{ config, pkgs, lib, ... }:

# A utiliser en tant qu'import home manager.

{
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        credential.helper = "store";
        user.name = "@@GIT_USERNAME@@";
        user.email = "@@GIT_USERMAIL@@";
      };
    };
  
  
    # Service systemd qui execute le script de synchronsiation git à la fermeture de session
    systemd.user.services.git-sync-on-shutdown = {
      Unit = {
        Description = "Synchronisation Git des dépôts à la fermeture de session";
        # On s'assure que le réseau est encore disponible si possible
        After = [ "network.target" ];
      };

      Service = {
        Type = "oneshot";
        # L'astuce : RemainAfterExit permet de déclencher ExecStop à la fin
        RemainAfterExit = true;
        ExecStart = "/bin/sh -c 'echo Initialisation du service de sync'";
        ExecStop = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/Mes-Donnees/Git/scripts/git-sync.sh";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
}
