#!/usr/bin/env bash
# Sisonke Setup & Migration Checklist
# Run this to verify your setup is ready

set -e

echo "🔍 Sisonke Setup Verification"
echo "=============================="
echo ""

# Check Flutter
echo "1️⃣  Checking Flutter..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -1)
    echo "   ✅ $FLUTTER_VERSION"
else
    echo "   ❌ Flutter not found. Install from https://flutter.dev"
    exit 1
fi

# Check Dart
echo ""
echo "2️⃣  Checking Dart..."
if command -v dart &> /dev/null; then
    DART_VERSION=$(dart --version 2>&1 | head -1)
    echo "   ✅ $DART_VERSION"
else
    echo "   ❌ Dart not found"
    exit 1
fi

# Check project structure
echo ""
echo "3️⃣  Checking project structure..."
REQUIRED_DIRS=(
    "lib/app/router"
    "lib/app/theme"
    "lib/app/core/constants"
    "lib/app/core/services"
    "lib/features/auth"
    "lib/features/home"
    "lib/data/migrations"
    "lib/shared/models"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir"
    else
        echo "   ❌ Missing: $dir"
        exit 1
    fi
done

# Check key files
echo ""
echo "4️⃣  Checking key files..."
REQUIRED_FILES=(
    "lib/main.dart"
    "lib/app/core/constants/config.dart"
    "lib/features/auth/auth_service_neon.dart"
    "lib/data/migrations/migration_runner_embedded.dart"
    "pubspec.yaml"
    "README.md"
    "SETUP.md"
    "NEON_SETUP.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ Missing: $file"
        exit 1
    fi
done

# Check dependencies
echo ""
echo "5️⃣  Checking dependencies..."
if [ -f "pubspec.lock" ]; then
    POSTGRES=$(grep -A 1 '"postgres"' pubspec.lock | head -1)
    if [[ "$POSTGRES" == *"postgres"* ]]; then
        echo "   ✅ postgres package"
    fi
    
    RIVERPOD=$(grep -A 1 '"flutter_riverpod"' pubspec.lock | head -1)
    if [[ "$RIVERPOD" == *"riverpod"* ]]; then
        echo "   ✅ flutter_riverpod package"
    fi
else
    echo "   ⚠️  Run 'flutter pub get' first"
fi

# Check Neon connection
echo ""
echo "6️⃣  Checking Neon configuration..."
if grep -q "neondb_owner" lib/app/core/constants/config.dart; then
    echo "   ✅ Neon connection string configured"
else
    echo "   ❌ Neon connection string not found"
    echo "   Add your connection string to lib/app/core/constants/config.dart"
fi

echo ""
echo "=============================="
echo "✅ All checks passed! Ready to run."
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Run: flutter run"
echo "3. Choose device (Windows desktop)"
echo ""
echo "On first run, migrations will auto-execute."
echo "Check console for migration status."
echo ""
echo "For more info, see:"
echo "- README.md          (overview)"
echo "- SETUP.md           (development setup)"
echo "- NEON_SETUP.md      (database setup)"