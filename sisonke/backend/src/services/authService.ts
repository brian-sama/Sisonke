import { db } from '../db';
import { users, roles, userRoles } from '../db/schema';
import { eq, inArray, and } from 'drizzle-orm';

export interface Permission {
  canCreateUsers: boolean;
  canAssignRoles: boolean;
  canViewAllCases: boolean;
  canReassignCases: boolean;
  canDeleteContent: boolean;
  canViewAnalytics: boolean;
  canExportReports: boolean;
  canViewAuditLogs: boolean;
  canModerateCommunity: boolean;
  canManageContent: boolean;
  canManageSystemSettings: boolean;
}

// Default permissions for each role
const ROLE_PERMISSIONS: Record<string, Permission> = {
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

export class AuthService {
  // Get user roles with permissions
  static async getUserRoles(userId: string) {
    const userRoleData = await db
      .select({
        role: roles,
      })
      .from(userRoles)
      .innerJoin(roles, eq(userRoles.roleId, roles.id))
      .where(eq(userRoles.userId, userId));

    return userRoleData.map(ur => ur.role);
  }

  // Get combined permissions for a user (union of all their roles)
  static async getUserPermissions(userId: string): Promise<Permission> {
    const userRoles = await this.getUserRoles(userId);
    
    const combinedPermissions: Permission = {
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
        combinedPermissions[key as keyof Permission] = 
          combinedPermissions[key as keyof Permission] || rolePermissions[key as keyof Permission];
      });
    }

    return combinedPermissions;
  }

  // Check if user has specific permission
  static async hasPermission(userId: string, permission: keyof Permission): Promise<boolean> {
    const permissions = await this.getUserPermissions(userId);
    return permissions[permission];
  }

  // Check if user has any of the specified roles
  static async hasRole(userId: string, roleNames: string | string[]): Promise<boolean> {
    const userRoles = await this.getUserRoles(userId);
    const targetRoles = Array.isArray(roleNames) ? roleNames : [roleNames];
    return userRoles.some(role => targetRoles.includes(role.name));
  }

  // Check if user can access a specific resource
  static async canAccessResource(
    userId: string, 
    resourceType: string, 
    resourceId?: string
  ): Promise<boolean> {
    const permissions = await this.getUserPermissions(userId);
    const userRoles = await this.getUserRoles(userId);

    switch (resourceType) {
      case 'admin_dashboard':
        return userRoles.some(role => 
          ['ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN'].includes(role.name)
        );

      case 'counselor_dashboard':
        return userRoles.some(role => 
          ['COUNSELOR', 'ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN'].includes(role.name)
        );

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
        name: 'USER' as const,
        description: 'Regular app user with access to wellness features',
        permissions: ROLE_PERMISSIONS.USER,
      },
      {
        name: 'COUNSELOR' as const,
        description: 'Mental health counselor providing support to users',
        permissions: ROLE_PERMISSIONS.COUNSELOR,
      },
      {
        name: 'MODERATOR' as const,
        description: 'Community moderator managing posts and reports',
        permissions: ROLE_PERMISSIONS.MODERATOR,
      },
      {
        name: 'CONTENT_ADMIN' as const,
        description: 'Content manager for resources and articles',
        permissions: ROLE_PERMISSIONS.CONTENT_ADMIN,
      },
      {
        name: 'ADMIN' as const,
        description: 'System administrator with broad access',
        permissions: ROLE_PERMISSIONS.ADMIN,
      },
      {
        name: 'SYSTEM_ADMIN' as const,
        description: 'System administrator with user management capabilities',
        permissions: ROLE_PERMISSIONS.SYSTEM_ADMIN,
      },
      {
        name: 'SUPER_ADMIN' as const,
        description: 'Super administrator with full system access',
        permissions: ROLE_PERMISSIONS.SUPER_ADMIN,
      },
    ];

    for (const roleData of defaultRoles) {
      const existing = await db
        .select()
        .from(roles)
        .where(eq(roles.name, roleData.name))
        .limit(1);

      if (existing.length === 0) {
        await db.insert(roles).values(roleData);
      }
    }
  }

  // Assign role to user
  static async assignRole(userId: string, roleName: string, assignedBy?: string) {
    const role = await db
      .select()
      .from(roles)
      .where(eq(roles.name, roleName as any))
      .limit(1);

    if (role.length === 0) {
      throw new Error(`Role ${roleName} not found`);
    }

    // Check if user already has this role
    const existing = await db
      .select()
      .from(userRoles)
      .where(
        and(
          eq(userRoles.userId, userId),
          eq(userRoles.roleId, role[0].id)
        )
      )
      .limit(1);

    if (existing.length > 0) {
      throw new Error(`User already has role ${roleName}`);
    }

    const [userRole] = await db
      .insert(userRoles)
      .values({
        userId,
        roleId: role[0].id,
        assignedBy,
      })
      .returning();

    return userRole;
  }

  // Remove role from user
  static async removeRole(userId: string, roleName: string) {
    const role = await db
      .select()
      .from(roles)
      .where(eq(roles.name, roleName as any))
      .limit(1);

    if (role.length === 0) {
      throw new Error(`Role ${roleName} not found`);
    }

    const result = await db
      .delete(userRoles)
      .where(
        and(
          eq(userRoles.userId, userId),
          eq(userRoles.roleId, role[0].id)
        )
      );

    return result;
  }
}
