{ config, pkgs, lib, ... }:


# erreur lors du rebuild. Une compilation d'une version cutsom de gamescope, tirée par jovian os, qui ne se passe pas bien
# error: Cannot build '/nix/store/6cnfqi63kra1ch6lzasdii2y6jfmwwx0-gamescope-3.16.24.drv'.
#       Reason: builder failed with exit code 1.
#       Output paths:
#         /nix/store/6k49hp4zy7ckyrs63kiv02s57j05qcnw-gamescope-3.16.24

{

  imports = [
#    (
#      # Put the most recent revision here:
#      let revision = "0.66"; in
#      builtins.fetchTarball {
#        url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
#        # Update the hash as needed: (sha256sum Jovian-NixOS-0.66.tar.gz)
#        sha256 = "sha256:0xh4sdyy5ikg30xkpygv64zfjjsd8az13n20sk1hlck2z9kv9dir";
#      } + "/modules"
#    )
    
    
(
  builtins.fetchGit {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS.git";
    ref = "refs/heads/development";
    rev = "db4a6e75522199a0406adb74c1a5e91e53f9296c";
  } + "/modules"
)
    
    
  ];

  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };

  jovian.hardware.has.amd.gpu = true;
  jovian.steam.enable = true;
  jovian.steam.desktopSession = "gnome";
  jovian.steam.updater.splash = "steamos";              # one of "steamos", "jovian", "bgrt", "vendor" 
  jovian.steam.autoStart = false;
  jovian.devices.steamdeck.autoUpdate = false;          # uniquement sur steamdeck
  jovian.devices.steamdeck.enable = false;              # uniquement sur steamdeck

}
