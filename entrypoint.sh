#!/usr/bin/env bash

set -e  # Exit on any error

echo "🔄 Running database migrations..."
python3 manage.py migrate --noinput

echo "📂 Collecting static files..."
python3 manage.py collectstatic --noinput

echo "✅ Initialization complete. Starting application..."
