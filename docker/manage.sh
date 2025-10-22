#!/usr/bin/env bash

# All-in-One Server Management Script
set -e

DOCKER_DIR="/srv/docker"
SERVICES=(
  "traefik"
  "portainer"
  "nextcloud"
  "jellyfin"
  "gitea"
  "monitoring"
  "wireguard"
  "home-assistant"
)

cd "$DOCKER_DIR"

case "${1:-}" in
  start)
    echo "Starting all services..."
    # Create proxy network first
    docker network create proxy 2>/dev/null || true

    # Start Traefik first
    (cd traefik && docker-compose up -d)
    sleep 5

    # Start all other services
    for service in "${SERVICES[@]}"; do
      if [ "$service" != "traefik" ]; then
        echo "Starting $service..."
        (cd "$service" && docker-compose up -d)
      fi
    done
    echo "All services started!"
    ;;

  stop)
    echo "Stopping all services..."
    for service in "${SERVICES[@]}"; do
      echo "Stopping $service..."
      (cd "$service" && docker-compose down) || true
    done
    echo "All services stopped!"
    ;;

  restart)
    "$0" stop
    sleep 5
    "$0" start
    ;;

  status)
    echo "Service status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    ;;

  logs)
    if [ -z "${2:-}" ]; then
      echo "Usage: $0 logs <service-name>"
      echo "Available services: ${SERVICES[*]}"
      exit 1
    fi
    (cd "$2" && docker-compose logs -f)
    ;;

  update)
    echo "Updating all services..."
    for service in "${SERVICES[@]}"; do
      echo "Updating $service..."
      (cd "$service" && docker-compose pull && docker-compose up -d)
    done
    echo "All services updated!"
    ;;

  *)
    echo "All-in-One Server Management"
    echo ""
    echo "Usage: $0 {start|stop|restart|status|logs|update}"
    echo ""
    echo "Commands:"
    echo "  start   - Start all services"
    echo "  stop    - Stop all services"
    echo "  restart - Restart all services"
    echo "  status  - Show service status"
    echo "  logs    - Show logs for a service (e.g., $0 logs traefik)"
    echo "  update  - Update and restart all services"
    echo ""
    echo "Services:"
    for service in "${SERVICES[@]}"; do
      echo "  - $service"
    done
    exit 1
    ;;
esac
