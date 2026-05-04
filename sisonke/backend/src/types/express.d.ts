declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email?: string;
      role: string;
      roles: string[];
      isGuest: boolean;
      mustChangePassword: boolean;
      deviceId?: string;
      };
    }
  }
}

export {};
