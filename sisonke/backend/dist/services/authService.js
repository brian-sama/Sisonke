"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
// Default permissions for each role
const ROLE_PERMISSIONS = {
    USER: {
        canCreateUsers: false,
        canAssignRoles: false,
        canViewAllCases: false,
        canReassignCases: false,
        canDeleteContent: false,
        canViewAnalytics: false,
        canExportReports: false,
        canViewAuditLogs: false,
        canModerateCommunity: false,
        canManageContent: false,
        canManageSystemSettings: false,
    },
    COUNSELOR: {
        canCreateUsers: false,
        canAssignRoles: false,
        canViewAllCases: false, // Only assigned cases
        canReassignCases: true, // Can reassign their own cases
        canDeleteContent: false,
        canViewAnalytics: false, // Only their own analytics
        canExportReports: false, // Only their own reports
        canViewAuditLogs: false,
        canModerateCommunity: false,
        canManageContent: false,
        canManageSystemSettings: false,
    },
    MODERATOR: {
        canCreateUsers: false,
        canAssignRoles: false,
        canViewAllCases: false,
        canReassignCases: false,
        canDeleteContent: false, // Can remove posts but not delete content
        canViewAnalytics: false,
        canExportReports: false,
        canViewAuditLogs: false,
        canModerateCommunity: true,
        canManageContent: false,
        canManageSystemSettings: false,
    },
    CONTENT_ADMIN: {
        canCreateUsers: false,
        canAssignRoles: false,
        canViewAllCases: false,
        canReassignCases: false,
        canDeleteContent: false,
        canViewAnalytics: false,
        canExportReports: false,
        canViewAuditLogs: false,
        canModerateCommunity: false,
        canManageContent: true,
        canManageSystemSettings: false,
    },
    ADMIN: {
        canCreateUsers: false,
        canAssignRoles: false,
        canViewAllCases: false, // Only metadata, not private content
        canReassignCases: true,
        canDeleteContent: true,
        canViewAnalytics: true,
        canExportReports: true,
        canViewAuditLogs: true,
        canModerateCommunity: true,
        canManageContent: true,
        canManageSystemSettings: false,
    },
    SYSTEM_ADMIN: {
        canCreateUsers: true,
        canAssignRoles: true,
        canViewAllCases: false, // Only metadata for assignment
        canReassignCases: true,
        canDeleteContent: true,
        canViewAnalytics: true,
        canExportReports: true,
        canViewAuditLogs: true,
        canModerateCommunity: true,
        canManageContent: true,
        canManageSystemSettings: true,
    },
    SUPER_ADMIN: {
        canCreateUsers: true,
        canAssignRoles: true,
        canViewAllCases: false, // Only metadata for assignment
        canReassignCases: true,
        canDeleteContent: true,
        canViewAnalytics: true,
        canExportReports: true,
        canViewAuditLogs: true,
        canModerateCommunity: true,
        canManageContent: true,
        canManageSystemSettings: true,
    },
};
const normalizeRoleName = (name) => {
    const normalized = name.trim().toLowerCase().replace(/_/g, '-');
    switch (normalized) {
        case 'super-admin':
            return 'SUPER_ADMIN';
        case 'system-admin':
            return 'SYSTEM_ADMIN';
        case 'admin':
            return 'ADMIN';
        case 'counselor':
        case 'counsellor':
            return 'COUNSELOR';
        case 'moderator':
        case 'community-helper':
            return 'MODERATOR';
        case 'content-manager':
        case 'content-admin':
        case 'content-helper':
            return 'CONTENT_ADMIN';
        case 'user':
        case 'app-user':
            return 'USER';
        default:
            return name.toUpperCase().replace(/-/g, '_');
    }
};
class AuthService {
    // Get user roles with permissions
    static async getUserRoles(userId) {
        const userRoleData = await db_1.db
            .select({
            role: schema_1.roles,
        })
            .from(schema_1.userRoles)
            .innerJoin(schema_1.roles, (0, drizzle_orm_1.eq)(schema_1.userRoles.roleId, schema_1.roles.id))
            .where((0, drizzle_orm_1.eq)(schema_1.userRoles.userId, userId));
        return userRoleData.map(ur => ur.role);
    }
    // Get combined permissions for a user (union of all their roles)
    static async getUserPermissions(userId) {
        const userRoles = await this.getUserRoles(userId);
        const combinedPermissions = {
            canCreateUsers: false,
            canAssignRoles: false,
            canViewAllCases: false,
            canReassignCases: false,
            canDeleteContent: false,
            canViewAnalytics: false,
            canExportReports: false,
            canViewAuditLogs: false,
            canModerateCommunity: false,
            canManageContent: false,
            canManageSystemSettings: false,
        };
        // Combine permissions from all roles (union of permissions)
        for (const role of userRoles) {
            const rolePermissions = ROLE_PERMISSIONS[role.name] || ROLE_PERMISSIONS.USER;
            Object.keys(combinedPermissions).forEach(key => {
                combinedPermissions[key] =
                    combinedPermissions[key] || rolePermissions[key];
            });
        }
        return combinedPermissions;
    }
    // Check if user has specific permission
    static async hasPermission(userId, permission) {
        const permissions = await this.getUserPermissions(userId);
        return permissions[permission];
    }
    // Check if user has any of the specified roles
    static async hasRole(userId, roleNames) {
        const userRoles = await this.getUserRoles(userId);
        const targetRoles = (Array.isArray(roleNames) ? roleNames : [roleNames]).map(r => normalizeRoleName(r));
        return userRoles.some(role => targetRoles.includes(role.name));
    }
    // Check if user can access a specific resource
    static async canAccessResource(userId, resourceType, resourceId) {
        const permissions = await this.getUserPermissions(userId);
        const userRoles = await this.getUserRoles(userId);
        switch (resourceType) {
            case 'admin_dashboard':
                return userRoles.some(role => ['ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN'].includes(role.name));
            case 'counselor_dashboard':
                return userRoles.some(role => ['COUNSELOR', 'ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN'].includes(role.name));
            case 'cases':
                // Counselors can only see their assigned cases
                if (await this.hasRole(userId, 'COUNSELOR')) {
                    return true; // Will be filtered by assigned counselor in the route
                }
                // Admins can see case metadata
                return await this.hasRole(userId, ['ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN']);
            case 'community_moderation':
                return permissions.canModerateCommunity;
            case 'content_management':
                return permissions.canManageContent;
            case 'user_management':
                return permissions.canCreateUsers;
            case 'system_settings':
                return permissions.canManageSystemSettings;
            case 'analytics':
                return permissions.canViewAnalytics;
            case 'audit_logs':
                return permissions.canViewAuditLogs;
            default:
                return false;
        }
    }
    // Initialize default roles in database
    static async initializeRoles() {
        const defaultRoles = [
            {
                name: 'USER',
                description: 'Regular app user with access to wellness features',
                permissions: ROLE_PERMISSIONS.USER,
            },
            {
                name: 'COUNSELOR',
                description: 'Mental health counselor providing support to users',
                permissions: ROLE_PERMISSIONS.COUNSELOR,
            },
            {
                name: 'MODERATOR',
                description: 'Community moderator managing posts and reports',
                permissions: ROLE_PERMISSIONS.MODERATOR,
            },
            {
                name: 'CONTENT_ADMIN',
                description: 'Content manager for resources and articles',
                permissions: ROLE_PERMISSIONS.CONTENT_ADMIN,
            },
            {
                name: 'ADMIN',
                description: 'System administrator with broad access',
                permissions: ROLE_PERMISSIONS.ADMIN,
            },
            {
                name: 'SYSTEM_ADMIN',
                description: 'System administrator with user management capabilities',
                permissions: ROLE_PERMISSIONS.SYSTEM_ADMIN,
            },
            {
                name: 'SUPER_ADMIN',
                description: 'Super administrator with full system access',
                permissions: ROLE_PERMISSIONS.SUPER_ADMIN,
            },
        ];
        for (const roleData of defaultRoles) {
            const existing = await db_1.db
                .select()
                .from(schema_1.roles)
                .where((0, drizzle_orm_1.eq)(schema_1.roles.name, roleData.name))
                .limit(1);
            if (existing.length === 0) {
                await db_1.db.insert(schema_1.roles).values(roleData);
            }
        }
    }
    // Assign role to user
    static async assignRole(userId, roleName, assignedBy) {
        const dbRoleName = normalizeRoleName(roleName);
        const role = await db_1.db
            .select()
            .from(schema_1.roles)
            .where((0, drizzle_orm_1.eq)(schema_1.roles.name, dbRoleName))
            .limit(1);
        if (role.length === 0) {
            throw new Error(`Role ${roleName} (mapped to ${dbRoleName}) not found`);
        }
        // Check if user already has this role
        const existing = await db_1.db
            .select()
            .from(schema_1.userRoles)
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.userRoles.userId, userId), (0, drizzle_orm_1.eq)(schema_1.userRoles.roleId, role[0].id)))
            .limit(1);
        if (existing.length > 0) {
            return null; // Gracefully return if user already has this role
        }
        const [userRole] = await db_1.db
            .insert(schema_1.userRoles)
            .values({
            userId,
            roleId: role[0].id,
            assignedBy,
        })
            .returning();
        return userRole;
    }
    // Remove role from user
    static async removeRole(userId, roleName) {
        const dbRoleName = normalizeRoleName(roleName);
        const role = await db_1.db
            .select()
            .from(schema_1.roles)
            .where((0, drizzle_orm_1.eq)(schema_1.roles.name, dbRoleName))
            .limit(1);
        if (role.length === 0) {
            throw new Error(`Role ${roleName} not found`);
        }
        const result = await db_1.db
            .delete(schema_1.userRoles)
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.userRoles.userId, userId), (0, drizzle_orm_1.eq)(schema_1.userRoles.roleId, role[0].id)));
        return result;
    }
}
exports.AuthService = AuthService;
//# sourceMappingURL=authService.js.map