#!/usr/bin/env sh
set -e

CONTAINER_NAME="django-boards"

echo "Waiting for database to be ready:"

for i in {1..30}; do
    if python3 manage.py check --database default >/dev/null 2>&1; then
        echo "Database connection successful!\n"
        break
    else
        echo "Waiting for database... attempt $i/30"
        sleep 2
    fi
    if [ $i -eq 30 ]; then
        echo "Database connection failed after 30 attempts"
        echo "Database connection details:"
        python3 manage.py check --database default || true
        exit 1
    fi
done


echo "Running database migrations:"
python3 manage.py migrate --noinput

# echo "Collecting static files:"
# Ensure static files directory has proper permissions before collecting
# python3 manage.py collectstatic --noinput --clear

echo "Initialization complete. Starting application:"

# Execute the CMD from Dockerfile (gunicorn)
echo "Starting Gunicorn server:"
exec "$@"
