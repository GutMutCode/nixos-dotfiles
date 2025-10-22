{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
    ports = [ 22 ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      80    # HTTP
      443   # HTTPS
      2222  # Gitea SSH
    ];
    allowedUDPPorts = [
      51820 # WireGuard
    ];
  };
}
