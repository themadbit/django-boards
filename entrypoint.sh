#!/uecho "🔧 Setting uecho "🔄 Waiting for database to be ready..."
# Wait for PostgreSQL to be ready
for i in {1..30}; do
    if python3 manage.py check --database default >/dev/null 2>&1; then
        echo "✅ Database connection successful"
        break
    else
        echo "⏳ Waiting for database... (attempt $i/30)"
        sleep 2
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Database connection failed after 30 attempts"
        echo "🔍 Database connection details:"
        python3 manage.py check --database default || true
        exit 1
    fi
done

echo "🔄 Running database migrations..."
python3 manage.py migrate --noinputstatic files directory..."
# Ensure the staticfiles directory exists and is writable
mkdir -p /app/staticfiles

# Check if we can write to the directory
if [ ! -w /app/staticfiles ]; then
    echo "⚠️  Warning: /app/staticfiles is not writable by current user"
    ls -la /app/staticfiles
fi

echo "👤 Current user: $(whoami) (UID: $(id -u), GID: $(id -g))"
echo "📁 Static files directory permissions:"
ls -ld /app/staticfilesn/env bash

set -e  # Exit on any error

echo "� Setting up permissions for static files..."
# Ensure the staticfiles directory exists and has proper permissions
mkdir -p /app/staticfiles
# Change ownership to appuser if we have permission, otherwise just make it writable
sudo chown -R appuser:appuser /app/staticfiles 2>/dev/null || chmod -R 755 /app/staticfiles

echo "�🔄 Running database migrations..."
python3 manage.py migrate --noinput

echo "📂 Collecting static files..."
python3 manage.py collectstatic --noinput --clear

echo "✅ Initialization complete. Starting application..."

# Execute the CMD from Dockerfile (gunicorn)
echo "🚀 Starting Gunicorn server..."
exec "$@"
