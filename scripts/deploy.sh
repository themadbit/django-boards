#!/bin/bash

# Django Boards Deployment Script
set -e

# Configuration
APP_DIR="/opt/django-boards"
COMPOSE_FILE="docker-compose.prod.yml"
ENV_FILE=".env.prod"
CONTAINER_NAME="django-boards"

# Navigate to application directory
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

# Verify critical environment variables
for var in "GITHUB_REPOSITORY" "SECRET_KEY" "DATABASE_NAME" "DATABASE_USERNAME" "DATABASE_PASSWORD"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "Using repository: $GITHUB_REPOSITORY"

# Pull latest images
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

# Stop existing services
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down

docker compose up "$CONTAINER_NAME" -d
docker exec -u 0 "$CONTAINER_NAME" python manage.py collectstatic --noinput

# Start services
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

# Wait for Django container to be ready
# echo "Waiting for Django container to start..."
# for i in {1..30}; do
#     if docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" | grep -q "$CONTAINER_NAME"; then
#         echo "Django container is running"
#         break
#     fi
#     if [ $i -eq 30 ]; then
#         echo "Error: Django container failed to start"
#         docker logs "$CONTAINER_NAME" --tail=50
#         exit 1
#     fi
#     sleep 2
# done

# # Collect static files
# echo "Collecting static files..."
# docker exec -u 0 "$CONTAINER_NAME" python manage.py collectstatic --noinput

# Verify deployment
echo "Checking service status..."
docker compose -f "$COMPOSE_FILE" ps

echo "Deployment completed successfully"
