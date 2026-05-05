"use strict";
const dotenv = require('dotenv');
const path = require('path');
const bcrypt = require('bcryptjs');
// Load .env explicitly
dotenv.config({ path: path.resolve(__dirname, '../../.env') });
async function main() {
    const { db } = require('../db');
    const { users } = require('../db/schema');
    const { eq } = require('drizzle-orm');
    const email = 'test@test.com';
    const password = 'password123';
    console.log(`Checking for user: ${email}`);
    const existing = await db.select().from(users).where(eq(users.email, email)).limit(1);
    if (existing.length > 0) {
        await db.update(users).set({
            role: 'admin',
            roles: ['super-admin', 'admin'],
            isGuest: false,
            mustChangePassword: false,
            updatedAt: new Date()
        }).where(eq(users.id, existing[0].id));
        console.log(`Successfully promoted existing user ${email} to super admin.`);
    }
    else {
        const passwordHash = await bcrypt.hash(password, 12);
        await db.insert(users).values({
            email,
            passwordHash,
            role: 'admin',
            roles: ['super-admin', 'admin'],
            isGuest: false,
            mustChangePassword: false,
            updatedAt: new Date(),
        });
        console.log(`Successfully created and promoted user ${email} as super admin.`);
    }
    process.exit(0);
}
main().catch((error) => {
    console.error(error);
    process.exit(1);
});
//# sourceMappingURL=fix_test_admin.js.map