import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { db } from '../db';
import { users } from '../db/schema';
import { eq } from 'drizzle-orm';
import { validateEnv } from '../env';
import { AuthService } from '../services/authService';

async function main() {
  validateEnv();

  const email = (process.env.ADMIN_EMAIL || '').trim().toLowerCase();
  const password = process.env.ADMIN_PASSWORD || '';

  if (!email || !password) {
    throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD are required.');
  }

  const existing = await db.select({ id: users.id }).from(users).where(eq(users.email, email)).limit(1);
  if (existing.length > 0) {
    await db.update(users).set({ isGuest: false, updatedAt: new Date() }).where(eq(users.id, existing[0].id));
    
    // Assign SUPER_ADMIN and ADMIN roles to existing user
    await AuthService.assignRole(existing[0].id, 'SUPER_ADMIN');
    await AuthService.assignRole(existing[0].id, 'ADMIN');
    
    console.log(`Promoted existing user ${email} to super admin.`);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const [newUser] = await db.insert(users).values({
    email,
    passwordHash,
    isGuest: false,
    updatedAt: new Date(),
  }).returning();

  // Assign SUPER_ADMIN and ADMIN roles to new user
  await AuthService.assignRole(newUser.id, 'SUPER_ADMIN');
  await AuthService.assignRole(newUser.id, 'ADMIN');
  
  console.log(`Created admin user ${email}.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
