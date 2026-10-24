#!/usr/bin/env bash
set -euo pipefail

# Dynamically determine paths relative to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MIGRATIONS_DIR="${SCRIPT_DIR}"
SEED_DIR="${BASE_DIR}/database/seed"

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-nexora_admin}"
DB_NAME="${DB_NAME:-inventory_db}"

echo "=== NEXORA DATABASE MIGRATION ENGINE ==="
echo "Target: ${DB_NAME} on ${DB_HOST}:${DB_PORT} (User: ${DB_USER})"

# Ensure schema_migrations table exists
psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -c "
CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    version VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);"

# Execute forward migrations sequentially
for file in $(ls "${MIGRATIONS_DIR}"/*.sql 2>/dev/null | sort); do
    filename=$(basename "${file}")
    version_tag="${filename%.sql}"
    
    already_applied=$(psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A -c "SELECT COUNT(*) FROM schema_migrations WHERE version = '${version_tag}';")
    
    if [[ "${already_applied}" -eq 0 ]]; then
        echo "Applying forward migration: ${filename}..."
        psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -f "${file}"
        psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -c "INSERT INTO schema_migrations (version) VALUES ('${version_tag}');"
        echo "Successfully applied ${filename}."
    else
        echo "Skipping already applied migration: ${filename}"
    fi
done

echo "Current Applied Database Migrations:"
psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT * FROM schema_migrations ORDER BY id ASC;"
