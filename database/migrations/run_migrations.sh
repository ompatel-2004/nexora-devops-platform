#!/usr/bin/env bash
set -e

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-inventory_db}"
DB_USER="${DB_USER:-nexora_admin}"
export PGPASSWORD="${PGPASSWORD:-devops_secure_password_123}"

MIGRATIONS_DIR="/mnt/c/nexora-devops-platform/database/migrations"

echo "=== NEXORA DATABASE MIGRATION ENGINE (Section 32) ==="
echo "Target Database: $DB_NAME on $DB_HOST:$DB_PORT"

# Ensure tracker exists
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(50) PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);" > /dev/null

for file in $(ls "$MIGRATIONS_DIR"/*.sql | sort); do
    ver=$(basename "$file" .sql)
    applied=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -A -c "SELECT COUNT(*) FROM schema_migrations WHERE version = '$ver';")
    
    if [ "$applied" -eq 0 ]; then
        echo "Applying forward migration: $ver..."
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file"
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "INSERT INTO schema_migrations (version) VALUES ('$ver');" > /dev/null
        echo "  Successfully applied $ver."
    else
        echo "Skipping already applied migration: $ver"
    fi
done

echo "Current Applied Database Migrations:"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT * FROM schema_migrations ORDER BY applied_at ASC;"
