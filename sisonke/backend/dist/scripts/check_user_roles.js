"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
async function checkUser(email) {
    console.log(`Checking user: ${email}`);
    const user = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.email, email)).limit(1);
    if (user.length === 0) {
        console.log('User not found');
        return;
    }
    const u = user[0];
    console.log('User found:', { id: u.id, email: u.email, isGuest: u.isGuest });
    const rolesData = await db_1.db
        .select({
        role: schema_1.roles,
    })
        .from(schema_1.userRoles)
        .innerJoin(schema_1.roles, (0, drizzle_orm_1.eq)(schema_1.userRoles.roleId, schema_1.roles.id))
        .where((0, drizzle_orm_1.eq)(schema_1.userRoles.userId, u.id));
    console.log('Roles:', rolesData.map(r => r.role.name));
}
const email = process.argv[2] || 'test@sisonke.org';
checkUser(email).catch(console.error).finally(() => process.exit());
//# sourceMappingURL=check_user_roles.js.map