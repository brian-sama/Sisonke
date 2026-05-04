import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { db } from '../db';
import { users } from '../db/schema';
import { eq } from 'drizzle-orm';
import { validateEnv } from '../env';

async function main() {
  validateEnv();

  const email = (process.env.ADMIN_EMAIL || '').trim().toLowerCase();
  const password = process.env.ADMIN_PASSWORD || '';

  if (!email || password.length < 12) {
    throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD with at least 12 characters are required.');
  }

  const existing = await db.select().from(users).where(eq(users.email, email)).limit(1);
  if (existing.length > 0) {
    await db.update(users).set({ role: 'admin', roles: ['super-admin', 'admin'], isGuest: false, updatedAt: new Date() }).where(eq(users.id, existing[0].id));
    console.log(`Promoted existing user ${email} to super admin.`);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);
  await db.insert(users).values({
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
