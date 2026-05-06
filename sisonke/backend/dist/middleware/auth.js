"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.dashboardAccess = exports.superAdminOnly = exports.adminOnly = exports.optionalAuth = exports.authMiddleware = exports.hasPermission = exports.hasAnyRole = exports.hasRole = exports.SYSTEM_ADMIN_ROLES = exports.DASHBOARD_ROLES = exports.normalizeRole = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const authService_1 = require("../services/authService");
const normalizeRole = (role) => {
    const norm = String(role || '')
        .trim()
        .toLowerCase()
        .replace(/_/g, '-');
    return norm === 'counsellor' ? 'counselor' : norm;
};
exports.normalizeRole = normalizeRole;
exports.DASHBOARD_ROLES = [
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
exports.SYSTEM_ADMIN_ROLES = ['admin', 'system-admin', 'super-admin'];
const hasRole = (user, role) => {
    if (!user)
        return false;
    const normalized = (0, exports.normalizeRole)(role);
    return user.roles.map(exports.normalizeRole).includes(normalized);
};
exports.hasRole = hasRole;
const hasAnyRole = (user, roles) => {
    if (!user)
        return false;
    return roles.some((role) => (0, exports.hasRole)(user, role));
};
exports.hasAnyRole = hasAnyRole;
// Permission-based middleware helpers
const hasPermission = async (userId, permission) => {
    return await authService_1.AuthService.hasPermission(userId, permission);
};
exports.hasPermission = hasPermission;
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
        const user = await db_1.db
            .select({
            id: schema_1.users.id,
            email: schema_1.users.email,
            isGuest: schema_1.users.isGuest,
            mustChangePassword: schema_1.users.mustChangePassword,
            deviceId: schema_1.users.deviceId,
            isSuspended: schema_1.users.isSuspended,
        })
            .from(schema_1.users)
            .where((0, drizzle_orm_1.eq)(schema_1.users.id, decoded.userId))
            .limit(1);
        if (!user.length) {
            return res.status(401).json({ error: 'Invalid token' });
        }
        if (user[0].isSuspended) {
            return res.status(403).json({ error: 'Account suspended' });
        }
        // Get user roles from new role system
        const userRoles = await authService_1.AuthService.getUserRoles(user[0].id);
        req.user = {
            id: user[0].id,
            email: user[0].email || undefined,
            roles: userRoles.map(r => r.name).map(exports.normalizeRole),
            isGuest: user[0].isGuest ?? true,
            mustChangePassword: user[0].mustChangePassword ?? false,
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
        const user = await db_1.db
            .select({
            id: schema_1.users.id,
            email: schema_1.users.email,
            isGuest: schema_1.users.isGuest,
            mustChangePassword: schema_1.users.mustChangePassword,
            deviceId: schema_1.users.deviceId,
            isSuspended: schema_1.users.isSuspended,
        })
            .from(schema_1.users)
            .where((0, drizzle_orm_1.eq)(schema_1.users.id, decoded.userId))
            .limit(1);
        if (user.length) {
            if (user[0].isSuspended)
                return next();
            // Get user roles from new role system
            const userRoles = await authService_1.AuthService.getUserRoles(user[0].id);
            req.user = {
                id: user[0].id,
                email: user[0].email || undefined,
                roles: userRoles.map(r => r.name).map(exports.normalizeRole),
                isGuest: user[0].isGuest ?? true,
                mustChangePassword: user[0].mustChangePassword ?? false,
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
    if (!(0, exports.hasAnyRole)(req.user, exports.SYSTEM_ADMIN_ROLES)) {
        return res.status(403).json({ error: 'Admin access required' });
    }
    next();
};
exports.adminOnly = adminOnly;
const superAdminOnly = (req, res, next) => {
    if (!(0, exports.hasAnyRole)(req.user, ['super-admin', 'system-admin'])) {
        return res.status(403).json({ error: 'Super admin access required' });
    }
    next();
};
exports.superAdminOnly = superAdminOnly;
const dashboardAccess = (req, res, next) => {
    if (!(0, exports.hasAnyRole)(req.user, exports.DASHBOARD_ROLES)) {
        return res.status(403).json({ error: 'Dashboard access required' });
    }
    next();
};
exports.dashboardAccess = dashboardAccess;
//# sourceMappingURL=auth.js.map