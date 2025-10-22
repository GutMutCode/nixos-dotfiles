# Practical Use Cases for Home Server

This guide demonstrates popular and practical workflows using the deployed services.

## Table of Contents

1. [Personal Cloud & Auto Backup](#1-personal-cloud--auto-backup)
2. [Personal Netflix Setup](#2-personal-netflix-setup)
3. [Unified Password & Security Management](#3-unified-password--security-management)
4. [Smart Home Automation](#4-smart-home-automation)
5. [Developer Workflow](#5-developer-workflow)
6. [Combined Scenario: Digital Nomad Life](#combined-scenario-digital-nomad-life)

---

## 1. 📱 Personal Cloud & Auto Backup

**Services Used**: Nextcloud + WireGuard VPN

### Setup Steps

1. **Install Nextcloud mobile app**
   - Android: [Google Play](https://play.google.com/store/apps/details?id=com.nextcloud.client)
   - iOS: [App Store](https://apps.apple.com/app/nextcloud/id1125420102)

2. **Configure auto-upload**
   ```
   Settings → Auto Upload
   ├── Enable Auto Upload
   ├── Source: Camera folder
   ├── Upload path: /Photos/Mobile
   └── Upload via: WiFi + Mobile data
   ```

3. **Desktop sync**
   - Install [Nextcloud Desktop Client](https://nextcloud.com/install/#install-clients)
   - Connect to: `https://nextcloud.${DOMAIN}`
   - Select folders to sync

4. **Remote access**
   - Connect to WireGuard VPN when outside home network
   - Access Nextcloud seamlessly

### Benefits

- **Cost savings**: Replace Google Photos ($20/year for 100GB → Unlimited free)
- **Complete privacy**: Your data never touches third-party servers
- **Original quality**: No compression or quality loss
- **Easy sharing**: Generate public/password-protected links
- **Cross-platform**: Automatic sync between all devices

### Real-world Applications

- **Travel**: Auto-backup vacation photos from phone
- **Documents**: Store important PDFs, contracts, certificates
- **Family**: Share photos with family members
- **Work**: Collaborate on documents with colleagues
- **Organization**: Clean up old phone photos by moving to archive

### Advanced Features

```bash
# Automatic backup script (add to crontab)
rsync -av /important/files/ user@server:/nextcloud/data/Backups/

# Desktop integration
- Right-click any file → Share via Nextcloud
- Automatic sync when file changes
- Version history for all files
```

---

## 2. 🎬 Personal Netflix Setup

**Services Used**: Jellyfin + WireGuard VPN

### Setup Steps

1. **Add media directories**

   Edit `docker/jellyfin/docker-compose.yml`:
   ```yaml
   volumes:
     - jellyfin-config:/config
     - jellyfin-cache:/cache
     - /media/movies:/media/movies:ro
     - /media/tv:/media/tv:ro
     - /media/music:/media/music:ro
   ```

2. **Organize your media**
   ```
   /media/
   ├── movies/
   │   ├── The Matrix (1999)/
   │   │   └── The Matrix (1999).mkv
   │   └── Inception (2010)/
   │       └── Inception (2010).mkv
   ├── tv/
   │   └── Breaking Bad/
   │       ├── Season 01/
   │       │   ├── S01E01.mkv
   │       │   └── S01E02.mkv
   │       └── Season 02/
   │           └── ...
   └── music/
       └── Artist Name/
           └── Album Name/
               └── 01 - Track.mp3
   ```

3. **Add libraries in Jellyfin**
   ```
   Dashboard → Libraries → Add Library
   ├── Content type: Movies/TV Shows/Music
   ├── Folder: /media/movies (or tv, music)
   └── Enable: Metadata downloaders
   ```

4. **Install client apps**
   - **Android/iOS**: Search "Jellyfin" in app stores
   - **Android TV/Fire TV**: Install Jellyfin app
   - **Smart TV**: Use web browser or cast from mobile
   - **Desktop**: Use browser or native app

5. **Configure remote streaming**
   - Connect to WireGuard VPN
   - Open Jellyfin app
   - Stream anywhere with internet

### Benefits

- **No subscriptions**: One-time setup, lifetime access
- **Permanent ownership**: Content never disappears
- **Unlimited accounts**: Share with family at no extra cost
- **Watch history sync**: Continue on any device
- **Offline downloads**: Download before travel
- **No geo-restrictions**: Your content, your rules

### Real-world Applications

- **Family videos**: Stream home movies and memories
- **Language learning**: Store educational videos
- **Audiobooks**: Listen to audiobook collection
- **Music library**: Personal Spotify alternative
- **Podcasts**: Organize and stream podcast archives

### Advanced Features

```yaml
# Hardware transcoding (NVIDIA GPU)
services:
  jellyfin:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

**Quality settings**:
- 4K streaming at home (no bandwidth limits)
- Auto-adjust quality on mobile data
- Subtitle support for multiple languages

---

## 3. 🔐 Unified Password & Security Management

**Services Used**: Vaultwarden + WireGuard VPN

### Setup Steps

1. **Create master account**
   - Visit `https://vault.${DOMAIN}`
   - Create account with strong master password
   - **IMPORTANT**: Never forget this password!

2. **Install browser extensions**
   - [Chrome/Edge/Brave](https://chrome.google.com/webstore/detail/bitwarden/nngceckbapebfimnlniiiahkandclblb)
   - [Firefox](https://addons.mozilla.org/firefox/addon/bitwarden-password-manager/)
   - Configure server: `https://vault.${DOMAIN}`

3. **Install mobile apps**
   - [Android](https://play.google.com/store/apps/details?id=com.x8bit.bitwarden)
   - [iOS](https://apps.apple.com/app/bitwarden-password-manager/id1137397744)
   - Enable auto-fill in system settings

4. **Migrate existing passwords**
   ```
   Settings → Tools → Import Data
   ├── Select format: Chrome/Firefox/1Password/LastPass
   └── Upload exported file
   ```

5. **Setup 2FA (TOTP)**
   - Add websites with 2FA codes
   - Vaultwarden auto-fills both password and TOTP
   - No separate authenticator app needed

### Benefits

- **Cost savings**: $10/month subscription → Free forever
- **Unlimited devices**: No device limit restrictions
- **Unlimited storage**: 1GB file attachments
- **Self-hosted security**: Complete control over data
- **No breach risk**: Data never on third-party servers
- **Family sharing**: Unlimited shared collections

### Real-world Applications

**Personal Security**:
```
✓ Banking credentials
✓ Credit card information
✓ Passport/ID scans
✓ SSH private keys
✓ API tokens
✓ Software licenses
✓ Wi-Fi passwords
```

**Family Sharing**:
```
Shared Collection: "Family Accounts"
├── Netflix: user@email.com / password
├── Spotify: shared@email.com / password
├── Disney+: family@email.com / password
└── Internet Router: admin / password
```

**Work/Development**:
```
Folder: "Development"
├── GitHub Personal Access Token
├── AWS API Keys
├── Database credentials
├── Server SSH keys
└── API documentation links
```

### Advanced Features

**Password Generator**:
```
Length: 20 characters
☑ Uppercase (A-Z)
☑ Lowercase (a-z)
☑ Numbers (0-9)
☑ Special (!@#$%)
☐ Avoid ambiguous (l, 1, O, 0)
```

**Security Reports**:
- Exposed passwords (data breach check)
- Weak passwords (strength analysis)
- Reused passwords (duplicate detection)
- Inactive 2FA (where 2FA available but not enabled)

**Emergency Access**:
```
Grant trusted contact emergency access
→ They can request access
→ After 7 days (configurable), auto-granted
→ Use for account recovery
```

---

## 4. 🏠 Smart Home Automation

**Services Used**: Home Assistant + Grafana + WireGuard

### Setup Steps

1. **Access Home Assistant**
   - Visit `https://home.${DOMAIN}`
   - Create account on first visit

2. **Add integrations**
   ```
   Settings → Devices & Services → Add Integration

   Popular integrations:
   ├── Philips Hue (lights)
   ├── TP-Link Kasa (smart plugs)
   ├── Xiaomi Mi Home (sensors)
   ├── Google Cast (Chromecast)
   ├── MQTT (DIY devices)
   └── Zigbee (via USB dongle)
   ```

3. **Create automations**

**Example 1: Arrive Home**
```yaml
alias: "Arrive Home"
trigger:
  - platform: zone
    entity_id: person.user
    zone: zone.home
    event: enter
action:
  - service: light.turn_on
    target:
      entity_id: light.living_room
  - service: climate.set_temperature
    target:
      entity_id: climate.ac
    data:
      temperature: 24
```

**Example 2: Energy Saving**
```yaml
alias: "Nobody Home - Turn Off Everything"
trigger:
  - platform: state
    entity_id: group.all_persons
    to: "not_home"
    for: "00:30:00"
action:
  - service: light.turn_off
    target:
      entity_id: all
  - service: climate.turn_off
    target:
      entity_id: all
```

**Example 3: Morning Routine**
```yaml
alias: "Morning Routine"
trigger:
  - platform: time
    at: "07:00:00"
condition:
  - condition: state
    entity_id: binary_sensor.workday
    state: "on"
action:
  - service: light.turn_on
    target:
      entity_id: light.bedroom
    data:
      brightness: 50
  - service: media_player.play_media
    target:
      entity_id: media_player.bedroom_speaker
    data:
      media_content_id: "radio_url"
      media_content_type: "music"
```

4. **Monitor with Grafana**
   - Create dashboard for energy usage
   - Track temperature/humidity trends
   - Visualize automation triggers

### Benefits

- **No subscription**: Google Home/Alexa alternatives are free
- **Privacy**: No voice recordings sent to cloud
- **Flexibility**: Support 1000+ device types
- **Customization**: Unlimited automation possibilities
- **Local control**: Works without internet

### Real-world Applications

**Energy Management**:
```
Monitor & optimize:
├── Track total power consumption
├── Identify power-hungry devices
├── Auto-turn-off unused devices
└── Schedule heavy tasks (washing) at night
```

**Security**:
```
When away from home:
├── Turn on lights randomly (simulate presence)
├── Monitor door/window sensors
├── Get notifications on motion detection
└── View security cameras remotely
```

**Comfort Automation**:
```
Smart climate control:
├── Pre-heat/cool before arrival
├── Adjust based on weather forecast
├── Different temperatures for day/night
└── Humidity control (mold prevention)
```

### Advanced Features

**Voice Control**:
```bash
# Integrate with voice assistants
Home Assistant Cloud (Nabu Casa)
or
Local voice with Rhasspy/Mycroft
```

**Presence Detection**:
```yaml
# Multiple methods
- Smartphone WiFi
- Bluetooth beacons
- GPS location
- Router device tracker
```

**Dashboard Example**:
```yaml
views:
  - title: Home
    cards:
      - type: weather-forecast
      - type: entities
        entities:
          - light.living_room
          - climate.ac
          - sensor.temperature
      - type: history-graph
        entities:
          - sensor.power_consumption
```

---

## 5. 💻 Developer Workflow

**Services Used**: Gitea + Nextcloud + Grafana + Portainer

### Setup Steps

1. **Create repository in Gitea**
   ```bash
   # Via web UI
   https://gitea.${DOMAIN} → New Repository

   # Clone to local
   git clone https://gitea.${DOMAIN}/username/project.git
   cd project
   ```

2. **Setup development environment**
   ```yaml
   # docker-compose.dev.yml
   version: '3.8'
   services:
     app:
       build: .
       ports:
         - "3000:3000"
       volumes:
         - .:/app
       environment:
         - NODE_ENV=development

     db:
       image: postgres:16
       environment:
         - POSTGRES_PASSWORD=devpass
   ```

3. **Deploy with Portainer**
   ```
   Portainer → Stacks → Add Stack
   ├── Name: my-project-dev
   ├── Repository: https://gitea.${DOMAIN}/user/project
   └── Compose path: docker-compose.dev.yml
   ```

4. **Setup monitoring**
   ```yaml
   # Add to docker-compose.yml
   labels:
     - "prometheus.scrape=true"
     - "prometheus.port=8080"
     - "prometheus.path=/metrics"
   ```

5. **Create Grafana dashboard**
   ```
   Dashboard for:
   ├── API response times
   ├── Error rates
   ├── Request count
   └── Database query performance
   ```

### Benefits

- **GitHub alternative**: Unlimited private repos (no cost)
- **CI/CD ready**: Built-in Actions (Gitea Actions)
- **Container-based**: Consistent dev environments
- **Real-time monitoring**: Track app performance
- **Team collaboration**: Code review, issues, wiki

### Real-world Applications

**Personal Projects**:
```bash
# 1. Start new project
mkdir my-app && cd my-app
git init
git remote add origin https://gitea.${DOMAIN}/gmc/my-app.git

# 2. Setup environment
docker-compose up -d

# 3. Develop with hot-reload
npm run dev

# 4. Monitor in Grafana
# Watch logs in Portainer
```

**Team Collaboration**:
```
Project workflow:
├── Create feature branch
├── Push to Gitea
├── Open Pull Request
├── Code review & discussion
├── Merge to main
└── Auto-deploy via webhook
```

**Documentation**:
```
Store in Nextcloud:
├── Design files (Figma exports)
├── API documentation
├── Architecture diagrams
├── Meeting notes
└── Screenshots
```

### Advanced Features

**CI/CD Pipeline**:
```yaml
# .gitea/workflows/deploy.yml
name: Deploy to Production
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t app:latest .
      - name: Deploy to Portainer
        run: |
          curl -X POST portainer-webhook-url
```

**Performance Monitoring Dashboard**:
```
Grafana panels:
├── Request rate (requests/sec)
├── Response time (p50, p95, p99)
├── Error rate (% errors)
├── Active connections
├── Memory usage
└── CPU usage
```

**Development Tools**:
```bash
# Code-server (VS Code in browser)
docker run -d \
  -p 8080:8080 \
  -v "$PWD:/workspace" \
  codercom/code-server

# Access via: https://code.${DOMAIN}
```

**Database Management**:
```yaml
# Add Adminer for database GUI
services:
  adminer:
    image: adminer
    ports:
      - 8081:8080
```

---

## Combined Scenario: Digital Nomad Life

**Full-day workflow using all services**

### Morning (8:00 AM)

```
📍 Location: Coffee shop in Tokyo

1. Connect to WireGuard VPN
   └── Secure connection to home server

2. Open Nextcloud
   ├── Download today's presentation slides
   └── Sync latest project files

3. Check Grafana
   └── Verify all services healthy
   └── Review last night's server metrics
```

### Midday (12:00 PM)

```
📍 Location: Co-working space

4. Development work
   ├── git push to Gitea
   ├── Deploy test version via Portainer
   └── Monitor API performance in Grafana

5. Access Vaultwarden
   ├── Get client VPN credentials
   └── Copy API keys for integration
```

### Afternoon (3:00 PM)

```
📍 Location: Client meeting

6. Share files via Nextcloud
   ├── Generate public link for proposal
   └── Set 7-day expiration

7. Receive payment
   └── Save invoice to Nextcloud/Documents/2025/Invoices
```

### Evening (7:00 PM)

```
📍 Location: Hotel room

8. Entertainment
   ├── Stream movie on Jellyfin
   └── Catch up on TV shows

9. Control home remotely
   ├── Check Home Assistant
   ├── Turn on porch light
   └── Adjust AC temperature
```

### Night (11:00 PM)

```
📍 Location: Hotel room

10. Final checks
    ├── Portainer: Review container status
    ├── Grafana: Check daily metrics
    ├── Nextcloud: Upload today's photos
    └── Vaultwarden: Save new client passwords

11. Disconnect VPN
    └── All data synced and secured
```

### Benefits of This Workflow

- **Single VPN connection** for everything
- **No monthly subscriptions** (only VPN data)
- **Complete privacy** (no cloud dependencies)
- **Work anywhere** with internet
- **Seamless sync** across all devices
- **Professional setup** on personal hardware

### Monthly Cost Comparison

**Traditional Cloud Services**:
```
Google Workspace:     $12/month
GitHub Pro:           $4/month
1Password:            $5/month
Netflix:              $15/month
Spotify:              $10/month
Dropbox:              $12/month
─────────────────────────────
Total:                $58/month = $696/year
```

**Self-hosted Setup**:
```
Electricity (~100W):  $5/month
Internet bandwidth:   $0 (existing)
Hardware (one-time):  $500 (amortized: ~$14/month over 3 years)
─────────────────────────────
Total:                $19/month = $228/year

Savings: $468/year 💰
```

---

## Security Best Practices

### 1. VPN Always On
```
Remote access rule:
├── Always connect via WireGuard first
├── Never expose services directly
└── Use strong VPN passwords
```

### 2. Regular Backups
```bash
# Weekly backup script
#!/bin/bash
cd /srv/docker
for service in */; do
  docker-compose -f "$service/docker-compose.yml" down
done

tar czf /backups/docker-$(date +%Y%m%d).tar.gz /var/lib/docker/volumes
./manage.sh start
```

### 3. Update Regularly
```bash
# Monthly maintenance
cd /srv/docker
./manage.sh update
docker system prune -a
```

### 4. Monitor Logs
```bash
# Check for suspicious activity
./manage.sh logs traefik | grep -i "error\|fail"
docker logs vaultwarden | grep "failed login"
```

### 5. Strong Passwords
```
Use Vaultwarden generator:
├── Minimum 20 characters
├── Include symbols
├── Unique for each service
└── Store in Vaultwarden
```

---

## Troubleshooting

### Can't Access Services Remotely

```bash
# Check VPN connection
sudo wg show

# Verify services running
docker ps

# Test from server
curl https://nextcloud.${DOMAIN}
```

### Slow Streaming Performance

```yaml
# Jellyfin: Enable hardware transcoding
# Lower quality settings on mobile
# Check network bandwidth with Grafana
```

### Storage Running Out

```bash
# Check usage
df -h
docker system df

# Clean up
docker system prune -a --volumes
# Move Jellyfin cache to larger disk
```

---

## Additional Resources

- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Home Assistant Guide](https://www.home-assistant.io/docs/)
- [Gitea Documentation](https://docs.gitea.io/)

---

## Conclusion

These use cases demonstrate the power of self-hosted services. With a one-time setup, you gain:

✅ Complete control over your data
✅ No recurring subscription costs
✅ Enhanced privacy and security
✅ Professional-grade tools
✅ Unlimited scalability

**Start with one use case and gradually expand your workflow!** 🚀
