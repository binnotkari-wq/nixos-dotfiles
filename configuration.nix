{ config, pkgs, ... }:

let
  user_name = "benoit"; # modifiable (faire concorder la valeur dans bootstrap.sh)
  host = "vm"; # modifiable selon la machine (faire concorder la valeur dans bootstrap.sh)
  nixos_release = "25.11";
in

{
  imports = [
    # --- SPECIFICITE MACHINE---
    ./modules/config/qemu.nix # adapter selon la machine. A utiliser seulement pour une VM, en désactivant tous les modules hardware.
    # ./modules/harware/cpu/CPU_AMD.nix # adapter selon la machine.
    # ./modules/harware/video/APU_AMD.nix # adapter selon la machine.

    # --- ENVIRONNEMENT LOGICIEL ---
    ./modules/programs/CLI_tools.nix # modifiable
    ./modules/programs/plasma_base.nix # modifiable

    # --- UTILISATEUR ---
    ./modules/users/${user_name}.nix # ne pas modififier
    ./modules/users/${user_name}_settings.nix # ne pas modififier

    # --- SOCLE COMMUN ---
    ./modules/hosts/${host}/hardware-configuration.nix # ne pas modififier
    ./modules/config/system_settings.nix # ne pas modififier
    ./modules/config/impermanence-config.nix # ne pas modififier

    # --- MODULE EXTERNE IMPERMANENCE ---
  (builtins.fetchTarball { url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";} + "/nixos.nix") # ne pas modififier
  ];

    # --- IDENTIFICATION SYSTEME ---
  networking.hostName = "${host}"; # ne pas modififier
  system.stateVersion = "${nixos_release}"; # ne pas modififier
}
