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
export declare class AuthService {
    static getUserRoles(userId: string): Promise<{
        description: string | null;
        id: string;
        name: "USER" | "COUNSELOR" | "MODERATOR" | "CONTENT_ADMIN" | "ADMIN" | "SYSTEM_ADMIN" | "SUPER_ADMIN";
        permissions: unknown;
        createdAt: Date | null;
        updatedAt: Date | null;
    }[]>;
    static getUserPermissions(userId: string): Promise<Permission>;
    static hasPermission(userId: string, permission: keyof Permission): Promise<boolean>;
    static hasRole(userId: string, roleNames: string | string[]): Promise<boolean>;
    static canAccessResource(userId: string, resourceType: string, resourceId?: string): Promise<boolean>;
    static initializeRoles(): Promise<void>;
    static assignRole(userId: string, roleName: string, assignedBy?: string): Promise<{
        id: string;
        userId: string;
        roleId: string;
        assignedBy: string | null;
        assignedAt: Date | null;
    }>;
    static removeRole(userId: string, roleName: string): Promise<import("postgres").RowList<never[]>>;
}
//# sourceMappingURL=authService.d.ts.map