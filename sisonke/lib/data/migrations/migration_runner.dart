import 'package:postgres/postgres.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class MigrationRunner {
  final Connection connection;
  final String migrationsPath;

  MigrationRunner({
    required this.connection,
    required this.migrationsPath,
  });

  /// Run all pending migrations
  Future<void> runMigrations() async {
    try {
      print('🔄 Starting migration runner...');
      
      // Ensure schema_migrations table exists
      await _initializeMigrationTable();

      // Get all SQL migration files
      final migrations = await _getMigrationFiles();
      
      if (migrations.isEmpty) {
        print('✅ No migration files found.');
        return;
      }

      // Get already applied migrations
      final applied = await _getAppliedMigrations();

      // Run pending migrations
      int executedCount = 0;
      for (final migration in migrations) {
        final version = migration['version'] as String;
        if (applied.contains(version)) {
          print('⏭️  Skipping already applied migration: $version');
          continue;
        }

        try {
          print('⏳ Running migration: $version');
          final sql = migration['sql'] as String;
          
          // Execute migration SQL
          await connection.execute(sql);
          
          // Record in schema_migrations
          await connection.execute(
            Sql.named('INSERT INTO schema_migrations (version, description) VALUES (@version, @description)'),
            parameters: {
              'version': version,
              'description': migration['description'],
            },
          );
          
          print('✅ Migration applied: $version');
          executedCount++;
        } catch (e) {
          print('❌ Migration failed: $version - $e');
          rethrow;
        }
      }

      print('✅ All migrations completed! ($executedCount new migrations applied)');
    } catch (e) {
      print('❌ Migration runner error: $e');
      rethrow;
    }
  }

  /// Initialize the schema_migrations tracking table
  Future<void> _initializeMigrationTable() async {
    try {
      await connection.execute('''
        CREATE TABLE IF NOT EXISTS schema_migrations (
          id SERIAL PRIMARY KEY,
          version VARCHAR(255) NOT NULL UNIQUE,
          description VARCHAR(255),
          installed_on TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        )
      ''');
      print('✅ Schema migrations table ready');
    } catch (e) {
      print('❌ Error initializing migration table: $e');
      rethrow;
    }
  }

  /// Get list of migration files in order
  Future<List<Map<String, dynamic>>> _getMigrationFiles() async {
    final dir = Directory(migrationsPath);
    if (!dir.existsSync()) {
      print('⚠️  Migrations directory not found: $migrationsPath');
      return [];
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)));

    final migrations = <Map<String, dynamic>>[];
    for (final file in files) {
      final filename = path.basename(file.path);
      final parts = filename.replaceAll('.sql', '').split('_');
      final version = parts[0];
      final description = parts.skip(1).join('_');
      final sql = file.readAsStringSync();

      migrations.add({
        'version': version,
        'description': description,
        'sql': sql,
        'file': filename,
      });
    }

    return migrations;
  }

  /// Get list of already applied migrations
  Future<List<String>> _getAppliedMigrations() async {
    try {
      final results = await connection.execute(
        'SELECT version FROM schema_migrations ORDER BY version',
      );
      return results.map((row) => row[0] as String).toList();
    } catch (e) {
      print('⚠️  Could not fetch applied migrations (table might not exist): $e');
      return [];
    }
  }

  /// Rollback last N migrations (use with caution!)
  Future<void> rollback({int steps = 1}) async {
    try {
      print('⚠️  Rolling back $steps migration(s)...');
      
      final results = await connection.execute(
        Sql.named('SELECT version FROM schema_migrations ORDER BY installed_on DESC LIMIT @steps'),
        parameters: {'steps': steps},
      );

      for (final row in results) {
        final version = row[0] as String;
        print('❌ Removing migration record: $version');
        
        await connection.execute(
          Sql.named('DELETE FROM schema_migrations WHERE version = @version'),
          parameters: {'version': version},
        );
      }

      print('⚠️  Rollback complete. Manually restore data if needed.');
    } catch (e) {
      print('❌ Rollback error: $e');
      rethrow;
    }
  }

  /// Get migration status
  Future<void> status() async {
    try {
      final migrations = await _getMigrationFiles();
      final applied = await _getAppliedMigrations();

      print('\n📊 Migration Status:');
      print('───────────────────────────────────────');
      
      for (final migration in migrations) {
        final version = migration['version'] as String;
        final description = migration['description'] as String;
        final isApplied = applied.contains(version);
        final status = isApplied ? '✅ Applied' : '⏳ Pending';
        print('$status  $version  $description');
      }
      
      print('───────────────────────────────────────');
      print('Total: ${migrations.length} | Applied: ${applied.length} | Pending: ${migrations.length - applied.length}');
    } catch (e) {
      print('❌ Error getting status: $e');
      rethrow;
    }
  }
}
