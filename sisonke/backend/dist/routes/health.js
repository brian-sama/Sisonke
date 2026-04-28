"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const errorHandler_1 = require("../middleware/errorHandler");
const router = (0, express_1.Router)();
// Health check endpoint
router.get('/', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    try {
        // Check database connection
        await db_1.db.select({ id: schema_1.users.id }).from(schema_1.users).limit(1);
        res.json({
            success: true,
            status: 'healthy',
            timestamp: new Date().toISOString(),
            version: '1.0.0',
            services: {
                database: 'connected',
                api: 'running',
            },
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            status: 'unhealthy',
            timestamp: new Date().toISOString(),
            error: 'Database connection failed',
            services: {
                database: 'disconnected',
                api: 'running',
            },
        });
    }
}));
// API status endpoint
router.get('/status', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    res.json({
        success: true,
        api: 'Sisonke Wellness API',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        endpoints: {
            auth: '/api/auth',
            resources: '/api/resources',
            questions: '/api/questions',
            emergency: '/api/emergency',
        },
        features: {
            authentication: true,
            resources: true,
            'anonymous-qa': true,
            'emergency-contacts': true,
            'offline-support': true,
        },
    });
}));
exports.default = router;
//# sourceMappingURL=health.js.map