const required = ['DATABASE_URL', 'JWT_SECRET'] as const;

export function validateEnv() {
  const missing = required.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }

  if ((process.env.JWT_SECRET || '').length < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters long');
  }
}

export function getAllowedOrigins() {
  const configured = process.env.ALLOWED_ORIGINS || process.env.FRONTEND_URL || 'http://localhost:3000';
  const origins = configured.split(',').map((origin) => origin.trim()).filter(Boolean);
  
  // Always allow the production domain if we're in production
  if (process.env.NODE_ENV === 'production') {
    if (!origins.includes('https://sisonke.mmpzmne.co.zw')) {
      origins.push('https://sisonke.mmpzmne.co.zw');
    }
  }
  
  return origins;
}
