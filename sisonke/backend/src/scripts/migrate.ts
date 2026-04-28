import 'dotenv/config';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import { client, db } from '../db';
import { validateEnv } from '../env';

async function main() {
  validateEnv();
  await migrate(db, { migrationsFolder: 'src/db/migrations' });
  await client.end();
  console.log('Database migrations completed.');
}

main().catch(async (error) => {
  console.error(error);
  await client.end({ timeout: 5 }).catch(() => undefined);
  process.exit(1);
});
