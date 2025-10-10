{ config, ... }:

{
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 devices=2 video_nr=0,1 card_label="OBS Virtual Camera"
  '';
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
}
