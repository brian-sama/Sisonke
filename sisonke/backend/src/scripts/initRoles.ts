import 'dotenv/config';
import { db } from '../db';
import { roles } from '../db/schema';
import { AuthService } from '../services/authService';

async function initializeRoles() {
  try {
    console.log('Initializing roles...');
    await AuthService.initializeRoles();
    console.log('✓ Roles initialized successfully');
  } catch (error) {
    console.error('✗ Failed to initialize roles:', error);
  }
}

initializeRoles().then(() => {
  console.log('Role initialization completed');
  process.exit(0);
}).catch((error) => {
  console.error('Role initialization failed:', error);
  process.exit(1);
});
