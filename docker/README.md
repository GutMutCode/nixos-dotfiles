# All-in-One Home Server

Complete home server setup with containerized services managed by Docker Compose and Traefik.

**📚 For production setup with real domain and SSL, see [DOMAIN-SETUP.md](./DOMAIN-SETUP.md)**
**🔧 Having issues? Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**

## How It Works

This setup uses **NixOS declarative configuration** to manage Docker services:

```
~/nixos-dotfiles/docker/          →  /srv/docker/
├── docker-compose.yml           (symlink)
├── manage.sh                    (symlink, auto-executable)
├── setup.sh                     (symlink, auto-executable)
├── .env.template                (symlink)
├── traefik/
│   ├── docker-compose.yml      (symlink)
│   ├── traefik.yml             (symlink)
│   ├── acme.json               (created by NixOS, 600)
│   └── config/                 (created by NixOS)
└── [other services]/
    └── docker-compose.yml      (symlink)
```

**Key points:**
- Configuration files are symlinked via `modules/services/home-server.nix`
- Changes to files in `~/nixos-dotfiles/docker/` apply immediately
- Runtime files (like `acme.json`) are created automatically with correct permissions
- Scripts get execute permissions automatically

## Services Included

| Service | URL | Description |
|---------|-----|-------------|
| Traefik | `https://traefik.${DOMAIN}` | Reverse proxy and SSL management |
| Cloudflare DDNS | (background) | Dynamic DNS updater for changing IPs |
| Portainer | `https://portainer.${DOMAIN}` | Container management UI |
| Nextcloud | `https://nextcloud.${DOMAIN}` | Personal cloud storage |
| Gitea | `https://gitea.${DOMAIN}` | Git repository hosting |
| Jellyfin | `https://jellyfin.${DOMAIN}` | Media streaming |
| Prometheus | `https://prometheus.${DOMAIN}` | Metrics collection |
| Grafana | `https://grafana.${DOMAIN}` | Monitoring dashboards |
| Home Assistant | `https://home.${DOMAIN}` | Home automation |
| Vaultwarden | `https://vault.${DOMAIN}` | Password manager (Bitwarden) |
| WireGuard | UDP Port 51820 | VPN server |

**All services use HTTPS with automatic SSL certificates via Cloudflare DNS challenge.**

## Initial Setup

### 1. Rebuild NixOS with Docker support

This will automatically create symlinks from `~/nixos-dotfiles/docker/` to `/srv/docker/` via `modules/services/home-server.nix`:

```bash
cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake .#nixos-gmc
```

**What gets symlinked:**
- Root files: `docker-compose.yml`, `manage.sh`, `setup.sh`, `README.md`, `.env.template`
- Service configs: `traefik/docker-compose.yml`, `nextcloud/docker-compose.yml`, etc.
- Runtime files created: `traefik/acme.json` (600), `traefik/config/` (not in git)

**Configuration management:**
- Managed by `systemd.tmpfiles.rules` in `modules/services/home-server.nix`
- Changes to files in `~/nixos-dotfiles/docker/` apply immediately (no rebuild)
- Scripts (`manage.sh`, `setup.sh`) automatically get execute permissions

### 2. Configure environment variables

**⚠️ Important:** The `.env` file is **NOT symlinked** and must be created manually in `/srv/docker/`:

```bash
cd /srv/docker
cp .env.template .env
nano .env  # Edit with your settings
```

**Why not symlinked?**
- Contains secrets (passwords, API tokens)
- Should not be committed to git
- Can optionally be managed with sops-nix (see `modules/services/home-server.nix`)

**Important settings to change:**
- `DOMAIN`: Your domain name (or keep as `local` for testing)
- All passwords (generate strong ones!)
- `TRAEFIK_ADMIN_AUTH`: Generate with `htpasswd -nb admin your_password`
  - **Note:** Avoid `!` in passwords due to bash history expansion issues

### 3. Traefik runtime files

**✅ Already created by NixOS** during rebuild via `modules/services/home-server.nix`:

```nix
traefikRuntimeFiles = [
  "f /srv/docker/traefik/acme.json 0600 gmc users -"
  "d /srv/docker/traefik/config 0755 gmc users -"
];
```

**No manual action needed.** If files are missing, run:
```bash
sudo nixos-rebuild switch --flake .#nixos-gmc
```

### 4. Start all services

```bash
cd /srv/docker
./manage.sh start
```

**Note:** `manage.sh` is automatically executable via `system.activationScripts` in `modules/services/home-server.nix`

## Management Commands

```bash
# Start all services
./manage.sh start

# Stop all services
./manage.sh stop

# Restart all services
./manage.sh restart

# Check service status
./manage.sh status

# View logs for a specific service
./manage.sh logs traefik
./manage.sh logs nextcloud

# Update all services to latest versions
./manage.sh update
```

## Accessing Services

### Production Access (HTTPS with Domain)

**This setup uses Cloudflare DNS challenge for automatic SSL certificates**, so you don't need to expose ports 80/443 directly to the internet.

**Prerequisites:**
1. Domain configured with Cloudflare DNS
2. Cloudflare API token in `.env` (`CF_DNS_API_TOKEN`)
3. Port forwarding or DMZ configured on router (for Traefik)
4. WireGuard VPN for secure remote access

**Access URLs:**
- Traefik: `https://traefik.${DOMAIN}`
- Portainer: `https://portainer.${DOMAIN}`
- Nextcloud: `https://nextcloud.${DOMAIN}`
- And so on...

**Remote Access via VPN:**
For secure remote access, use WireGuard VPN instead of exposing all services:
1. Connect to WireGuard VPN (port 51820)
2. Access services via HTTPS URLs
3. All traffic encrypted through VPN tunnel

### Local Development (Optional)

For testing without domain, add to `/etc/hosts`:
```
<server-ip>  traefik.local portainer.local nextcloud.local
```

Then modify Traefik labels to use `.local` domain instead of `${DOMAIN}`.

## Post-Setup Configuration

### Nextcloud
1. Access `https://nextcloud.${DOMAIN}`
2. Login with credentials from `.env`
3. Install recommended apps (Calendar, Contacts, Tasks)
4. Configure mobile apps for automatic photo backup
5. Configure external storage if needed

### Jellyfin
1. Access `https://jellyfin.${DOMAIN}`
2. Complete initial setup wizard
3. Add media libraries:
   - Edit `docker-compose.yml` to mount your media directories
   - Example: `- /path/to/movies:/media/movies:ro`
4. Enable hardware transcoding in settings (if using NVIDIA GPU)
5. Install Jellyfin mobile apps for streaming

### Gitea
1. Access `https://gitea.${DOMAIN}`
2. Login with credentials from `.env` (auto-configured)
3. Configure SSH (use port 2222):
   ```bash
   git clone ssh://git@${DOMAIN}:2222/username/repo.git
   ```
4. Create repositories and push code

### Grafana
1. Access `https://grafana.${DOMAIN}`
2. Login with credentials from `.env`
3. Add Prometheus data source:
   - URL: `http://prometheus:9090`
   - Access: Server (default)
4. Import dashboards:
   - Node Exporter Full: Dashboard ID 1860
   - Docker Container & Host Metrics: Dashboard ID 893
   - Traefik 2: Dashboard ID 11462

### Vaultwarden (Password Manager)
1. Access `https://vault.${DOMAIN}`
2. Create account with email and strong master password
3. Admin panel: `https://vault.${DOMAIN}/admin`
   - Token from `.env`: `VAULTWARDEN_ADMIN_TOKEN`
4. Install Bitwarden browser extensions and apps:
   - Configure server URL: `https://vault.${DOMAIN}`
   - Login with your account
5. Import passwords from other password managers

### WireGuard VPN
1. Check container logs for QR codes: `docker logs wireguard`
2. Client configs located in Docker volume
3. View configs:
   ```bash
   docker exec wireguard cat /config/peer1/peer1.conf
   docker exec wireguard cat /config/peer2/peer2.conf
   ```
4. Install WireGuard on mobile/desktop and scan QR code or import config
5. Test connection: access services via HTTPS while connected to VPN

### Home Assistant
1. Access `https://home.${DOMAIN}`
2. Create account on first visit
3. Add integrations (Settings → Devices & Services)
4. Connect smart home devices
5. Create automations and dashboards

## Backup Strategy

### Manual Backup

```bash
# Backup all volumes
cd /srv/docker
for service in */; do
  cd "$service"
  docker-compose down
  cd ..
done

# Backup Docker volumes
sudo tar czf docker-volumes-backup-$(date +%Y%m%d).tar.gz /var/lib/docker/volumes/

# Restart services
./manage.sh start
```

### Automated Backup (TODO)

Create a systemd timer for automated backups.

## Security Considerations

1. **Change all default passwords** in `.env`
2. **Enable HTTPS** for production (configure Traefik with real domain)
3. **Use VPN** for remote access instead of exposing all services
4. **Regular updates**: Run `./manage.sh update` weekly
5. **Monitor logs**: Check `./manage.sh logs` for suspicious activity
6. **Backup regularly**: Implement automated backup strategy

## Troubleshooting

### Service won't start
```bash
# Check logs
./manage.sh logs <service-name>

# Check if port is already in use
sudo netstat -tulpn | grep <port>

# Restart specific service
cd /srv/docker/<service-name>
docker-compose down
docker-compose up -d
```

### Can't access services
```bash
# Check if containers are running
docker ps

# Check Traefik dashboard
http://traefik.local:8080

# Verify network
docker network inspect proxy
```

### Out of disk space
```bash
# Clean up unused Docker resources
docker system prune -a --volumes

# Check disk usage
df -h
du -sh /var/lib/docker/*
```

## Updating Services

```bash
# Update single service
cd /srv/docker/<service-name>
docker-compose pull
docker-compose up -d

# Update all services
./manage.sh update
```

## Advanced Configuration

### Custom Traefik Middleware

Create `/srv/docker/traefik/config/middleware.yml`:

```yaml
http:
  middlewares:
    rate-limit:
      rateLimit:
        average: 100
        burst: 50
```

### Adding New Service

**Example: Adding Vaultwarden**

1. **Create service files in repository:**
   ```bash
   mkdir ~/nixos-dotfiles/docker/vaultwarden
   nano ~/nixos-dotfiles/docker/vaultwarden/docker-compose.yml
   ```

2. **Add Traefik labels for HTTPS:**
   ```yaml
   labels:
     - "traefik.enable=true"
     # HTTP router (redirect to HTTPS)
     - "traefik.http.routers.vaultwarden.entrypoints=http"
     - "traefik.http.routers.vaultwarden.rule=Host(`vault.${DOMAIN}`)"
     - "traefik.http.routers.vaultwarden.middlewares=vaultwarden-https-redirect"
     # HTTPS router
     - "traefik.http.routers.vaultwarden-secure.entrypoints=https"
     - "traefik.http.routers.vaultwarden-secure.rule=Host(`vault.${DOMAIN}`)"
     - "traefik.http.routers.vaultwarden-secure.tls=true"
     - "traefik.http.routers.vaultwarden-secure.tls.certresolver=cloudflare"
     - "traefik.http.routers.vaultwarden-secure.service=vaultwarden"
     # Middleware & Service
     - "traefik.http.middlewares.vaultwarden-https-redirect.redirectscheme.scheme=https"
     - "traefik.http.services.vaultwarden.loadbalancer.server.port=80"
     - "traefik.docker.network=proxy"
   ```

3. **Update `modules/services/home-server.nix`:**
   - Add `"vaultwarden"` to `serviceDirectories` array
   - Add symlink rule to `serviceFileLinks`:
     ```nix
     "L+ /srv/docker/vaultwarden/docker-compose.yml - - - - ${dockerConfigPath}/vaultwarden/docker-compose.yml"
     ```

4. **Add environment variables to `/srv/docker/.env`:**
   ```bash
   VAULTWARDEN_ADMIN_TOKEN=<random-token>
   ```

5. **Rebuild NixOS to create symlinks:**
   ```bash
   sudo nixos-rebuild switch --flake .#nixos-gmc
   ```

6. **Start service:**
   ```bash
   cd /srv/docker/vaultwarden
   docker-compose --env-file ../.env up -d
   ```

7. **Verify HTTPS access:**
   ```bash
   curl -I https://vault.${DOMAIN}
   ```

## Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Gitea Documentation](https://docs.gitea.io/)
- [Home Assistant Documentation](https://www.home-assistant.io/docs/)

## Support

Check service-specific logs and documentation for issues.

Common issues:
- Port conflicts: Check firewall and router settings
- SSL certificates: Verify domain DNS and Traefik configuration
- Performance: Monitor with Grafana, increase resources if needed
