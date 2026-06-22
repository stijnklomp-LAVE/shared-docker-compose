#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T db psql -U dev -d video-editor < ../client/prisma/seed.sql
