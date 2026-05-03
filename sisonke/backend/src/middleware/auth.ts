import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';
import { db } from '../db';
import { users } from '../db/schema';
import { eq } from 'drizzle-orm';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email?: string;
    role: string;
    isGuest: boolean;
    deviceId?: string;
  };
}

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
    const user = await db.select().from(users).where(eq(users.id, decoded.userId)).limit(1);
    
    if (!user.length) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    if (user[0].isSuspended) {
      return res.status(403).json({ error: 'Account suspended' });
    }

    req.user = {
      id: user[0].id,
      email: user[0].email || undefined,
      role: user[0].role || 'guest',
      isGuest: user[0].isGuest ?? true,
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
    const user = await db.select().from(users).where(eq(users.id, decoded.userId)).limit(1);
    
    if (user.length) {
      if (user[0].isSuspended) return next();
      req.user = {
        id: user[0].id,
        email: user[0].email || undefined,
        role: user[0].role || 'guest',
        isGuest: user[0].isGuest ?? true,
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
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};
