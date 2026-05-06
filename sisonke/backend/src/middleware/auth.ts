import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';
import { db } from '../db';
import { users } from '../db/schema';
import { eq } from 'drizzle-orm';
import { AuthService } from '../services/authService';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email?: string;
    roles: string[];
    isGuest: boolean;
    mustChangePassword: boolean;
    deviceId?: string;
  };
}

export const normalizeRole = (role: string | null | undefined) => {
  const norm = String(role || '')
    .trim()
    .toLowerCase()
    .replace(/_/g, '-');
  return norm === 'counsellor' ? 'counselor' : norm;
};

export const DASHBOARD_ROLES = [
  'admin',
  'system-admin', 
  'super-admin',
  'counselor',
  'moderator',
  'content-admin',
  'content-manager',
  'safety-reviewer',
  'analyst',
  'user',
];

export const SYSTEM_ADMIN_ROLES = ['admin', 'system-admin', 'super-admin'];

export const hasRole = (user: AuthRequest['user'] | undefined, role: string) => {
  if (!user) return false;
  const normalized = normalizeRole(role);
  return user.roles.map(normalizeRole).includes(normalized);
};

export const hasAnyRole = (user: AuthRequest['user'] | undefined, roles: string[]) => {
  if (!user) return false;
  return roles.some((role) => hasRole(user, role));
};

// Permission-based middleware helpers
export const hasPermission = async (userId: string, permission: string): Promise<boolean> => {
  return await AuthService.hasPermission(userId, permission as any);
};

export const authMiddleware = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);
    
    if (!process.env.JWT_SECRET) {
      throw new Error('JWT_SECRET not configured');
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET) as any;
    
    // Get user from database
    const user = await db
      .select({
        id: users.id,
        email: users.email,
        isGuest: users.isGuest,
        mustChangePassword: users.mustChangePassword,
        deviceId: users.deviceId,
        isSuspended: users.isSuspended,
      })
      .from(users)
      .where(eq(users.id, decoded.userId))
      .limit(1);
    
    if (!user.length) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    if (user[0].isSuspended) {
      return res.status(403).json({ error: 'Account suspended' });
    }

    // Get user roles from new role system
    const userRoles = await AuthService.getUserRoles(user[0].id);

    req.user = {
      id: user[0].id,
      email: user[0].email || undefined,
      roles: userRoles.map(r => r.name).map(normalizeRole),
      isGuest: user[0].isGuest ?? true,
      mustChangePassword: user[0].mustChangePassword ?? false,
      deviceId: user[0].deviceId || undefined,
    };

    next();
  } catch (error) {
    console.error('Auth error:', error);
    return res.status(401).json({ error: 'Invalid token' });
  }
};

export const optionalAuth = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(); // No token, continue as guest
    }

    const token = authHeader.substring(7);
    
    if (!process.env.JWT_SECRET) {
      return next(); // No JWT secret, continue as guest
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET) as any;
    
    // Get user from database
    const user = await db
      .select({
        id: users.id,
        email: users.email,
        isGuest: users.isGuest,
        mustChangePassword: users.mustChangePassword,
        deviceId: users.deviceId,
        isSuspended: users.isSuspended,
      })
      .from(users)
      .where(eq(users.id, decoded.userId))
      .limit(1);
    
    if (user.length) {
      if (user[0].isSuspended) return next();
      
      // Get user roles from new role system
      const userRoles = await AuthService.getUserRoles(user[0].id);
      
      req.user = {
        id: user[0].id,
        email: user[0].email || undefined,
        roles: userRoles.map(r => r.name).map(normalizeRole),
        isGuest: user[0].isGuest ?? true,
        mustChangePassword: user[0].mustChangePassword ?? false,
        deviceId: user[0].deviceId || undefined,
      };
    }

    next();
  } catch (error) {
    // Continue as guest on any auth error
    next();
  }
};

export const adminOnly = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!hasAnyRole(req.user, SYSTEM_ADMIN_ROLES)) {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

export const superAdminOnly = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!hasAnyRole(req.user, ['super-admin', 'system-admin'])) {
    return res.status(403).json({ error: 'Super admin access required' });
  }
  next();
};

export const dashboardAccess = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!hasAnyRole(req.user, DASHBOARD_ROLES)) {
    return res.status(403).json({ error: 'Dashboard access required' });
  }
  next();
};
