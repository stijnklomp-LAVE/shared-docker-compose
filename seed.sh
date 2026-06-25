#!/usr/bin/env bash
set -euo pipefail

wait_for_table() {
  local table=$1 label=$2 timeout=${3:-120}
  local elapsed=0 shown=false
  until docker compose exec -T db psql -U dev -d video-editor \
    -c "SELECT 1 FROM \"$table\" LIMIT 1" &>/dev/null 2>&1; do
    if [ "$elapsed" -ge "$timeout" ]; then
      echo "ERROR: Timed out after ${timeout}s waiting for $table ($label)."
      echo "       The seed requires all services to be running."
      echo "       See README.md for setup instructions."
      exit 1
    fi
    if ! $shown; then
      echo "  Waiting for $table ($label)..."
      shown=true
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
}

echo "Waiting for database migrations..."
wait_for_table Account   "client migration"
wait_for_table Device    "fragment-composer migration"
echo "Migrations applied."

echo "Seeding database..."
docker compose exec -T db psql -U dev -d video-editor < ../client/prisma/seed.sql
echo "Seed complete."
