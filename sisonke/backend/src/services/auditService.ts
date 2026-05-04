import { db } from '../db';
import { auditLogs, NewAuditLog } from '../db/schema';
import { SocketService } from './socketService';

export class AuditService {
  static async log(data: Omit<NewAuditLog, 'id' | 'createdAt'>) {
    try {
      const [log] = await db.insert(auditLogs).values({
        ...data,
        createdAt: new Date(),
      }).returning();
      
      // Notify staff/admins of certain events
      if (['risk_escalated', 'user_deleted', 'admin_action'].includes(data.action)) {
        SocketService.notifyAdmins('audit:new', log);
      }
      
      return log;
    } catch (error) {
      console.error('Failed to create audit log:', error);
      return null;
    }
  }
}
