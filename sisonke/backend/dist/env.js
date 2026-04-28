"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateEnv = validateEnv;
exports.getAllowedOrigins = getAllowedOrigins;
const required = ['DATABASE_URL', 'JWT_SECRET'];
function validateEnv() {
    const missing = required.filter((key) => !process.env[key]);
    if (missing.length > 0) {
        throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
    }
    if ((process.env.JWT_SECRET || '').length < 32) {
        throw new Error('JWT_SECRET must be at least 32 characters long');
    }
}
function getAllowedOrigins() {
    const configured = process.env.FRONTEND_URL || 'http://localhost:3000';
    return configured.split(',').map((origin) => origin.trim()).filter(Boolean);
}
//# sourceMappingURL=env.js.map