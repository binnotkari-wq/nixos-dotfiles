{ config, pkgs, ... }:

let
  host = "dell-5485"; # modifiable selon la machine (faire concorder la valeur dans install.sh)
  nixos-stable = "25.11"; # modifiable selon la version stable actuelle de Nixos
  # NE RIEN MODIFIER D'AUTRE ET NE RIEN DESACTIVER DANS CE FICHIER
in

{
  imports = [
    ./hosts/${host}.nix # spécificités machine
    ./users/benoit.nix # définition utilisateur
    ./users/benoit_settings.nix # réglages utilisateur
    ./modules/programs/CLI_tools.nix # logiciels supplémentaires interface terminal
    ./modules/programs/plasma_base.nix # KDE
    ./modules/programs/plasma_apps.nix # applications Qt
    ./modules/config/system_settings.nix # réglages sytème (boot, localisation, services ...)
    ./modules/config/impermanence-config.nix # fichier dédié pour la configuration de l'impermanence
    (builtins.fetchTarball { url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";} + "/nixos.nix") # module impermanence à intégrer dans le store
  ];

    # --- IDENTIFICATION SYSTEME ---
  networking.hostName = "${host}";
  system.stateVersion = "${nixos-stable}";
}
