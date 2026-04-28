"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const migrator_1 = require("drizzle-orm/postgres-js/migrator");
const db_1 = require("../db");
const env_1 = require("../env");
async function main() {
    (0, env_1.validateEnv)();
    await (0, migrator_1.migrate)(db_1.db, { migrationsFolder: 'src/db/migrations' });
    await db_1.client.end();
    console.log('Database migrations completed.');
}
main().catch(async (error) => {
    console.error(error);
    await db_1.client.end({ timeout: 5 }).catch(() => undefined);
    process.exit(1);
});
//# sourceMappingURL=migrate.js.map