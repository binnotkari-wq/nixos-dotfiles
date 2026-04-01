# D'après configuration.nix tel que généré lors d'une installation standard de NixOS par l'installateur graphique
# Calamares, environnement Gnome, unfree Softwares, français. Fonctionnement garanti sur cette base.
# Quelques modifications :
# - suppression de tous les commentaires et déclarations inutilisées.
# - "services.xserver.displayManager.gdm.enable = true;" commenté car externalisé
# - "services.xserver.desktopManager.gnome.enable = true;" commenté car externalisé
# - "services.printing.enable = true;" commenté, car inutilisé
# - "programs.firefox.enable = true;" commenté (on installera un flatpak)

{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
   # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true; # commenté car externalisé
  # services.xserver.desktopManager.gnome.enable = true; # commenté car externalisé

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  # services.printing.enable = true; # inutilisé

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.benoit = {
    isNormalUser = true;
    description = "Benoit";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Install firefox.
  # programs.firefox.enable = true; # sera installé en flatpak

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
