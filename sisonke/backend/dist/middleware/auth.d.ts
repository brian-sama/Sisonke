import { Request, Response, NextFunction } from 'express';
export interface AuthRequest extends Request {
    user?: {
        id: string;
        email?: string;
        roles: string[];
        isGuest: boolean;
        mustChangePassword: boolean;
        deviceId?: string;
    };
}
export declare const normalizeRole: (role: string | null | undefined) => string;
export declare const DASHBOARD_ROLES: string[];
export declare const SYSTEM_ADMIN_ROLES: string[];
export declare const hasRole: (user: AuthRequest["user"] | undefined, role: string) => boolean;
export declare const hasAnyRole: (user: AuthRequest["user"] | undefined, roles: string[]) => boolean;
export declare const hasPermission: (userId: string, permission: string) => Promise<boolean>;
export declare const authMiddleware: (req: AuthRequest, res: Response, next: NextFunction) => Promise<Response<any, Record<string, any>> | undefined>;
export declare const optionalAuth: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const adminOnly: (req: AuthRequest, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined;
export declare const superAdminOnly: (req: AuthRequest, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined;
export declare const dashboardAccess: (req: AuthRequest, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined;
//# sourceMappingURL=auth.d.ts.map