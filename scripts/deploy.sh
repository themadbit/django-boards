#!/bin/bash

# Deployment script for Django Boards
# This script will be executed on the VM during deployment

set -e  # Exit on any error

echo "🚀 Starting deployment of Django Boards..."

# Configuration
APP_DIR="/opt/django-boards"
COMPOSE_FILE="docker-compose.prod.yml"
ENV_FILE=".env.prod"

# Navigate to application directory
cd "$APP_DIR"

# Verify required files exist
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found!"
    echo "Please create $ENV_FILE with production environment variables"
    exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Error: $COMPOSE_FILE not found!"
    echo "Please ensure the Docker Compose file is deployed"
    exit 1
fi

echo "📦 Pulling latest container images..."
docker compose -f "$COMPOSE_FILE" pull

echo "🔄 Stopping existing services..."
docker compose -f "$COMPOSE_FILE" down

echo "� Starting services (migrations and static files will run via entrypoint)..."
docker compose -f "$COMPOSE_FILE" up -d

echo "⏳ Waiting for application initialization..."
sleep 15

echo "✅ Deployment completed successfully!"
