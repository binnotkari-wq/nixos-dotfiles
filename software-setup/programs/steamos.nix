{ pkgs, ... }:

# infos : si la session steam ne démarre pas, et qu'au bout d'un moment on revient à SSDM....en fait il faut confgurer le client de bureau avant tout (mise à jour, login, langue de l'interface)


let

# 1. On définit la session avec les métadonnées exigées par NixOS
  steam-custom-session = pkgs.runCommand "steam-custom-session" {
    passthru.providedSessions = [ "steam-custom" ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat <<EOF > $out/share/wayland-sessions/steam-custom.desktop
    [Desktop Entry]
    Name=Steam
    Comment=Steam (Gamescope et MangoHud)
    Exec=${pkgs.gamescope}/bin/gamescope --mangoapp -e -- ${pkgs.steam}/bin/steam -steamdeck -steamos3 -gamepadui
    Type=Application
    DesktopNames=gamescope
    EOF
  '';
in

{
  # 1. On dit à SDDM de charger cette session spécifique
  services.displayManager.sessionPackages = [ steam-custom-session ];

  # 2. Le reste de ta config Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false; # on utilise la session custom à la place
    extraPackages = with pkgs; [ mangohud ];
  };

  # 3. Paquets et scripts
  environment.systemPackages = with pkgs; [
    gamescope
    mangohud
    steam-custom-session

    # LE SCRIPT DE RETOUR AU BUREAU
    (pkgs.writeShellScriptBin "steamos-session-select" ''
      case "$1" in
        *)
          echo "Retour vers le bureau..."
          ${pkgs.steam}/bin/steam -shutdown
          ;;
      esac
    '')
  ];

}
