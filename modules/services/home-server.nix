{ config, pkgs, lib, ... }:

let
  # Path to docker configurations in dotfiles
  dockerConfigPath = "${config.users.users.gmc.home}/nixos-dotfiles/docker";

  # Service directories that need to be created
  serviceDirectories = [
    "traefik"
    "portainer"
    "nextcloud"
    "jellyfin"
    "gitea"
    "monitoring"
    "wireguard"
    "home-assistant"
    "cloudflare-ddns"
    "vaultwarden"
  ];

  # Generate directory creation rules
  mkServiceDirRules = map (dir: "d /srv/docker/${dir} 0755 gmc users -") serviceDirectories;

  # Generate symlink rules for root files
  rootFiles = [
    "docker-compose.yml"
    "manage.sh"
    "setup.sh"
    "README.md"
    ".env.template"
  ];
  mkRootFileLinks = map (file:
    "L+ /srv/docker/${file} - - - - ${dockerConfigPath}/${file}"
  ) rootFiles;

  # Traefik runtime files (not in git, created by system)
  traefikRuntimeFiles = [
    "f /srv/docker/traefik/acme.json 0600 gmc users -"
    "d /srv/docker/traefik/config 0755 gmc users -"
  ];

  # Generate symlink rules for service-specific files
  serviceFileLinks = [
    "L+ /srv/docker/traefik/docker-compose.yml - - - - ${dockerConfigPath}/traefik/docker-compose.yml"
    "L+ /srv/docker/traefik/traefik.yml - - - - ${dockerConfigPath}/traefik/traefik.yml"
    "L+ /srv/docker/portainer/docker-compose.yml - - - - ${dockerConfigPath}/portainer/docker-compose.yml"
    "L+ /srv/docker/nextcloud/docker-compose.yml - - - - ${dockerConfigPath}/nextcloud/docker-compose.yml"
    "L+ /srv/docker/jellyfin/docker-compose.yml - - - - ${dockerConfigPath}/jellyfin/docker-compose.yml"
    "L+ /srv/docker/gitea/docker-compose.yml - - - - ${dockerConfigPath}/gitea/docker-compose.yml"
    "L+ /srv/docker/monitoring/docker-compose.yml - - - - ${dockerConfigPath}/monitoring/docker-compose.yml"
    "L+ /srv/docker/monitoring/prometheus.yml - - - - ${dockerConfigPath}/monitoring/prometheus.yml"
    "L+ /srv/docker/wireguard/docker-compose.yml - - - - ${dockerConfigPath}/wireguard/docker-compose.yml"
    "L+ /srv/docker/home-assistant/docker-compose.yml - - - - ${dockerConfigPath}/home-assistant/docker-compose.yml"
    "L+ /srv/docker/cloudflare-ddns/docker-compose.yml - - - - ${dockerConfigPath}/cloudflare-ddns/docker-compose.yml"
    "L+ /srv/docker/vaultwarden/docker-compose.yml - - - - ${dockerConfigPath}/vaultwarden/docker-compose.yml"
  ];
in
{
  # Create service directories and symlink configuration files
  # Using systemd.tmpfiles.rules for declarative directory and symlink management
  # Pattern matches modules/home/xdg.nix symlink approach
  systemd.tmpfiles.rules = mkServiceDirRules ++ mkRootFileLinks ++ serviceFileLinks ++ traefikRuntimeFiles;

  # Make manage.sh and setup.sh executable
  system.activationScripts.makeHomeServerScriptsExecutable = lib.stringAfter [ "etc" ] ''
    chmod +x /srv/docker/manage.sh 2>/dev/null || true
    chmod +x /srv/docker/setup.sh 2>/dev/null || true
  '';

  # Optional: Manage .env file with sops-nix
  # Uncomment and configure secrets/home-server-env.yaml to use
  # sops.secrets.home-server-env = {
  #   sopsFile = ../secrets/home-server-env.yaml;
  #   path = "/srv/docker/.env";
  #   owner = "gmc";
  #   group = "users";
  #   mode = "0600";
  # };
}
