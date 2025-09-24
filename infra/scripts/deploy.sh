#!/bin/bash
# Django Boards Deployment Script

set -e

# Configuration
APP_DIR="/opt/django-boards"
COMPOSE_FILE="docker-compose.prod.yml"
ENV_FILE=".env.prod"
CONTAINER_NAME="django-boards"

cd "$APP_DIR"

# Verify required files exist
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found"
    exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Error: $COMPOSE_FILE not found"
    exit 1
fi

# Load environment variables
set -a
source "$ENV_FILE"
set +a

echo "Using repository: $GITHUB_REPOSITORY"

# Pull latest images
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

# Stop existing services
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down

# Start django-boards service
# Collect static files as root (for proper file permissions)
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up "$CONTAINER_NAME" -d
docker exec -u 0 "$CONTAINER_NAME" python manage.py collectstatic --noinput

# Start all services
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

# Verify deployment
echo "Checking service status..."
docker compose -f "$COMPOSE_FILE" ps

echo "Deployment completed successfully"
