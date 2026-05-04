import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { db } from '../db';
import { users } from '../db/schema';
import { eq, and } from 'drizzle-orm';
import { ChangePasswordSchema, LoginSchema, RegisterSchema, GuestSessionSchema } from '../types';
import { asyncHandler } from '../middleware/errorHandler';
import { authMiddleware } from '../middleware/auth';

const router = Router();

// Generate JWT token
const generateToken = (userId: string) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET not configured');
  }
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as any,
  });
};

// Register new user
router.post('/register', asyncHandler(async (req, res) => {
  const validatedData = RegisterSchema.parse(req.body);
  
  // Check if user already exists
  const existingUser = await db
    .select()
    .from(users)
    .where(eq(users.email, validatedData.email))
    .limit(1);

  if (existingUser.length > 0) {
    return res.status(400).json({
      success: false,
      error: 'User already exists with this email',
    });
  }

  // Hash password
  const saltRounds = 12;
  const passwordHash = await bcrypt.hash(validatedData.password, saltRounds);

  // Create user
  const newUser = await db
    .insert(users)
    .values({
      email: validatedData.email,
      passwordHash,
      role: 'user',
      roles: ['user'],
      isGuest: false,
    })
    .returning();

  const token = generateToken(newUser[0].id);

  res.status(201).json({
    success: true,
    data: {
      user: {
        id: newUser[0].id,
        email: newUser[0].email,
        role: newUser[0].role,
        roles: newUser[0].roles,
        isGuest: newUser[0].isGuest,
        mustChangePassword: newUser[0].mustChangePassword,
      },
      token,
    },
  });
}));

// Login user
router.post('/login', asyncHandler(async (req, res) => {
  const validatedData = LoginSchema.parse(req.body);

  // Find user
  const user = await db
    .select()
    .from(users)
    .where(eq(users.email, validatedData.email))
    .limit(1);

  if (user.length === 0) {
    return res.status(401).json({
      success: false,
      error: 'Invalid credentials',
    });
  }

  // Check password
  const isValidPassword = await bcrypt.compare(validatedData.password, user[0].passwordHash!);
  
  if (!isValidPassword) {
    return res.status(401).json({
      success: false,
      error: 'Invalid credentials',
    });
  }

  // Update last active
  await db
    .update(users)
    .set({ lastActiveAt: new Date() })
    .where(eq(users.id, user[0].id));

  const token = generateToken(user[0].id);

  res.json({
    success: true,
    data: {
      user: {
        id: user[0].id,
        email: user[0].email,
        role: user[0].role,
        roles: user[0].roles?.length ? user[0].roles : [user[0].role || 'guest'],
        isGuest: user[0].isGuest,
        mustChangePassword: user[0].mustChangePassword,
      },
      token,
    },
  });
}));

router.post('/change-password', authMiddleware, asyncHandler(async (req, res) => {
  const input = ChangePasswordSchema.parse(req.body);
  const [user] = await db.select().from(users).where(eq(users.id, req.user!.id)).limit(1);

  if (!user || !user.passwordHash) {
    return res.status(404).json({ success: false, error: 'Account not found.' });
  }

  if (!user.mustChangePassword) {
    if (!input.currentPassword) {
      return res.status(400).json({ success: false, error: 'Current password is required.' });
    }
    const isValidPassword = await bcrypt.compare(input.currentPassword, user.passwordHash);
    if (!isValidPassword) {
      return res.status(401).json({ success: false, error: 'Current password is incorrect.' });
    }
  }

  const passwordHash = await bcrypt.hash(input.newPassword, 12);
  await db.update(users).set({
    passwordHash,
    mustChangePassword: false,
    updatedAt: new Date(),
  }).where(eq(users.id, user.id));

  res.json({ success: true });
}));

// Create guest session
router.post('/guest', asyncHandler(async (req, res) => {
  const validatedData = GuestSessionSchema.parse(req.body);

  // Check if guest session already exists
  const existingGuest = await db
    .select()
    .from(users)
    .where(and(eq(users.deviceId, validatedData.deviceId), eq(users.isGuest, true)))
    .limit(1);

  if (existingGuest.length > 0) {
    // Update last active
    await db
      .update(users)
      .set({ lastActiveAt: new Date() })
      .where(eq(users.id, existingGuest[0].id));

    const token = generateToken(existingGuest[0].id);

    return res.json({
      success: true,
      data: {
        user: {
          id: existingGuest[0].id,
          role: existingGuest[0].role,
          roles: existingGuest[0].roles?.length ? existingGuest[0].roles : [existingGuest[0].role || 'guest'],
          isGuest: existingGuest[0].isGuest,
          mustChangePassword: existingGuest[0].mustChangePassword,
        },
        token,
      },
    });
  }

  // Create new guest user
  const newGuest = await db
    .insert(users)
    .values({
      deviceId: validatedData.deviceId,
      role: 'guest',
      roles: ['guest'],
      isGuest: true,
    })
    .returning();

  const token = generateToken(newGuest[0].id);

  res.status(201).json({
    success: true,
    data: {
      user: {
        id: newGuest[0].id,
        role: newGuest[0].role,
        roles: newGuest[0].roles,
        isGuest: newGuest[0].isGuest,
        mustChangePassword: newGuest[0].mustChangePassword,
      },
      token,
    },
  });
}));

// Refresh token
router.post('/refresh', asyncHandler(async (req, res) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      error: 'No token provided',
    });
  }

  const token = authHeader.substring(7);
  
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET not configured');
  }

  const decoded = jwt.verify(token, process.env.JWT_SECRET) as any;
  
  // Get user
  const user = await db
    .select()
    .from(users)
    .where(eq(users.id, decoded.userId))
    .limit(1);

  if (!user.length) {
    return res.status(401).json({
      success: false,
      error: 'Invalid token',
    });
  }

  // Update last active
  await db
    .update(users)
    .set({ lastActiveAt: new Date() })
    .where(eq(users.id, user[0].id));

  const newToken = generateToken(user[0].id);

  res.json({
    success: true,
    data: {
      token: newToken,
    },
  });
}));

export default router;
