"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.migrateRoles = migrateRoles;
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const authService_1 = require("../services/authService");
async function migrateRoles() {
    console.log('Starting role migration...');
    try {
        // Initialize default roles
        await authService_1.AuthService.initializeRoles();
        console.log('✓ Default roles created');
        // Migrate existing users from old role system to new multi-role system
        const { users } = await Promise.resolve().then(() => __importStar(require('../db/schema')));
        const { eq } = await Promise.resolve().then(() => __importStar(require('drizzle-orm')));
        // Get all users with old role data
        const existingUsers = await db_1.db.select().from(users);
        for (const user of existingUsers) {
            // Skip if user already has roles assigned
            const existingUserRoles = await db_1.db.select().from(schema_1.userRoles).where(eq(schema_1.userRoles.userId, user.id));
            if (existingUserRoles.length === 0) {
                // Assign USER role to all existing users
                try {
                    await authService_1.AuthService.assignRole(user.id, 'USER');
                    console.log(`✓ Assigned USER role to user ${user.id}`);
                }
                catch (error) {
                    console.error(`✗ Failed to assign role to user ${user.id}:`, error);
                }
            }
        }
        console.log('✓ Role migration completed successfully');
    }
    catch (error) {
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
//# sourceMappingURL=migrateRoles.js.map