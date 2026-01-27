{ pkgs, ... }:

let

# 1. On définit la session avec les métadonnées exigées par NixOS
  steam-custom-session = pkgs.runCommand "steam-custom-session" {
    passthru.providedSessions = [ "steam-custom" ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat <<EOF > $out/share/wayland-sessions/steam-custom.desktop
    [Desktop Entry]
    Name=Steam Custom (Bluetooth+Perfs)
    Comment=Steam (Gamescope et MangoHud)
    Exec=${pkgs.gamescope}/bin/gamescope --mangoapp -e -- ${pkgs.steam}/bin/steam -steamdeck -steamos3 -gamepadui
    Type=Application
    DesktopNames=gamescope
    EOF
  '';
in

{
  # 2. On dit à SDDM de charger cette session spécifique
  services.displayManager.sessionPackages = [ steam-custom-session ];

  # 3. Le reste de ta config Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false; # on utilise la session custom à la place
    extraPackages = with pkgs; [ mangohud ];
  };

  # 4. On active GameMode (toujours utile)
  programs.gamemode.enable = true;

  # 5. Paquets et scripts
  environment.systemPackages = with pkgs; [
    gamescope
    mangohud
    protonup-qt
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
