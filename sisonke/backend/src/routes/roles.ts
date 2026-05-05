import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { users, roles, userRoles } from '../db/schema';
import { eq, and } from 'drizzle-orm';
import { asyncHandler } from '../middleware/errorHandler';
import { authMiddleware } from '../middleware/auth';
import { AuthService } from '../services/authService';
import { AuditService } from '../services/auditService';

const router = Router();

// Role assignment schemas
const AssignRoleSchema = z.object({
  userId: z.string().uuid(),
  roleName: z.enum(['USER', 'COUNSELOR', 'MODERATOR', 'CONTENT_ADMIN', 'ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN']),
});

const RemoveRoleSchema = z.object({
  userId: z.string().uuid(),
  roleName: z.enum(['USER', 'COUNSELOR', 'MODERATOR', 'CONTENT_ADMIN', 'ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN']),
});

// Initialize default roles (for system setup)
router.post('/initialize', asyncHandler(async (req, res) => {
  await AuthService.initializeRoles();
  
  res.json({
    success: true,
    message: 'Default roles initialized successfully',
  });
}));

// Get all roles
router.get('/', authMiddleware, asyncHandler(async (req, res) => {
  // Check if user has permission to view roles
  const hasPermission = await AuthService.hasPermission(req.user!.id, 'canViewAuditLogs');
  if (!hasPermission) {
    return res.status(403).json({
      success: false,
      error: 'Insufficient permissions',
    });
  }

  const allRoles = await db.select().from(roles);
  
  res.json({
    success: true,
    data: allRoles,
  });
}));

// Get user roles
router.get('/user/:userId', authMiddleware, asyncHandler(async (req, res) => {
  const { userId } = req.params;
  
  // Users can only view their own roles unless they have elevated permissions
  if (userId !== req.user!.id) {
    const hasPermission = await AuthService.hasPermission(req.user!.id, 'canViewAuditLogs');
    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: 'Insufficient permissions',
      });
    }
  }

  const userRoles = await AuthService.getUserRoles(userId);
  
  res.json({
    success: true,
    data: userRoles,
  });
}));

// Assign role to user
router.post('/assign', authMiddleware, asyncHandler(async (req, res) => {
  const validatedData = AssignRoleSchema.parse(req.body);
  
  // Check if user has permission to assign roles
  const hasPermission = await AuthService.hasPermission(req.user!.id, 'canAssignRoles');
  if (!hasPermission) {
    return res.status(403).json({
      success: false,
      error: 'Insufficient permissions to assign roles',
    });
  }

  try {
    await AuthService.assignRole(validatedData.userId, validatedData.roleName, req.user!.id);
    
    // Log the role assignment
    await AuditService.log({
      actorId: req.user!.id,
      action: 'role_assigned',
      entityType: 'user',
      entityId: validatedData.userId,
      metadata: {
        roleName: validatedData.roleName,
        assignedBy: req.user!.id,
      },
    });

    res.json({
      success: true,
      message: `Role ${validatedData.roleName} assigned to user successfully`,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : 'Failed to assign role',
    });
  }
}));

// Remove role from user
router.post('/remove', authMiddleware, asyncHandler(async (req, res) => {
  const validatedData = RemoveRoleSchema.parse(req.body);
  
  // Check if user has permission to assign roles (same permission for removing)
  const hasPermission = await AuthService.hasPermission(req.user!.id, 'canAssignRoles');
  if (!hasPermission) {
    return res.status(403).json({
      success: false,
      error: 'Insufficient permissions to remove roles',
    });
  }

  try {
    await AuthService.removeRole(validatedData.userId, validatedData.roleName);
    
    // Log the role removal
    await AuditService.log({
      actorId: req.user!.id,
      action: 'role_removed',
      entityType: 'user',
      entityId: validatedData.userId,
      metadata: {
        roleName: validatedData.roleName,
        removedBy: req.user!.id,
      },
    });

    res.json({
      success: true,
      message: `Role ${validatedData.roleName} removed from user successfully`,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : 'Failed to remove role',
    });
  }
}));

// Get user permissions
router.get('/permissions/:userId', authMiddleware, asyncHandler(async (req, res) => {
  const { userId } = req.params;
  
  // Users can only view their own permissions unless they have elevated permissions
  if (userId !== req.user!.id) {
    const hasPermission = await AuthService.hasPermission(req.user!.id, 'canViewAuditLogs');
    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: 'Insufficient permissions',
      });
    }
  }

  const permissions = await AuthService.getUserPermissions(userId);
  
  res.json({
    success: true,
    data: permissions,
  });
}));

// Check if user has specific permission
router.post('/check-permission', authMiddleware, asyncHandler(async (req, res) => {
  const { permission, userId } = req.body;
  
  // Default to current user if no userId provided
  const targetUserId = userId || req.user!.id;
  
  // Users can only check their own permissions unless they have elevated permissions
  if (targetUserId !== req.user!.id) {
    const hasPermission = await AuthService.hasPermission(req.user!.id, 'canViewAuditLogs');
    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: 'Insufficient permissions',
      });
    }
  }

  const hasPermissionResult = await AuthService.hasPermission(targetUserId, permission);
  
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
router.post('/check-role', authMiddleware, asyncHandler(async (req, res) => {
  const { role, userId } = req.body;
  
  // Default to current user if no userId provided
  const targetUserId = userId || req.user!.id;
  
  // Users can only check their own roles unless they have elevated permissions
  if (targetUserId !== req.user!.id) {
    const hasPermission = await AuthService.hasPermission(req.user!.id, 'canViewAuditLogs');
    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: 'Insufficient permissions',
      });
    }
  }

  const hasRole = await AuthService.hasRole(targetUserId, role);
  
  res.json({
    success: true,
    data: {
      hasRole,
      role,
      userId: targetUserId,
    },
  });
}));

export default router;
