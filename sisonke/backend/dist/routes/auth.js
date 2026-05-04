"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const types_1 = require("../types");
const errorHandler_1 = require("../middleware/errorHandler");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
// Generate JWT token
const generateToken = (userId) => {
    if (!process.env.JWT_SECRET) {
        throw new Error('JWT_SECRET not configured');
    }
    return jsonwebtoken_1.default.sign({ userId }, process.env.JWT_SECRET, {
        expiresIn: (process.env.JWT_EXPIRES_IN || '7d'),
    });
};
// Register new user
router.post('/register', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const validatedData = types_1.RegisterSchema.parse(req.body);
    // Check if user already exists
    const existingUser = await db_1.db
        .select()
        .from(schema_1.users)
        .where((0, drizzle_orm_1.eq)(schema_1.users.email, validatedData.email))
        .limit(1);
    if (existingUser.length > 0) {
        return res.status(400).json({
            success: false,
            error: 'User already exists with this email',
        });
    }
    // Hash password
    const saltRounds = 12;
    const passwordHash = await bcryptjs_1.default.hash(validatedData.password, saltRounds);
    // Create user
    const newUser = await db_1.db
        .insert(schema_1.users)
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
router.post('/login', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const validatedData = types_1.LoginSchema.parse(req.body);
    // Find user
    const user = await db_1.db
        .select()
        .from(schema_1.users)
        .where((0, drizzle_orm_1.eq)(schema_1.users.email, validatedData.email))
        .limit(1);
    if (user.length === 0) {
        return res.status(401).json({
            success: false,
            error: 'Invalid credentials',
        });
    }
    // Check password
    const isValidPassword = await bcryptjs_1.default.compare(validatedData.password, user[0].passwordHash);
    if (!isValidPassword) {
        return res.status(401).json({
            success: false,
            error: 'Invalid credentials',
        });
    }
    // Update last active
    await db_1.db
        .update(schema_1.users)
        .set({ lastActiveAt: new Date() })
        .where((0, drizzle_orm_1.eq)(schema_1.users.id, user[0].id));
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
router.post('/change-password', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.ChangePasswordSchema.parse(req.body);
    const [user] = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.user.id)).limit(1);
    if (!user || !user.passwordHash) {
        return res.status(404).json({ success: false, error: 'Account not found.' });
    }
    if (!user.mustChangePassword) {
        if (!input.currentPassword) {
            return res.status(400).json({ success: false, error: 'Current password is required.' });
        }
        const isValidPassword = await bcryptjs_1.default.compare(input.currentPassword, user.passwordHash);
        if (!isValidPassword) {
            return res.status(401).json({ success: false, error: 'Current password is incorrect.' });
        }
    }
    const passwordHash = await bcryptjs_1.default.hash(input.newPassword, 12);
    await db_1.db.update(schema_1.users).set({
        passwordHash,
        mustChangePassword: false,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.users.id, user.id));
    res.json({ success: true });
}));
// Create guest session
router.post('/guest', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const validatedData = types_1.GuestSessionSchema.parse(req.body);
    // Check if guest session already exists
    const existingGuest = await db_1.db
        .select()
        .from(schema_1.users)
        .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.users.deviceId, validatedData.deviceId), (0, drizzle_orm_1.eq)(schema_1.users.isGuest, true)))
        .limit(1);
    if (existingGuest.length > 0) {
        // Update last active
        await db_1.db
            .update(schema_1.users)
            .set({ lastActiveAt: new Date() })
            .where((0, drizzle_orm_1.eq)(schema_1.users.id, existingGuest[0].id));
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
    const newGuest = await db_1.db
        .insert(schema_1.users)
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
router.post('/refresh', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
    const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET);
    // Get user
    const user = await db_1.db
        .select()
        .from(schema_1.users)
        .where((0, drizzle_orm_1.eq)(schema_1.users.id, decoded.userId))
        .limit(1);
    if (!user.length) {
        return res.status(401).json({
            success: false,
            error: 'Invalid token',
        });
    }
    // Update last active
    await db_1.db
        .update(schema_1.users)
        .set({ lastActiveAt: new Date() })
        .where((0, drizzle_orm_1.eq)(schema_1.users.id, user[0].id));
    const newToken = generateToken(user[0].id);
    res.json({
        success: true,
        data: {
            token: newToken,
        },
    });
}));
exports.default = router;
//# sourceMappingURL=auth.js.map