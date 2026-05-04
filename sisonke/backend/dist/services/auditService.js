"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuditService = void 0;
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const socketService_1 = require("./socketService");
class AuditService {
    static async log(data) {
        try {
            const [log] = await db_1.db.insert(schema_1.auditLogs).values({
                ...data,
                createdAt: new Date(),
            }).returning();
            // Notify staff/admins of certain events
            if (['risk_escalated', 'user_deleted', 'admin_action'].includes(data.action)) {
                socketService_1.SocketService.notifyAdmins('audit:new', log);
            }
            return log;
        }
        catch (error) {
            console.error('Failed to create audit log:', error);
            return null;
        }
    }
}
exports.AuditService = AuditService;
//# sourceMappingURL=auditService.js.map