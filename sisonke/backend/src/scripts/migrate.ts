import path from 'path';
import 'dotenv/config';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import { client, db } from '../db';
import { validateEnv } from '../env';

async function main() {
  validateEnv();
  const folder = process.env.MIGRATIONS_FOLDER || path.resolve(process.cwd(), 'src/db/migrations');
  console.log(`Running migrations from: ${folder}`);
  await migrate(db, { migrationsFolder: folder });
  await client.end();
  console.log('Database migrations completed.');
}

main().catch(async (error) => {
  console.error(error);
  await client.end({ timeout: 5 }).catch(() => undefined);
  process.exit(1);
});
