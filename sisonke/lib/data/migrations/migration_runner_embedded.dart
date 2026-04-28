import 'package:postgres/postgres.dart';

/// Embedded SQL migrations as Dart constants
/// This ensures migrations are included in the app bundle
class EmbeddedMigrations {
  static const Map<String, String> migrations = {
    '000': _migration000SchemaTracking,
    '001': _migration001Init,
    '002': _migration002Auth,
    '003': _migration003UserData,
  };

  static const String _migration000SchemaTracking = '''
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id SERIAL PRIMARY KEY,
      version VARCHAR(255) NOT NULL UNIQUE,
      description VARCHAR(255),
      installed_on TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  ''';

  static const String _migration001Init = '''
    CREATE TABLE IF NOT EXISTS resources (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      title TEXT NOT NULL,
      slug TEXT UNIQUE NOT NULL,
      summary TEXT,
      content TEXT,
      category TEXT,
      topic_tags TEXT[],
      language TEXT DEFAULT 'en',
      is_published BOOLEAN DEFAULT false,
      is_offline_featured BOOLEAN DEFAULT false,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS emergency_contacts (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL,
      phone_number TEXT NOT NULL,
      region TEXT,
      category TEXT,
      is_24_7 BOOLEAN DEFAULT false,
      notes TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS anonymous_questions (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      question_text TEXT NOT NULL,
      topic TEXT,
      status TEXT DEFAULT 'pending',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      moderation_flag BOOLEAN DEFAULT false
    );

    CREATE TABLE IF NOT EXISTS answers (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      question_id UUID REFERENCES anonymous_questions(id) ON DELETE CASCADE,
      answer_text TEXT NOT NULL,
      reviewed_by TEXT,
      published_at TIMESTAMP WITH TIME ZONE
    );

    CREATE INDEX IF NOT EXISTS idx_resources_slug ON resources(slug);
    CREATE INDEX IF NOT EXISTS idx_resources_category ON resources(category);
    CREATE INDEX IF NOT EXISTS idx_resources_is_published ON resources(is_published);
    CREATE INDEX IF NOT EXISTS idx_emergency_contacts_region ON emergency_contacts(region);
    CREATE INDEX IF NOT EXISTS idx_anonymous_questions_status ON anonymous_questions(status);
    CREATE INDEX IF NOT EXISTS idx_answers_question_id ON answers(question_id);

    ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
    ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
    ALTER TABLE anonymous_questions ENABLE ROW LEVEL SECURITY;
    ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
  ''';

  static const String _migration002Auth = '''
    CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email TEXT UNIQUE,
      password_hash TEXT,
      is_guest BOOLEAN DEFAULT true,
      display_name TEXT,
      country TEXT,
      language TEXT DEFAULT 'en',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      last_login TIMESTAMP WITH TIME ZONE,
      is_active BOOLEAN DEFAULT true
    );

    CREATE TABLE IF NOT EXISTS sessions (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      token TEXT UNIQUE NOT NULL,
      expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      last_used TIMESTAMP WITH TIME ZONE
    );

    CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    CREATE INDEX IF NOT EXISTS idx_users_is_guest ON users(is_guest);
    CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
    CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(token);
    CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);

    ALTER TABLE users ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Users can view own profile" ON users FOR SELECT 
      USING (auth.uid() = id::text OR is_guest = true);

    CREATE POLICY "Users can update own profile" ON users FOR UPDATE 
      USING (auth.uid() = id::text);

    CREATE POLICY "Anyone can insert guest user" ON users FOR INSERT 
      WITH CHECK (is_guest = true OR auth.uid() = id::text);

    CREATE POLICY "Users can view own sessions" ON sessions FOR SELECT 
      USING (auth.uid() = user_id::text);

    CREATE POLICY "Users can insert own sessions" ON sessions FOR INSERT 
      WITH CHECK (auth.uid() = user_id::text);

    CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
    RETURNS void AS \$\$
    BEGIN
      DELETE FROM sessions WHERE expires_at < NOW();
    END;
    \$\$ LANGUAGE plpgsql;
  ''';

  static const String _migration003UserData = '''
    CREATE TABLE IF NOT EXISTS mood_entries (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      mood_score INTEGER NOT NULL CHECK (mood_score >= 1 AND mood_score <= 10),
      mood_label TEXT,
      note TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      synced BOOLEAN DEFAULT false
    );

    CREATE TABLE IF NOT EXISTS sobriety_entries (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      entry_type TEXT NOT NULL,
      date DATE NOT NULL,
      notes TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      synced BOOLEAN DEFAULT false
    );

    CREATE TABLE IF NOT EXISTS journal_entries (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      title TEXT,
      body TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      synced BOOLEAN DEFAULT false
    );

    CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON mood_entries(user_id);
    CREATE INDEX IF NOT EXISTS idx_mood_entries_created_at ON mood_entries(created_at);
    CREATE INDEX IF NOT EXISTS idx_sobriety_entries_user_id ON sobriety_entries(user_id);
    CREATE INDEX IF NOT EXISTS idx_sobriety_entries_date ON sobriety_entries(date);
    CREATE INDEX IF NOT EXISTS idx_journal_entries_user_id ON journal_entries(user_id);
    CREATE INDEX IF NOT EXISTS idx_journal_entries_created_at ON journal_entries(created_at);

    ALTER TABLE mood_entries ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sobriety_entries ENABLE ROW LEVEL SECURITY;
    ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Users can view own mood entries" ON mood_entries FOR SELECT 
      USING (auth.uid() = user_id::text);

    CREATE POLICY "Users can insert own mood entries" ON mood_entries FOR INSERT 
      WITH CHECK (auth.uid() = user_id::text);

    CREATE POLICY "Users can update own mood entries" ON mood_entries FOR UPDATE 
      USING (auth.uid() = user_id::text);

    CREATE POLICY "Users can view own sobriety entries" ON sobriety_entries FOR SELECT 
      USING (auth.uid() = user_id::text);

    CREATE POLICY "Users can insert own sobriety entries" ON sobriety_entries FOR INSERT 
      WITH CHECK (auth.uid() = user_id::text);

    CREATE POLICY "Users can view own journal entries" ON journal_entries FOR SELECT 
      USING (auth.uid() = user_id::text);

    CREATE POLICY "Users can insert own journal entries" ON journal_entries FOR INSERT 
      WITH CHECK (auth.uid() = user_id::text);

    CREATE POLICY "Users can update own journal entries" ON journal_entries FOR UPDATE 
      USING (auth.uid() = user_id::text);
  ''';
}

/// Simplified migration runner that uses embedded SQL
class MigrationRunnerEmbedded {
  final Connection connection;

  MigrationRunnerEmbedded({required this.connection});

  /// Run all pending migrations
  Future<void> runMigrations() async {
    try {
      print('🔄 Starting migration runner...');

      // Ensure schema_migrations table exists
      await _initializeMigrationTable();

      // Get already applied migrations
      final applied = await _getAppliedMigrations();

      // Run pending migrations in order
      int executedCount = 0;
      for (final version in ['000', '001', '002', '003']) {
        if (applied.contains(version)) {
          print('⏭️  Skipping already applied migration: $version');
          continue;
        }

        try {
          print('⏳ Running migration: $version');
          final sql = EmbeddedMigrations.migrations[version];

          if (sql == null) {
            print('⚠️  Migration SQL not found: $version');
            continue;
          }

          // Execute migration SQL
          await connection.execute(sql);

          // Record in schema_migrations
          await connection.execute(
            Sql.named('INSERT INTO schema_migrations (version, description) VALUES (@version, @description)'),
            parameters: {
              'version': version,
              'description': 'Migration $version',
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
      await connection.execute(EmbeddedMigrations._migration000SchemaTracking);
      print('✅ Schema migrations table ready');
    } catch (e) {
      print('❌ Error initializing migration table: $e');
      rethrow;
    }
  }

  /// Get list of already applied migrations
  Future<List<String>> _getAppliedMigrations() async {
    try {
      final results = await connection.execute(
        'SELECT version FROM schema_migrations ORDER BY version',
      );
      return results.map((row) => row[0] as String).toList();
    } catch (e) {
      print('⚠️  Could not fetch applied migrations: $e');
      return [];
    }
  }

  /// Get migration status
  Future<void> status() async {
    try {
      final applied = await _getAppliedMigrations();

      print('\n📊 Migration Status:');
      print('───────────────────────────────────────');

      for (final version in ['000', '001', '002', '003']) {
        final isApplied = applied.contains(version);
        final status = isApplied ? '✅ Applied' : '⏳ Pending';
        print('$status  $version');
      }

      print('───────────────────────────────────────');
      print('Total: 4 | Applied: ${applied.length} | Pending: ${4 - applied.length}');
    } catch (e) {
      print('❌ Error getting status: $e');
      rethrow;
    }
  }
}