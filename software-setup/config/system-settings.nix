{ config, lib, pkgs, ... }:

{
  # --- BOOTLOADER & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
  boot.initrd.systemd.enable = true;


  # --- BOOT GRAPHIQUE ---
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };


  # --- ACTIVATION DU SWAP EN RAM COMPRESSEE (sera utilisé en priorité avant le swap sur disque) ---
  zramSwap.enable = true;
  zramSwap.priority = 100;
  zramSwap.memoryPercent = 30; # Utilise jusqu'à 30% de tes 12Go si besoin


  # --- OPTION ADDITIONNELLES FILESYSTEMS ( seront appliquées à tout sous-volume btrfs sauf /swap ---
  fileSystems = lib.mapAttrs (name: fs: {
    options = if (fs.fsType == "btrfs") then
      if (name == "/swap") 
      then [ "noatime" "ssd" ] ++ (fs.options or [])
      else [ "noatime" "compress=zstd" "ssd" "discard=async" ] ++ (fs.options or [])
    else fs.options;
}) config.fileSystems;


  # --- RÉSEAU ---
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Paris";


  # --- LOCALISATION (FR) ---
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
  console.keyMap = "fr";
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };


  # --- MATÉRIEL & SERVICES ---
  services.printing.enable = true;
  services.flatpak.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics = { # Vulkan
    enable = true;
    enable32Bit = true; # Souvent utile pour Steam aussi
  };


  # --- SON (Pipewire) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # --- OPTIMISATION NIX ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true; # évite toute duplcation dans le store en créant des symlinks
}
