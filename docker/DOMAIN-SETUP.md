# Production Domain Setup Guide

Complete guide for setting up the home server with a real domain and SSL certificates.

## Table of Contents

- [Prerequisites](#prerequisites)
- [DNS Configuration](#dns-configuration)
- [Public IP and DDNS](#public-ip-and-ddns)
- [Router Port Forwarding](#router-port-forwarding)
- [NixOS Firewall](#nixos-firewall)
- [Configuration Files](#configuration-files)
- [System Rebuild and Service Start](#system-rebuild-and-service-start)
- [Access Testing](#access-testing)
- [Troubleshooting](#troubleshooting)
- [Security Recommendations](#security-recommendations)

## Prerequisites

Before starting, ensure you have:

1. **Domain Name**: Purchased from registrar (GoDaddy, Namecheap, Cloudflare, etc.)
2. **Public IP Address**: From ISP or DDNS service
3. **Router Admin Access**: To configure port forwarding
4. **Server Local IP**: `192.168.0.194` (check with `ip -4 addr show`)

## DNS Configuration

### Option 1: Cloudflare (Recommended)

Cloudflare provides free SSL certificates, DDoS protection, and DNS management.

#### Step 1: Add Domain to Cloudflare

1. Create Cloudflare account at https://cloudflare.com
2. Add your domain
3. Update nameservers at your domain registrar to Cloudflare's nameservers

#### Step 2: Create DNS A Records

Add the following DNS records in Cloudflare Dashboard:

```
Type: A
Name: @
Content: [Your Public IP]
Proxy status: DNS only (Free) or Proxied (Pro Use)
TTL: Auto
```

```
Type: A
Name: *
Content: [Your Public IP]
Proxy status: DNS only
TTL: Auto
```

#### Step 3: Generate API Token for DNS Challenge

Required for automatic SSL certificate issuance:

1. Go to Cloudflare Dashboard → Profile → API Tokens
2. Click "Create Token"
3. Use "Edit zone DNS" template
4. Set Zone Resources: Include → Specific zone → Your domain
5. Click "Continue to summary" → "Create Token"
6. Copy the token (save it for `.env` file)

### Option 2: Generic DNS Provider

If not using Cloudflare, manually add A records for each service:

```
Host: @           → Your Public IP
Host: *           → Your Public IP
Host: traefik     → Your Public IP
Host: portainer   → Your Public IP
Host: nextcloud   → Your Public IP
Host: jellyfin    → Your Public IP
Host: gitea       → Your Public IP
Host: grafana     → Your Public IP
Host: prometheus  → Your Public IP
Host: home        → Your Public IP
```

Note: Without Cloudflare DNS challenge, you'll need HTTP challenge (requires port 80 accessible).

## Public IP and DDNS

### Check Your Public IP

```bash
curl ifconfig.me
# or
curl ipinfo.io/ip
```

### Dynamic DNS (Automatic with Docker)

**✅ Cloudflare DDNS is included and automatic!**

If your ISP assigns dynamic IP addresses (most home internet), the included `cloudflare-ddns` service will:

- ✅ Automatically detect your public IP every 5 minutes
- ✅ Update Cloudflare DNS records when IP changes
- ✅ Update both root domain (@) and wildcard (*) records
- ✅ Use the same `CF_DNS_API_TOKEN` from your `.env` file

**No additional configuration needed** - it starts automatically with `./manage.sh start`

**Check DDNS status:**

```bash
# View DDNS logs
./manage.sh logs cloudflare-ddns

# Check if running
docker ps | grep cloudflare-ddns
```

**Alternative DDNS Services** (if not using Cloudflare):

- **DuckDNS** (free): Visit https://www.duckdns.org, use subdomain like `myhome.duckdns.org`
- **No-IP** (free/paid): Visit https://www.noip.com, install Dynamic Update Client

## Router Port Forwarding

Configure port forwarding in your router admin panel:

### Required Port Forwards

| External Port | Internal IP:Port    | Protocol | Service          |
| ------------- | ------------------- | -------- | ---------------- |
| 80            | 192.168.0.194:80    | TCP      | HTTP             |
| 443           | 192.168.0.194:443   | TCP      | HTTPS            |
| 51820         | 192.168.0.194:51820 | UDP      | WireGuard VPN    |
| 2222          | 192.168.0.194:2222  | TCP      | Gitea SSH (opt.) |

### Router Configuration Steps

1. Access router admin panel (usually `192.168.0.1` or `192.168.1.1`)
2. Find "Port Forwarding" or "Virtual Server" section
3. Add rules for each port listed above
4. Save and apply settings

### Verify Port Forwarding

Test from external network:

- Use https://www.yougetsignal.com/tools/open-ports/
- Or test with smartphone on cellular data

## NixOS Firewall

The firewall is already configured in `modules/services/ssh.nix`:

```nix
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
```

No action needed - this is declaratively managed by NixOS.

## Configuration Files

### 1. Update Traefik Email

Edit `~/nixos-dotfiles/docker/traefik/traefik.yml`:

```yaml
certificatesResolvers:
  cloudflare:
    acme:
      email: your-actual-email@example.com # ← Change this
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
```

### 2. Configure Environment Variables

After system rebuild, create `/srv/docker/.env`:

```bash
cd /srv/docker
cp .env.template .env
nano .env
```

**Required Changes:**

```bash
# Your actual domain
DOMAIN=yourdomain.com

# Cloudflare API token (from DNS setup)
CF_DNS_API_TOKEN=your_cloudflare_api_token_here

# Traefik dashboard authentication
# Generate with: docker run --rm httpd:2.4-alpine htpasswd -nb admin your_password
# Remember to escape $ as $$ in .env file
TRAEFIK_ADMIN_AUTH=admin:$$apr1$$xyz123$$abc456

# Nextcloud credentials
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=strong_password_here
POSTGRES_PASSWORD=different_strong_password
POSTGRES_DB=nextcloud
POSTGRES_USER=nextcloud

# Gitea credentials
GITEA_ADMIN_USER=admin
GITEA_ADMIN_PASSWORD=strong_password_here
GITEA_ADMIN_EMAIL=admin@yourdomain.com

# Grafana credentials
GRAFANA_ADMIN_PASSWORD=strong_password_here

# WireGuard VPN
WIREGUARD_PEERS=2
WIREGUARD_SERVERPORT=51820

# Timezone
TZ=Asia/Seoul
```

**Generate Strong Passwords:**

```bash
# Option 1: Using /dev/urandom
tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 20; echo

# Option 2: Using Docker
docker run --rm alpine sh -c "cat /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c 20"
```

**Generate Traefik Auth Hash:**

```bash
# Run this command
docker run --rm httpd:2.4-alpine htpasswd -nb admin your_password

# Output example:
# admin:$apr1$abc123$def456

# In .env file, escape $ as $$:
TRAEFIK_ADMIN_AUTH=admin:$$apr1$$abc123$$def456
```

### 3. Prepare Traefik SSL Storage

```bash
cd /srv/docker/traefik
touch acme.json
chmod 600 acme.json
mkdir -p config
```

## System Rebuild and Service Start

### 1. Rebuild NixOS

Apply the declarative configuration:

```bash
cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake .#nixos-gmc
```

This will:

- Create symlinks from `docker/` to `/srv/docker/`
- Apply firewall rules
- Enable Docker service

### 2. Create Docker Network

```bash
docker network create proxy
```

### 3. Start All Services

```bash
cd /srv/docker
chmod +x manage.sh setup.sh
./manage.sh start
```

### 4. Monitor Logs

```bash
# Watch Traefik SSL certificate issuance
./manage.sh logs traefik

# Check specific service
./manage.sh logs nextcloud
./manage.sh logs gitea
```

## Access Testing

### Service URLs

Replace `example.com` with your actual domain:

| Service        | URL                            | Credentials             |
| -------------- | ------------------------------ | ----------------------- |
| Traefik        | https://traefik.example.com    | From TRAEFIK_ADMIN_AUTH |
| Portainer      | https://portainer.example.com  | Create on first visit   |
| Nextcloud      | https://nextcloud.example.com  | From .env               |
| Jellyfin       | https://jellyfin.example.com   | Create on first visit   |
| Gitea          | https://gitea.example.com      | Complete setup wizard   |
| Grafana        | https://grafana.example.com    | From .env               |
| Prometheus     | https://prometheus.example.com | No auth (internal)      |
| Home Assistant | https://home.example.com       | Create on first visit   |

### SSL Certificate Verification

1. Access any service URL in browser
2. Click the lock icon in address bar
3. Verify certificate is from "Let's Encrypt"
4. Check expiry date (should be ~90 days from now)

### External Access Test

Test from outside your network:

- Use smartphone on cellular data (not WiFi)
- Or use online tools: https://www.whatsmydns.net/

## Troubleshooting

### SSL Certificate Not Issued

**Symptoms:**

- Browser shows "SSL Error" or "Certificate Invalid"
- Traefik logs show ACME errors

**Solutions:**

```bash
# Check Traefik logs for errors
docker logs traefik

# Verify acme.json has content
cat /srv/docker/traefik/acme.json

# Reset and retry
cd /srv/docker/traefik
docker-compose down
rm acme.json
touch acme.json
chmod 600 acme.json
docker-compose up -d

# Watch logs
docker logs -f traefik
```

**Common Issues:**

1. **DNS not propagated**: Wait 5-60 minutes after DNS changes
2. **Cloudflare API token invalid**: Regenerate token with correct permissions
3. **Port 80/443 blocked**: Check router port forwarding and ISP restrictions
4. **Email invalid**: Update `traefik.yml` with valid email address

### DNS Propagation Check

```bash
# Check if DNS records are resolving
nslookup yourdomain.com
nslookup traefik.yourdomain.com

# Check from multiple locations
# Visit https://www.whatsmydns.net/
```

### Cloudflare API Token Verification

```bash
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type:application/json"
```

Expected response:

```json
{
  "success": true,
  "messages": [],
  "result": {
    "status": "active"
  }
}
```

### Service Not Accessible

**Check service status:**

```bash
docker ps
./manage.sh status
```

**Check Traefik dashboard:**

```
https://traefik.yourdomain.com
```

- Verify routers are listed
- Check if backends are healthy

**Verify Docker network:**

```bash
docker network inspect proxy
```

### Port Forwarding Not Working

**Test from external network:**

```bash
# Use online tool
https://www.yougetsignal.com/tools/open-ports/

# Or from external server
nc -zv your_public_ip 443
```

**Common Issues:**

1. Double NAT (ISP router + your router)
2. ISP blocks residential servers
3. Router firewall separate from port forwarding rules

### WireGuard VPN Issues

**Check WireGuard logs:**

```bash
./manage.sh logs wireguard
```

**Get client configs:**

```bash
# QR codes and configs are in:
ls -la /srv/docker/wireguard-config/
```

## Security Recommendations

### 1. Use VPN for Sensitive Services

Configure Traefik middleware to restrict access:

Create `/srv/docker/traefik/config/vpn-only.yml`:

```yaml
http:
  middlewares:
    vpn-only:
      ipWhiteList:
        sourceRange:
          - "10.13.13.0/24" # WireGuard network
          - "192.168.0.0/24" # Local network
```

Apply to sensitive services in their docker-compose.yml:

```yaml
- "traefik.http.routers.portainer.middlewares=vpn-only@file"
```

### 2. Enable Cloudflare Proxy

In Cloudflare DNS settings:

- Toggle proxy status to "Proxied" (orange cloud)
- This hides your real IP address
- Provides DDoS protection

### 3. Strong Passwords

Use unique, strong passwords for each service:

- Minimum 20 characters
- Mix of letters, numbers, symbols
- Never reuse passwords

### 4. Regular Updates

```bash
# Weekly updates
cd /srv/docker
./manage.sh update
```

### 5. Enable Fail2Ban (Optional)

Add to NixOS configuration for SSH protection:

```nix
services.fail2ban = {
  enable = true;
  maxretry = 3;
  bantime = "24h";
};
```

### 6. Backup Strategy

**Critical data locations:**

```
/srv/docker/nextcloud-data/
/srv/docker/gitea-data/
/srv/docker/jellyfin-config/
/var/lib/docker/volumes/
```

**Automated backup script:**

```bash
#!/usr/bin/env bash
# Save as /root/backup-docker.sh

BACKUP_DIR="/backup/docker-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Stop services
cd /srv/docker
./manage.sh stop

# Backup volumes
tar czf "$BACKUP_DIR/docker-volumes.tar.gz" /var/lib/docker/volumes/

# Backup configs
tar czf "$BACKUP_DIR/docker-configs.tar.gz" /srv/docker/

# Restart services
./manage.sh start

# Keep only last 7 days
find /backup -name "docker-*" -mtime +7 -delete
```

### 7. Monitoring

Configure alerts in Grafana:

1. Access https://grafana.yourdomain.com
2. Add Prometheus data source: `http://prometheus:9090`
3. Import dashboards:
   - Node Exporter: Dashboard ID 1860
   - Docker: Dashboard ID 893
4. Set up alert notifications (email, Slack, etc.)

### 8. Rate Limiting

Add to `/srv/docker/traefik/config/middleware.yml`:

```yaml
http:
  middlewares:
    rate-limit:
      rateLimit:
        average: 100
        burst: 50
```

Apply to routers:

```yaml
- "traefik.http.routers.service.middlewares=rate-limit@file"
```

## Summary

### Changes Made

- ✅ `docker/traefik/docker-compose.yml`: Uses `${DOMAIN}` environment variable
- ✅ `modules/services/ssh.nix`: Firewall rules pre-configured
- ✅ `docker/traefik/traefik.yml`: Cloudflare DNS challenge ready

### Deployment Checklist

- [ ] Domain purchased and DNS configured
- [ ] Public IP identified or DDNS configured
- [ ] Router port forwarding configured
- [ ] `docker/traefik/traefik.yml` email updated
- [ ] `/srv/docker/.env` created and configured
- [ ] NixOS rebuilt: `sudo nixos-rebuild switch`
- [ ] Docker network created: `docker network create proxy`
- [ ] acme.json created with correct permissions
- [ ] Services started: `./manage.sh start`
- [ ] SSL certificates verified
- [ ] External access tested
- [ ] VPN configured for remote access
- [ ] Backups configured

### Next Steps

1. Complete initial setup wizards for each service
2. Configure regular backups
3. Set up monitoring alerts
4. Document your specific configuration
5. Test disaster recovery procedures

## Additional Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Cloudflare DNS API](https://developers.cloudflare.com/api/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)

## Support

For issues specific to this setup:

1. Check Traefik logs: `./manage.sh logs traefik`
2. Verify DNS propagation
3. Test port forwarding from external network
4. Review [Troubleshooting](#troubleshooting) section

For service-specific issues, refer to their official documentation.
