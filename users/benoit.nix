{ pkgs, ... }:

{
  users.users.benoit = {
    isNormalUser = true;
    description = "Benoit";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "lp" "scanner" ];
    hashedPassword = "$y$j9T$Mj35eRqiQeZAF3qCODbuX0$x/QwgdyVj5QmuglgOkukZfb5n/SsLklBn.ipr.gy1YC";
  };
}
