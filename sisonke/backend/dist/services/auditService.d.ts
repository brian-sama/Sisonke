import { NewAuditLog } from '../db/schema';
export declare class AuditService {
    static log(data: Omit<NewAuditLog, 'id' | 'createdAt'>): Promise<{
        id: string;
        createdAt: Date | null;
        actorId: string | null;
        action: string;
        entityType: string | null;
        entityId: string | null;
        metadata: unknown;
    } | null>;
}
//# sourceMappingURL=auditService.d.ts.map