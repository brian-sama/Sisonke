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
    const configured = process.env.ALLOWED_ORIGINS || process.env.FRONTEND_URL || 'http://localhost:5173';
    const origins = configured.split(',').map((o) => o.trim()).filter(Boolean);
    // Add production domain
    if (!origins.includes('https://sisonke.mmpzmne.co.zw')) {
        origins.push('https://sisonke.mmpzmne.co.zw');
    }
    // Always allow any localhost port for easier dev/debug
    origins.push(/^http:\/\/localhost:\d+$/);
    return origins;
}
//# sourceMappingURL=env.js.map