#!/bin/bash
# Quick migration runner for Sisonke
# Run this script to manually execute migrations if auto-run fails

set -e

echo "🔄 Sisonke Database Migration Runner"
echo "====================================="

# Check if connection string is set
if [ -z "$NEON_CONNECTION_STRING" ]; then
    echo "❌ Error: NEON_CONNECTION_STRING environment variable not set"
    echo "Set it from lib/app/core/constants/config.dart"
    exit 1
fi

echo "📍 Using Neon connection: ${NEON_CONNECTION_STRING:0:30}..."

# Install psql if not present
if ! command -v psql &> /dev/null; then
    echo "⚠️  psql not found. Install PostgreSQL client tools."
    exit 1
fi

# Create migration tracking table
echo "🔧 Setting up migration tracking table..."
psql "$NEON_CONNECTION_STRING" < lib/data/migrations/000_schema_migrations.sql

# Run each migration
for migration in lib/data/migrations/{001,002,003}_*.sql; do
    if [ -f "$migration" ]; then
        echo "⏳ Running $(basename "$migration")..."
        psql "$NEON_CONNECTION_STRING" < "$migration"
        echo "✅ $(basename "$migration") complete"
    fi
done

echo ""
echo "✅ All migrations completed!"
echo ""
echo "📊 Migration status:"
psql "$NEON_CONNECTION_STRING" -c "SELECT * FROM schema_migrations ORDER BY installed_on;"