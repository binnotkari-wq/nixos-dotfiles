{ config, pkgs, lib, ... }:

{
    # ============================================================
    # XDG USER DIRS
    # ============================================================
    # xdg.userDirs gère ~/.config/user-dirs.dirs de façon déclarative.
    # Les chemins sont relatifs à $HOME, ou absolus.
    # NixOS crée les dossiers automatiquement si enable = true.

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop     = "${config.home.homeDirectory}/Bureau";
      download    = "${config.home.homeDirectory}/Téléchargements";
      templates   = "${config.home.homeDirectory}/Modèles";
      publicShare = "${config.home.homeDirectory}/Public";
      documents   = "${config.home.homeDirectory}/Documents";
      music       = "${config.home.homeDirectory}/Mes-Donnees/03_Ressources_Externes/Musique";
      pictures    = "${config.home.homeDirectory}/Images";
      videos      = "${config.home.homeDirectory}/Vidéos";
    };

    # ============================================================
    # MIME / ASSOCIATIONS
    # ============================================================

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/x-shellscript" = "org.gnome.TextEditor.desktop";
        "inode/symlink"             = "org.gnome.TextEditor.desktop";
        "text/markdown"   = [ "firefox.desktop" ];
        "text/x-markdown" = [ "firefox.desktop" ];
      };
    };

    # ============================================================
    # FICHIERS MODELES
    # ============================================================

      home.file."${config.home.homeDirectory}/Modèles/Fichier Markdown.md" = {
        text = ''
        # H1
        ## H2
        ### H3...etc...

        *Italique*

        **gras**

        ```bash
        # Un commentaire
        cd /usr/bin &&
        Texte aléatoire
        Encadré par ```
        ```
        [Markdown Cheatsheet.md] (${config.home.homeDirectory}/Mes-Donnees/03_Ressources_Externes/Utilisation du syst%C3%A8me/Markdown Cheatsheet.md)
        '';
      };

      home.file."${config.home.homeDirectory}/Modèles/Fichier texte.txt" = {
        text = ''
        '';
      };

      home.file."${config.home.homeDirectory}/Modèles/Script.sh" = {
        executable = true;
        text = ''
        #!/usr/bin/env bash
        
        ########################
        # Descriptif du script #
        ########################

        '';
      };
      
      home.file."${config.home.homeDirectory}/Modèles/Fichier nix.nix" = {
        text = ''
        #############################
        # Descriptif du fichier nix #
        #############################
        
        { config, pkgs, lib, ... }:

        {

        }
        '';
      };

    # ============================================================
    # RACCOURCIS VERS LES SCRIPTS
    # ============================================================

    xdg.desktopEntries = {
      llm-start = {
        name = "Démarrer LLM";
        exec = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/start_llm.sh";
        terminal = true;
        icon = "media-playback-start";
        type = "Application";
        comment = "Lance le serveur llama.cpp";
        categories = [ "Education" ];
      };

      llm-stop = {
        name = "Arrêter LLM";
        exec = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/stop_llm.sh";
        terminal = false;
        icon = "media-playback-stop";
        type = "Application";
        comment = "Arrête le serveur llama.cpp";
        categories = [ "Education" ];
      };

      kiwix = {
        name = "Démarrer Kiwix";
        exec = "${config.home.homeDirectory}/Mes-Donnees/Git/scripts/kiwix-launcher.sh";
        terminal = false;
        icon = "accessories-dictionary";
        type = "Application";
        comment = "Lance le serveur Kiwix";
        categories = [ "Education" ];
      };
    };
}
