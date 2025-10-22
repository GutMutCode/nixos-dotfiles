# All-in-One Home Server

Complete home server setup with containerized services managed by Docker Compose and Traefik.

## Services Included

| Service | URL | Description |
|---------|-----|-------------|
| Traefik | `traefik.local` | Reverse proxy and SSL management |
| Portainer | `portainer.local` | Container management UI |
| Nextcloud | `nextcloud.local` | Personal cloud storage |
| Jellyfin | `jellyfin.local` | Media streaming |
| Gitea | `gitea.local` | Git repository hosting |
| Grafana | `grafana.local` | Monitoring dashboards |
| Prometheus | `prometheus.local` | Metrics collection |
| Home Assistant | `home.local` | Home automation |
| WireGuard | Port 51820 | VPN server |

## Initial Setup

### 1. Rebuild NixOS with Docker support

```bash
cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake .#nixos-gmc
```

### 2. Copy Docker configuration to /srv/docker

```bash
sudo mkdir -p /srv/docker
sudo chown -R gmc:users /srv/docker
cp -r ~/nixos-dotfiles/docker/* /srv/docker/
```

### 3. Configure environment variables

```bash
cd /srv/docker
cp .env.template .env
nano .env  # Edit with your settings
```

**Important settings to change:**
- `DOMAIN`: Your domain name (or keep as `local` for testing)
- All passwords (generate strong ones!)
- `TRAEFIK_ADMIN_AUTH`: Generate with `htpasswd -nb admin your_password`

### 4. Create Traefik acme.json

```bash
cd /srv/docker/traefik
touch acme.json
chmod 600 acme.json
mkdir -p config
```

### 5. Start all services

```bash
cd /srv/docker
chmod +x manage.sh
./manage.sh start
```

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

### Local Access (without domain)

Add to your `/etc/hosts` (or `C:\Windows\System32\drivers\etc\hosts` on Windows):

```
192.168.0.194  traefik.local
192.168.0.194  portainer.local
192.168.0.194  nextcloud.local
192.168.0.194  jellyfin.local
192.168.0.194  gitea.local
192.168.0.194  grafana.local
192.168.0.194  prometheus.local
192.168.0.194  home.local
```

Then access via browser: `http://portainer.local`

### With Domain (Production)

1. Point your domain DNS A records to your server IP
2. Configure port forwarding on your router (80, 443)
3. Update `.env` with your domain
4. Update `traefik.yml` with your email for Let's Encrypt
5. Restart Traefik: `cd /srv/docker/traefik && docker-compose restart`

## Post-Setup Configuration

### Nextcloud
1. Access `http://nextcloud.local`
2. Login with credentials from `.env`
3. Install recommended apps
4. Configure external storage if needed

### Jellyfin
1. Access `http://jellyfin.local`
2. Complete initial setup wizard
3. Add media libraries (update docker-compose.yml to mount your media directories)
4. Enable hardware transcoding in settings (if using NVIDIA GPU)

### Gitea
1. Access `http://gitea.local`
2. Complete installation
3. Create admin account
4. Configure SSH (use port 2222):
   ```bash
   git clone ssh://git@gitea.local:2222/username/repo.git
   ```

### Grafana
1. Access `http://grafana.local`
2. Login with credentials from `.env`
3. Add Prometheus data source: `http://prometheus:9090`
4. Import dashboards:
   - Node Exporter: Dashboard ID 1860
   - Docker: Dashboard ID 893

### WireGuard VPN
1. Check container logs: `./manage.sh logs wireguard`
2. Find QR codes for client configuration in `/srv/docker/wireguard-config`
3. Or copy config files from the same directory

### Home Assistant
1. Access `http://home.local`
2. Create account
3. Configure integrations
4. Add devices

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

1. Create directory: `mkdir /srv/docker/new-service`
2. Create `docker-compose.yml` with Traefik labels
3. Add to `SERVICES` array in `manage.sh`
4. Start: `cd /srv/docker/new-service && docker-compose up -d`

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
