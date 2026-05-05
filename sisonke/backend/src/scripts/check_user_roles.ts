
import 'dotenv/config';
import { db } from '../db';
import { users, userRoles, roles } from '../db/schema';
import { eq } from 'drizzle-orm';

async function checkUser(email: string) {
  console.log(`Checking user: ${email}`);
  const user = await db.select().from(users).where(eq(users.email, email)).limit(1);
  if (user.length === 0) {
    console.log('User not found');
    return;
  }

  const u = user[0];
  console.log('User found:', { id: u.id, email: u.email, isGuest: u.isGuest });

  const rolesData = await db
    .select({
      role: roles,
    })
    .from(userRoles)
    .innerJoin(roles, eq(userRoles.roleId, roles.id))
    .where(eq(userRoles.userId, u.id));

  console.log('Roles:', rolesData.map(r => r.role.name));
}

const email = process.argv[2] || 'test@sisonke.org';
checkUser(email).catch(console.error).finally(() => process.exit());
