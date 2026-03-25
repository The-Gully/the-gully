#!/bin/bash
set -e

echo "Waiting for postgres to be ready..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_SERVER -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
    sleep 1
done
echo "Postgres is ready!"

# Populate database if not already done
echo "Checking if database needs population..."
ROW_COUNT=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_SERVER -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c "SELECT COUNT(*) FROM ipl_ball_by_ball;" 2>/dev/null | tr -d '[:space:]')

if [ "$ROW_COUNT" = "0" ]; then
    echo "Populating database..."
    cd /app
    python -m db.populate
    echo "Database populated successfully!"
else
    echo "Database already populated, skipping."
fi

exec uvicorn agents.app.main:app --host 0.0.0.0 --port 8000
