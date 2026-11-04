#!/usr/bin/env bash
# Mac/Linux twin of backup.ps1. Dumps schema, data and roles of the linked Supabase project.
set -euo pipefail

# Absolute path: the Supabase CLI resolves relative -f paths from the project root, not from here.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$SCRIPT_DIR/backups/$TIMESTAMP"

mkdir -p "$BACKUP_DIR"

echo "Backing up Supabase database..."

# Backup schema
supabase db dump --remote -f "$BACKUP_DIR/schema.sql" || { echo "Schema backup failed" >&2; exit 1; }

# Backup data
supabase db dump --remote --use-copy --data-only \
  -x "storage.buckets_vectors" \
  -x "storage.vector_indexes" \
  -f "$BACKUP_DIR/data.sql" || { echo "Data backup failed" >&2; exit 1; }

# Backup roles
supabase db dump --remote --role-only -f "$BACKUP_DIR/roles.sql" || { echo "Roles backup failed" >&2; exit 1; }

echo
echo "Backup completed successfully!"
echo "Location: $BACKUP_DIR"
