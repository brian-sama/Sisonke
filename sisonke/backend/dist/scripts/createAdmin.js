"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const env_1 = require("../env");
async function main() {
    (0, env_1.validateEnv)();
    const email = (process.env.ADMIN_EMAIL || '').trim().toLowerCase();
    const password = process.env.ADMIN_PASSWORD || '';
    if (!email || !password) {
        throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD are required.');
    }
    const existing = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.email, email)).limit(1);
    if (existing.length > 0) {
        await db_1.db.update(schema_1.users).set({ role: 'admin', roles: ['super-admin', 'admin'], isGuest: false, updatedAt: new Date() }).where((0, drizzle_orm_1.eq)(schema_1.users.id, existing[0].id));
        console.log(`Promoted existing user ${email} to super admin.`);
        return;
    }
    const passwordHash = await bcryptjs_1.default.hash(password, 12);
    await db_1.db.insert(schema_1.users).values({
        email,
        passwordHash,
        role: 'admin',
        roles: ['super-admin', 'admin'],
        isGuest: false,
        updatedAt: new Date(),
    });
    console.log(`Created admin user ${email}.`);
}
main().catch((error) => {
    console.error(error);
    process.exit(1);
});
//# sourceMappingURL=createAdmin.js.map