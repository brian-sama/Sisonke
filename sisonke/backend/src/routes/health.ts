import { Router } from 'express';
import { db } from '../db';
import { users } from '../db/schema';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

// Health check endpoint
router.get('/', asyncHandler(async (req, res) => {
  try {
    // Check database connection
    await db.select({ id: users.id }).from(users).limit(1);
    
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
  } catch (error) {
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
router.get('/status', asyncHandler(async (req, res) => {
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

export default router;
