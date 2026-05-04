"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const http_1 = require("http");
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const dotenv_1 = __importDefault(require("dotenv"));
const errorHandler_1 = require("./middleware/errorHandler");
const env_1 = require("./env");
const socketService_1 = require("./services/socketService");
// Import routes
const auth_1 = __importDefault(require("./routes/auth"));
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
// Load environment variables
dotenv_1.default.config();
(0, env_1.validateEnv)();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3001;
// Rate limiting
const limiter = (0, express_rate_limit_1.default)({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // limit each IP to 100 requests per windowMs
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
        const allowedOrigins = (0, env_1.getAllowedOrigins)();
        if (!origin || allowedOrigins.includes(origin)) {
            callback(null, true);
            return;
        }
        callback(new Error('Origin not allowed by CORS'));
    },
    credentials: true,
}));
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
// Request logging
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});
// Routes
app.use('/api/health', health_1.default);
app.use('/api/auth', auth_1.default);
app.use('/api/resources', resources_1.default);
app.use('/api/questions', questions_1.default);
app.use('/api/emergency', emergency_1.default);
app.use('/api/sync', sync_1.default);
app.use('/api/analytics', analytics_1.default);
app.use('/api/profiles', profiles_1.default);
app.use('/api/chatbot', chatbot_1.default);
app.use('/api/counselor', counselor_1.default);
app.use('/api/community', community_1.default);
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