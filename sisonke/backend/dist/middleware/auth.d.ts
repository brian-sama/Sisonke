import { Request, Response, NextFunction } from 'express';
export interface AuthRequest extends Request {
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
export declare const hasRole: (user: AuthRequest["user"] | undefined, role: string) => boolean;
export declare const hasAnyRole: (user: AuthRequest["user"] | undefined, roles: string[]) => boolean;
export declare const authMiddleware: (req: AuthRequest, res: Response, next: NextFunction) => Promise<Response<any, Record<string, any>> | undefined>;
export declare const optionalAuth: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const adminOnly: (req: AuthRequest, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined;
export declare const superAdminOnly: (req: AuthRequest, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined;
//# sourceMappingURL=auth.d.ts.map