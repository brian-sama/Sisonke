"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.superAdminOnly = exports.adminOnly = exports.optionalAuth = exports.authMiddleware = exports.hasAnyRole = exports.hasRole = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const hasRole = (user, role) => {
    if (!user)
        return false;
    return user.role === role || user.roles.includes(role);
};
exports.hasRole = hasRole;
const hasAnyRole = (user, roles) => {
    return roles.some((role) => (0, exports.hasRole)(user, role));
};
exports.hasAnyRole = hasAnyRole;
const authMiddleware = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'No token provided' });
        }
        const token = authHeader.substring(7);
        if (!process.env.JWT_SECRET) {
            throw new Error('JWT_SECRET not configured');
        }
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET);
        // Get user from database
        const user = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, decoded.userId)).limit(1);
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
            roles: user[0].roles?.length ? user[0].roles : [user[0].role || 'guest'],
            isGuest: user[0].isGuest ?? true,
            deviceId: user[0].deviceId || undefined,
        };
        next();
    }
    catch (error) {
        console.error('Auth error:', error);
        return res.status(401).json({ error: 'Invalid token' });
    }
};
exports.authMiddleware = authMiddleware;
const optionalAuth = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return next(); // No token, continue as guest
        }
        const token = authHeader.substring(7);
        if (!process.env.JWT_SECRET) {
            return next(); // No JWT secret, continue as guest
        }
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET);
        // Get user from database
        const user = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, decoded.userId)).limit(1);
        if (user.length) {
            if (user[0].isSuspended)
                return next();
            req.user = {
                id: user[0].id,
                email: user[0].email || undefined,
                role: user[0].role || 'guest',
                roles: user[0].roles?.length ? user[0].roles : [user[0].role || 'guest'],
                isGuest: user[0].isGuest ?? true,
                deviceId: user[0].deviceId || undefined,
            };
        }
        next();
    }
    catch (error) {
        // Continue as guest on any auth error
        next();
    }
};
exports.optionalAuth = optionalAuth;
const adminOnly = (req, res, next) => {
    if (!(0, exports.hasAnyRole)(req.user, ['admin', 'super-admin'])) {
        return res.status(403).json({ error: 'Admin access required' });
    }
    next();
};
exports.adminOnly = adminOnly;
const superAdminOnly = (req, res, next) => {
    if (!(0, exports.hasRole)(req.user, 'super-admin')) {
        return res.status(403).json({ error: 'Super admin access required' });
    }
    next();
};
exports.superAdminOnly = superAdminOnly;
//# sourceMappingURL=auth.js.map