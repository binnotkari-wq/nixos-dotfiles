{ pkgs, ... }:

{
  users.users.benoit = {
    isNormalUser = true;
    uid = 1000; # pour s'assurer qu'on sera bien bénéficiaire des droits sur /home dans le cas d'une réinstallation où /home est conservé
    description = "Benoit";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "lp" "scanner" ];
    passwordFile = "/nix/persist/secrets/benoit-password";
  };
}
