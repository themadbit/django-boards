#!/bin/bash

# Deployment script echo "🔧 Loadiecho "🔧 Loading environment variables..."

# Check the cechecho "✅ All environment variables loaded successfully"
echo "� Using repository: $GITHUB_REPOSITORY"
echo "🐳 Docker image: ghcr.io/$GITHUB_REPOSITORY:latest"

# Test Docker Compose variable substitution
echo "🧪 Testing Docker Compose variable substitution..."
echo "🔍 Showing Docker Compose config with variables resolved (first 20 lines):"
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" config | head -20

# Test if config is valid
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" config --quiet
if [ $? -eq 0 ]; then
    echo "✅ Docker Compose can read environment variables"
else
    echo "❌ Docker Compose configuration test failed!"
    exit 1
fi

echo "�📦 Pulling latest container images..." Pulling latest container images..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

echo "🔄 Stopping existing services..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down

echo "🚀 Starting services (migrations and static files will run via entrypoint)..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -df the env file first
echo "📋 Environment file contents (with secrets masked):"
sed 's/SECRET_KEY=.*/SECRET_KEY=***MASKED***/g; s/DATABASE_PASSWORD=.*/DATABASE_PASSWORD=***MASKED***/g' "$ENV_FILE"

# Clean the env file (remove leading/trailing whitespace and empty lines)
echo "🧹 Cleaning environment file..."
sed 's/^[[:space:]]*//g; s/[[:space:]]*$//g' "$ENV_FILE" | grep -v '^\s*$' | grep -v '^#' > "${ENV_FILE}.clean"
mv "${ENV_FILE}.clean" "$ENV_FILE"

# Validate environment file format
echo "🔍 Validating environment file format..."
if ! grep -q '=' "$ENV_FILE"; then
    echo "❌ Error: Environment file doesn't contain any key=value pairs!"
    exit 1
fi

# Check for required variables in the file
for var in "GITHUB_REPOSITORY" "SECRET_KEY" "DATABASE_NAME"; do
    if ! grep -q "^${var}=" "$ENV_FILE"; then
        echo "❌ Error: $var not found in environment file!"
        exit 1
    fi
done

echo "✅ Environment file format validation passed"

# Export environment variables using multiple methods for reliability
echo "🔧 Exporting environment variables..."
set -a  # automatically export all variables
source "$ENV_FILE"
set +a  # turn off automatic export

# Alternative export method
export $(cat "$ENV_FILE" | grep -v '^#' | grep -v '^\s*$' | xargs)

# Debug: Show what Docker Compose will see
echo "🔍 Environment variables that Docker Compose will see:"
printenv | grep -E '(GITHUB_REPOSITORY|SECRET_KEY|DATABASE_|ALLOWED_HOSTS)' | sed 's/SECRET_KEY=.*/SECRET_KEY=***MASKED***/g; s/DATABASE_PASSWORD=.*/DATABASE_PASSWORD=***MASKED***/g'"🔧 Loading environment variables..."g environment variables..."

# Cheecho "📦 Pulling latest container images..."k the content of the env file first
echo "📋 Environment file contents (with secrets masked):"
sed 's/SECRET_KEY=.*/SECRET_KEY=***MASKED***/g; s/DATABASE_PASSWORD=.*/DATABASE_PASSWORD=***MASKED***/g' "$ENV_FILE"

# Clean the env file (remove leading/trailing whitespace)
echo "🧹 Cleaning environment file..."
sed 's/^[[:space:]]*//g; s/[[:space:]]*$//g' "$ENV_FILE" > "${ENV_FILE}.clean"
mv "${ENV_FILE}.clean" "$ENV_FILE"

# Export environment variables so they're available to docker compose
set -a  # automatically export all variables
source "$ENV_FILE"
set +a  # turn off automatic exportjango Boarecho "✅ Environment variables loaded successfully"
echo "📋 Using repository: $GITHUB_REPOSITORY"
echo "🐳 Docker image: ghcr.io/$GITHUB_REPOSITORY:latest"

echo "📦 Pulling latest container images..." This script will be executed on the VM during deployment

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

echo "� Loading environment variables..."
# Export environment variables so they're available to docker compose
set -a  # automatically export all variables
source "$ENV_FILE"
set +a  # turn off automatic export

# Verify critical environment variables are set
echo "🔍 Verifying environment variables..."

# List of required variables
required_vars=("GITHUB_REPOSITORY" "SECRET_KEY" "DATABASE_NAME" "DATABASE_USERNAME" "DATABASE_PASSWORD" "ALLOWED_HOSTS")
missing_vars=0

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: $var is not set!"
        missing_vars=$((missing_vars + 1))
    else
        if [[ "$var" == *"PASSWORD"* ]] || [[ "$var" == *"SECRET"* ]]; then
            echo "✅ $var is set (***MASKED***)"
        else
            echo "✅ $var is set: ${!var}"
        fi
    fi
done

if [ $missing_vars -gt 0 ]; then
    echo "❌ $missing_vars required environment variables are missing!"
    exit 1
fi

echo "✅ All environment variables loaded successfully"
echo "📋 Using repository: $GITHUB_REPOSITORY"
echo "🐳 Docker image: ghcr.io/$GITHUB_REPOSITORY:latest"

echo "�📦 Pulling latest container images..."
docker compose -f "$COMPOSE_FILE" pull

echo "🔄 Stopping existing services..."
docker compose -f "$COMPOSE_FILE" down

echo "🚀 Starting services (migrations and static files will run via entrypoint)..."
docker compose -f "$COMPOSE_FILE" up -d

echo "⏳ Waiting for application initialization..."
sleep 15

# Check container status and health
echo "🔍 Checking container status..."
docker compose -f "$COMPOSE_FILE" ps

echo "🩺 Checking health status..."
docker inspect django-boards --format='{{.State.Health.Status}}'

# If unhealthy, show the health check logs
if [ "$(docker inspect django-boards --format='{{.State.Health.Status}}')" = "unhealthy" ]; then
    echo "❌ Container is unhealthy. Health check details:"
    docker inspect django-boards --format='{{range .State.Health.Log}}{{.Output}}{{end}}'

    echo "📋 Container logs (last 50 lines):"
    docker logs django-boards --tail=50

    echo "🔍 Container processes:"
    docker exec django-boards ps aux || echo "Could not exec into container"

    echo "🌐 Network connectivity test:"
    docker exec django-boards curl -v http://localhost:8000/ || echo "Curl test failed"

    echo "❌ Health check failed - see details above"
    exit 1
fi

echo "✅ Deployment completed successfully!"
