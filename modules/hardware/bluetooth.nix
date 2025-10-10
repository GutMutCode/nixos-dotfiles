{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        AutoConnect = true;
        FastConnectable = true;
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = true;

  systemd.user.services.bluetooth-auto-connect = {
    description = "Auto-connect to trusted Bluetooth devices";
    after = [ "bluetooth.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "bluetooth-auto-connect" ''
        sleep 3
        ${pkgs.bluez}/bin/bluetoothctl power on
        sleep 2
        for device in $(${pkgs.bluez}/bin/bluetoothctl devices Trusted | ${pkgs.coreutils}/bin/cut -d' ' -f2); do
          echo "Connecting to trusted device: $device"
          ${pkgs.bluez}/bin/bluetoothctl connect "$device"
        done
      '';
      RemainAfterExit = true;
    };
  };
}
