"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const errorHandler_1 = require("../middleware/errorHandler");
const auth_1 = require("../middleware/auth");
const authService_1 = require("../services/authService");
const auditService_1 = require("../services/auditService");
const router = (0, express_1.Router)();
// Role assignment schemas
const AssignRoleSchema = zod_1.z.object({
    userId: zod_1.z.string().uuid(),
    roleName: zod_1.z.enum(['USER', 'COUNSELOR', 'MODERATOR', 'CONTENT_ADMIN', 'ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN']),
});
const RemoveRoleSchema = zod_1.z.object({
    userId: zod_1.z.string().uuid(),
    roleName: zod_1.z.enum(['USER', 'COUNSELOR', 'MODERATOR', 'CONTENT_ADMIN', 'ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN']),
});
// Initialize default roles (for system setup)
router.post('/initialize', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    await authService_1.AuthService.initializeRoles();
    res.json({
        success: true,
        message: 'Default roles initialized successfully',
    });
}));
// Get all roles
router.get('/', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    // Check if user has permission to view roles
    const hasPermission = await authService_1.AuthService.hasPermission(req.user.id, 'canViewAuditLogs');
    if (!hasPermission) {
        return res.status(403).json({
            success: false,
            error: 'Insufficient permissions',
        });
    }
    const allRoles = await db_1.db.select().from(schema_1.roles);
    res.json({
        success: true,
        data: allRoles,
    });
}));
// Get user roles
router.get('/user/:userId', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { userId } = req.params;
    // Users can only view their own roles unless they have elevated permissions
    if (userId !== req.user.id) {
        const hasPermission = await authService_1.AuthService.hasPermission(req.user.id, 'canViewAuditLogs');
        if (!hasPermission) {
            return res.status(403).json({
                success: false,
                error: 'Insufficient permissions',
            });
        }
    }
    const userRoles = await authService_1.AuthService.getUserRoles(userId);
    res.json({
        success: true,
        data: userRoles,
    });
}));
// Assign role to user
router.post('/assign', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const validatedData = AssignRoleSchema.parse(req.body);
    // Check if user has permission to assign roles
    const hasPermission = await authService_1.AuthService.hasPermission(req.user.id, 'canAssignRoles');
    if (!hasPermission) {
        return res.status(403).json({
            success: false,
            error: 'Insufficient permissions to assign roles',
        });
    }
    try {
        await authService_1.AuthService.assignRole(validatedData.userId, validatedData.roleName, req.user.id);
        // Log the role assignment
        await auditService_1.AuditService.log({
            actorId: req.user.id,
            action: 'role_assigned',
            entityType: 'user',
            entityId: validatedData.userId,
            metadata: {
                roleName: validatedData.roleName,
                assignedBy: req.user.id,
            },
        });
        res.json({
            success: true,
            message: `Role ${validatedData.roleName} assigned to user successfully`,
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            error: error instanceof Error ? error.message : 'Failed to assign role',
        });
    }
}));
// Remove role from user
router.post('/remove', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const validatedData = RemoveRoleSchema.parse(req.body);
    // Check if user has permission to assign roles (same permission for removing)
    const hasPermission = await authService_1.AuthService.hasPermission(req.user.id, 'canAssignRoles');
    if (!hasPermission) {
        return res.status(403).json({
            success: false,
            error: 'Insufficient permissions to remove roles',
        });
    }
    try {
        await authService_1.AuthService.removeRole(validatedData.userId, validatedData.roleName);
        // Log the role removal
        await auditService_1.AuditService.log({
            actorId: req.user.id,
            action: 'role_removed',
            entityType: 'user',
            entityId: validatedData.userId,
            metadata: {
                roleName: validatedData.roleName,
                removedBy: req.user.id,
            },
        });
        res.json({
            success: true,
            message: `Role ${validatedData.roleName} removed from user successfully`,
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            error: error instanceof Error ? error.message : 'Failed to remove role',
        });
    }
}));
// Get user permissions
router.get('/permissions/:userId', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { userId } = req.params;
    // Users can only view their own permissions unless they have elevated permissions
    if (userId !== req.user.id) {
        const hasPermission = await authService_1.AuthService.hasPermission(req.user.id, 'canViewAuditLogs');
        if (!hasPermission) {
            return res.status(403).json({
                success: false,
                error: 'Insufficient permissions',
            });
        }
    }
    const permissions = await authService_1.AuthService.getUserPermissions(userId);
    res.json({
        success: true,
        data: permissions,
    });
}));
// Check if user has specific permission
router.post('/check-permission', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { permission, userId } = req.body;
    // Default to current user if no userId provided
    const targetUserId = userId || req.user.id;
    // Users can only check their own permissions unless they have elevated permissions
    if (targetUserId !== req.user.id) {
        const hasPermission = await authService_1.AuthService.hasPermission(req.user.id, 'canViewAuditLogs');
        if (!hasPermission) {
            return res.status(403).json({
                success: false,
                error: 'Insufficient permissions',
            });
        }
    }
    const hasPermissionResult = await authService_1.AuthService.hasPermission(targetUserId, permission);
    res.json({
        success: true,
        data: {
            hasPermission: hasPermissionResult,
            permission,
            userId: targetUserId,
        },
    });
}));
// Check if user has specific role
router.post('/check-role', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { role, userId } = req.body;
    // Default to current user if no userId provided
    const targetUserId = userId || req.user.id;
    // Users can only check their own roles unless they have elevated permissions
    if (targetUserId !== req.user.id) {
        const hasPermission = await authService_1.AuthService.hasPermission(req.user.id, 'canViewAuditLogs');
        if (!hasPermission) {
            return res.status(403).json({
                success: false,
                error: 'Insufficient permissions',
            });
        }
    }
    const hasRole = await authService_1.AuthService.hasRole(targetUserId, role);
    res.json({
        success: true,
        data: {
            hasRole,
            role,
            userId: targetUserId,
        },
    });
}));
exports.default = router;
//# sourceMappingURL=roles.js.map