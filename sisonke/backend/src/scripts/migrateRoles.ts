import { db } from '../db';
import { roles, userRoles } from '../db/schema';
import { AuthService } from '../services/authService';

async function migrateRoles() {
  console.log('Starting role migration...');
  
  try {
    // Initialize default roles
    await AuthService.initializeRoles();
    console.log('✓ Default roles created');
    
    // Migrate existing users from old role system to new multi-role system
    const { users } = await import('../db/schema');
    const { eq } = await import('drizzle-orm');
    
    // Get all users with old role data
    const existingUsers = await db.select().from(users);
    
    for (const user of existingUsers) {
      // Skip if user already has roles assigned
      const existingUserRoles = await db.select().from(userRoles).where(eq(userRoles.userId, user.id));
      
      if (existingUserRoles.length === 0) {
        // Assign USER role to all existing users
        try {
          await AuthService.assignRole(user.id, 'USER');
          console.log(`✓ Assigned USER role to user ${user.id}`);
        } catch (error) {
          console.error(`✗ Failed to assign role to user ${user.id}:`, error);
        }
      }
    }
    
    console.log('✓ Role migration completed successfully');
  } catch (error) {
    console.error('✗ Role migration failed:', error);
    process.exit(1);
  }
}

// Run migration if this file is executed directly
if (require.main === module) {
  migrateRoles()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error('Migration failed:', error);
      process.exit(1);
    });
}

export { migrateRoles };
