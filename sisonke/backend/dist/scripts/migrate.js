"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = __importDefault(require("path"));
require("dotenv/config");
const migrator_1 = require("drizzle-orm/postgres-js/migrator");
const db_1 = require("../db");
const env_1 = require("../env");
async function main() {
    (0, env_1.validateEnv)();
    const folder = process.env.MIGRATIONS_FOLDER || path_1.default.resolve(process.cwd(), 'src/db/migrations');
    console.log(`Running migrations from: ${folder}`);
    await (0, migrator_1.migrate)(db_1.db, { migrationsFolder: folder });
    await db_1.client.end();
    console.log('Database migrations completed.');
}
main().catch(async (error) => {
    console.error(error);
    await db_1.client.end({ timeout: 5 }).catch(() => undefined);
    process.exit(1);
});
//# sourceMappingURL=migrate.js.map