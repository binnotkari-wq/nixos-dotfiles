{ config, lib, pkgs, ... }:

{

  # --- SECOND SSD ---

  # Montage
  fileSystems."/run/media/benoit/1615eb5d-4346-4106-ba33-dbecf0b75b31" = {
    device = "/dev/disk/by-uuid/1615eb5d-4346-4106-ba33-dbecf0b75b31";
    fsType = "ext4";
    options = [ "users" "nofail" "noatime" ]; # "users" permet aux utilisateurs de monter/démonter
  };

  # Permissions utilisateur sur ce point de montage
  system.activationScripts.fix-mount-permissions = {
    text = ''
      chown -R benoit:users /run/media/benoit/1615eb5d-4346-4106-ba33-dbecf0b75b31
    '';
  };


}
