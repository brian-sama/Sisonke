"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const http_1 = require("http");
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const path_1 = __importDefault(require("path"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const errorHandler_1 = require("./middleware/errorHandler");
const env_1 = require("./env");
const socketService_1 = require("./services/socketService");
// Import routes
const auth_1 = __importDefault(require("./routes/auth"));
const upload_1 = __importDefault(require("./routes/upload"));
const roles_1 = __importDefault(require("./routes/roles"));
const resources_1 = __importDefault(require("./routes/resources"));
const questions_1 = __importDefault(require("./routes/questions"));
const emergency_1 = __importDefault(require("./routes/emergency"));
const health_1 = __importDefault(require("./routes/health"));
const admin_1 = __importDefault(require("./routes/admin"));
const sync_1 = __importDefault(require("./routes/sync"));
const analytics_1 = __importDefault(require("./routes/analytics"));
const profiles_1 = __importDefault(require("./routes/profiles"));
const chatbot_1 = __importDefault(require("./routes/chatbot"));
const counselor_1 = __importDefault(require("./routes/counselor"));
const community_1 = __importDefault(require("./routes/community"));
const notifications_1 = __importDefault(require("./routes/notifications"));
(0, env_1.validateEnv)();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3001;
// Trust reverse proxy (Nginx) for correct rate-limiting IP mapping
app.set('trust proxy', 1);
// Rate limiting
const highFrequencyReadPaths = new Set([
    '/api/admin/community-posts',
    '/api/admin/counselor-cases',
    '/api/admin/counselor-operations',
]);
const highFrequencyReadPrefixes = [
    '/api/counselor/my-cases',
    '/api/counselor/cases',
];
const limiter = (0, express_rate_limit_1.default)({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // limit each IP to 100 requests per windowMs
    skip: (req) => req.method === 'GET' &&
        (highFrequencyReadPaths.has(req.path) ||
            highFrequencyReadPrefixes.some((prefix) => req.path.startsWith(prefix))),
    message: {
        success: false,
        error: 'Too many requests from this IP, please try again later.',
    },
    standardHeaders: true,
    legacyHeaders: false,
});
// Middleware
app.use((0, helmet_1.default)()); // Security headers
app.use(limiter); // Rate limiting
app.use((0, cors_1.default)({
    origin(origin, callback) {
        if (process.env.NODE_ENV !== 'production') {
            callback(null, true);
            return;
        }
        const allowedOrigins = (0, env_1.getAllowedOrigins)();
        const isAllowed = !origin || allowedOrigins.some((allowed) => {
            if (allowed instanceof RegExp) {
                return allowed.test(origin);
            }
            return allowed === origin;
        });
        if (isAllowed) {
            callback(null, true);
            return;
        }
        callback(new Error(`Origin ${origin} not allowed by CORS`));
    },
    credentials: true,
}));
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
// Host static files from the uploads directory
app.use('/uploads', express_1.default.static(path_1.default.join(__dirname, '../uploads')));
// Request logging
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});
// Routes
app.use('/api/health', health_1.default);
app.use('/api/upload', upload_1.default);
app.use('/api/auth', auth_1.default);
app.use('/api/roles', roles_1.default);
app.use('/api/resources', resources_1.default);
app.use('/api/questions', questions_1.default);
app.use('/api/emergency', emergency_1.default);
app.use('/api/sync', sync_1.default);
app.use('/api/analytics', analytics_1.default);
app.use('/api/profiles', profiles_1.default);
app.use('/api/chatbot', chatbot_1.default);
app.use('/api/counselor', counselor_1.default);
app.use('/api/community', community_1.default);
app.use('/api/notifications', notifications_1.default);
app.use('/api/admin', admin_1.default);
// Root endpoint
app.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'Sisonke Wellness API',
        version: '1.0.0',
        status: 'running',
        endpoints: {
            health: '/api/health',
            auth: '/api/auth',
            resources: '/api/resources',
            questions: '/api/questions',
            emergency: '/api/emergency',
            sync: '/api/sync',
            analytics: '/api/analytics',
            profiles: '/api/profiles',
            chatbot: '/api/chatbot',
            counselor: '/api/counselor',
            community: '/api/community',
            admin: '/api/admin',
        },
        documentation: 'https://github.com/sisonke/api-docs',
    });
});
// Error handling
app.use(errorHandler_1.notFound);
app.use(errorHandler_1.errorHandler);
// Start server
const httpServer = (0, http_1.createServer)(app);
socketService_1.SocketService.init(httpServer);
httpServer.listen(PORT, () => {
    console.log(`🚀 Sisonke API Server running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
    console.log(`📚 API status: http://localhost:${PORT}/api/health/status`);
    console.log(`🔐 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log('💬 Socket.io initialized for real-time support');
});
exports.default = app;
//# sourceMappingURL=index.js.map