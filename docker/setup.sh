#!/usr/bin/env bash

# All-in-One Server Setup Script
set -e

echo "========================================="
echo "  All-in-One Home Server Setup"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "ERROR: Do not run this script as root!"
  exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "ERROR: Docker is not installed!"
  echo "Please rebuild NixOS with: sudo nixos-rebuild switch --flake .#nixos-gmc"
  exit 1
fi

# Check if user is in docker group
if ! groups | grep -q docker; then
  echo "ERROR: Current user is not in docker group!"
  echo "Please log out and log back in, or run: newgrp docker"
  exit 1
fi

TARGET_DIR="/srv/docker"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Source directory: $SOURCE_DIR"
echo "Target directory: $TARGET_DIR"
echo ""

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
  echo "Creating $TARGET_DIR..."
  sudo mkdir -p "$TARGET_DIR"
  sudo chown -R "$(whoami):users" "$TARGET_DIR"
fi

# Copy files
echo "Copying configuration files..."
rsync -av --exclude='.git' "$SOURCE_DIR/" "$TARGET_DIR/"

cd "$TARGET_DIR"

# Check if .env exists
if [ ! -f .env ]; then
  if [ -f .env.template ]; then
    echo ""
    echo "Creating .env from template..."
    cp .env.template .env
    echo "⚠️  IMPORTANT: Edit .env and set your passwords!"
    echo "   nano .env"
  fi
else
  echo "✓ .env file already exists"
fi

# Setup Traefik
echo ""
echo "Setting up Traefik..."
cd traefik
if [ ! -f acme.json ]; then
  touch acme.json
  chmod 600 acme.json
  echo "✓ Created acme.json"
fi

if [ ! -d config ]; then
  mkdir -p config
  echo "✓ Created config directory"
fi

cd "$TARGET_DIR"

# Create Grafana provisioning directories
echo ""
echo "Setting up Grafana..."
mkdir -p monitoring/grafana/provisioning/{dashboards,datasources,notifiers}

# Make manage script executable
chmod +x manage.sh
echo "✓ Made manage.sh executable"

# Create Docker network
echo ""
echo "Creating Docker network..."
docker network create proxy 2>/dev/null && echo "✓ Created 'proxy' network" || echo "✓ Network 'proxy' already exists"

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Edit configuration:"
echo "   cd $TARGET_DIR"
echo "   nano .env"
echo ""
echo "2. Generate admin password for Traefik:"
echo "   htpasswd -nb admin yourpassword"
echo "   (Copy output to TRAEFIK_ADMIN_AUTH in .env)"
echo ""
echo "3. Start services:"
echo "   ./manage.sh start"
echo ""
echo "4. Check status:"
echo "   ./manage.sh status"
echo ""
echo "5. View logs:"
echo "   ./manage.sh logs traefik"
echo ""
echo "📖 Read README.md for detailed configuration"
echo ""
