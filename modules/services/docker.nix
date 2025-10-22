{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Add user to docker group
  users.users.gmc.extraGroups = [ "docker" ];

  # Install Docker Compose
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # Create directory for docker services
  systemd.tmpfiles.rules = [
    "d /srv/docker 0755 gmc users -"
    "d /srv/docker/data 0755 gmc users -"
    "d /srv/docker/config 0755 gmc users -"
  ];
}
