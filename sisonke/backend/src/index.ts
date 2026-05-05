import express from 'express';
import { createServer } from 'http';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { notFound, errorHandler } from './middleware/errorHandler';
import { getAllowedOrigins, validateEnv } from './env';
import { SocketService } from './services/socketService';

// Import routes
import authRoutes from './routes/auth';
import rolesRoutes from './routes/roles';
import resourceRoutes from './routes/resources';
import questionRoutes from './routes/questions';
import emergencyRoutes from './routes/emergency';
import healthRoutes from './routes/health';
import adminRoutes from './routes/admin';
import syncRoutes from './routes/sync';
import analyticsRoutes from './routes/analytics';
import profileRoutes from './routes/profiles';
import chatbotRoutes from './routes/chatbot';
import counselorRoutes from './routes/counselor';
import communityRoutes from './routes/community';
import notificationRoutes from './routes/notifications';

// Load environment variables
dotenv.config();
validateEnv();

const app = express();
const PORT = process.env.PORT || 3001;

// Rate limiting
const limiter = rateLimit({
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
app.use(helmet()); // Security headers
app.use(limiter); // Rate limiting
app.use(cors({
  origin(origin, callback) {
    if (process.env.NODE_ENV !== 'production') {
      callback(null, true);
      return;
    }
    const allowedOrigins = getAllowedOrigins();
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
      return;
    }
    callback(new Error('Origin not allowed by CORS'));
  },
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api/health', healthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/roles', rolesRoutes);
app.use('/api/resources', resourceRoutes);
app.use('/api/questions', questionRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/sync', syncRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/profiles', profileRoutes);
app.use('/api/chatbot', chatbotRoutes);
app.use('/api/counselor', counselorRoutes);
app.use('/api/community', communityRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/admin', adminRoutes);

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
app.use(notFound);
app.use(errorHandler);

// Start server
const httpServer = createServer(app);
SocketService.init(httpServer);

httpServer.listen(PORT, () => {
  console.log(`🚀 Sisonke API Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
  console.log(`📚 API status: http://localhost:${PORT}/api/health/status`);
  console.log(`🔐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('💬 Socket.io initialized for real-time support');
});

export default app;
