declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email?: string;
        role: string;
        isGuest: boolean;
        deviceId?: string;
      };
    }
  }
}

export {};
