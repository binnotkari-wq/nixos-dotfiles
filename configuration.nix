{ config, pkgs, ... }:

let
  user_name = "benoit"; # modifiable (faire concorder la valeur dans bootstrap.sh)
  host = "vm"; # modifiable selon la machine (faire concorder la valeur dans bootstrap.sh)
  nixos_release = "25.11"
in

{
  imports = [
    # --- SPECIFICITE MACHINE---
    ./platform_specific/qemu.nix # modifiable selon la machine

    # --- ENVIRONNEMENT LOGICIEL ---
    ./OS/CLI_tools.nix # modifiable
    ./OS/plasma_base.nix # modifiable

    # --- UTILISATEUR ---
    (./. + "/users/${user_name}.nix") # ne pas modififier
    (./. + "/users/${user_name}_settings.nix") # ne pas modififier

    # --- SOCLE COMMUN ---
    (./. + "/hosts/${host}/hardware-configuration.nix") # ne pas modififier
    ./external_modules/impermanence.nix # ne pas modififier
    ./OS/system_settings.nix # ne pas modififier
    ./OS/impermanence-config.nix # ne pas modififier
  ];

  networking.hostName = "${host}"; # ne pas modififier
  system.stateVersion = "${nixos_release}"; # ne pas modififier
}
