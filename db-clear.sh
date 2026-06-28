#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-client}"

case "$SERVICE" in
	client)
		MIGRATION_SERVICE="client-migration"
		;;
	fragment-composer)
		MIGRATION_SERVICE="fragment-composer-migration"
		;;
	*)
		echo "ERROR: Unknown service '$SERVICE'. Choose from: client, fragment-composer"
		exit 1
		;;
esac

echo "Clearing database via '$MIGRATION_SERVICE'..."
docker compose run --rm "$MIGRATION_SERVICE" \
	sh -c "
		export DATABASE_URL='postgresql://dev:admin123@db:5432/video-editor?schema=public'
		bunx prisma migrate reset --force
	"
echo "Database cleared for '$SERVICE'."
