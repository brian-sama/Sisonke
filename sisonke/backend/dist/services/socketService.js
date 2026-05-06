"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SocketService = void 0;
const socket_io_1 = require("socket.io");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const authService_1 = require("./authService");
/**
 * SocketService handles real-time bidirectional communication
 * between counselors and users for live support sessions.
 */
class SocketService {
    static io;
    static init(server) {
        this.io = new socket_io_1.Server(server, {
            cors: {
                origin: '*', // Adjust for production
                methods: ['GET', 'POST']
            }
        });
        this.io.use(async (socket, next) => {
            const token = socket.handshake.auth.token;
            if (!token)
                return next(new Error('Authentication error'));
            try {
                const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || 'dev_secret');
                // Fetch user roles dynamically from DB to support the new multi-role junction table architecture
                const userRolesList = await authService_1.AuthService.getUserRoles(decoded.userId);
                const rolesList = userRolesList.map(r => r.name);
                socket.data.user = {
                    id: decoded.userId,
                    roles: rolesList
                };
                next();
            }
            catch (err) {
                next(new Error('Authentication error'));
            }
        });
        this.io.on('connection', (socket) => {
            const user = socket.data.user;
            // Convert all roles to lowercase for localized staff room checks to match counselor, admin, super-admin, system-admin
            const roles = (Array.isArray(user.roles) ? user.roles : [])
                .map((r) => r.toLowerCase().replace(/_/g, '-'));
            console.log(`User connected: ${user.id} (Roles: ${roles.join(', ')})`);
            // Users join their own private room for notifications
            socket.join(`user:${user.id}`);
            // Staff join shared rooms
            const isStaff = roles.includes('counselor') || roles.includes('admin') || roles.includes('super-admin') || roles.includes('system-admin');
            const isAdmin = roles.includes('admin') || roles.includes('super-admin') || roles.includes('system-admin');
            if (isStaff)
                socket.join('staff');
            if (isAdmin)
                socket.join('admins');
            if (roles.includes('counselor')) {
                socket.join('counselors');
                this.io.to('staff').emit('counselor:online', {
                    counselorId: user.id,
                    status: 'online',
                    timestamp: new Date().toISOString()
                });
                this.io.to('staff').emit('dashboard:update', {
                    type: 'counselor',
                    action: 'online',
                    counselorId: user.id
                });
            }
            // Join a specific case room
            socket.on('join_case', (caseId) => {
                socket.join(`case:${caseId}`);
                console.log(`User ${user.id} joined case room: ${caseId}`);
            });
            // Leave a case room
            socket.on('leave_case', (caseId) => {
                socket.leave(`case:${caseId}`);
            });
            // Send a message to a case
            socket.on('send_message', (data) => {
                // Broadcast to everyone in the case room EXCEPT the sender
                socket.to(`case:${data.caseId}`).emit('new_message', {
                    caseId: data.caseId,
                    senderId: user.id,
                    senderRole: roles[0] || 'user',
                    content: data.content,
                    timestamp: new Date().toISOString()
                });
            });
            socket.on('disconnect', () => {
                console.log(`User disconnected: ${user.id}`);
                if (roles.includes('counselor')) {
                    this.io.to('staff').emit('counselor:offline', {
                        counselorId: user.id,
                        status: 'offline',
                        timestamp: new Date().toISOString()
                    });
                    this.io.to('staff').emit('dashboard:update', {
                        type: 'counselor',
                        action: 'offline',
                        counselorId: user.id
                    });
                }
            });
        });
    }
    /**
     * Broadcast an event to all staff (counselors and admins)
     */
    static notifyStaff(event, data) {
        if (this.io) {
            this.io.to('staff').emit(event, data);
        }
    }
    /**
     * Send an alert to all counselors (e.g. for new high-risk cases)
     */
    static notifyCounselors(event, data) {
        if (this.io) {
            this.io.to('counselors').emit(event, data);
        }
    }
    /**
     * Send an alert specifically to admins
     */
    static notifyAdmins(event, data) {
        if (this.io) {
            this.io.to('admins').emit(event, data);
        }
    }
    /**
     * Broadcast dashboard updates to all connected staff (admins/counselors)
     */
    static broadcastDashboardUpdate(data) {
        if (this.io) {
            this.io.to('staff').emit('dashboard:update', data);
        }
    }
    static emitCaseEvent(caseId, userId, event, data) {
        if (this.io) {
            this.io.to(`case:${caseId}`).emit(event, data);
            this.io.to('staff').emit(event, data);
            if (userId)
                this.io.to(`user:${userId}`).emit(event, data);
            this.io.to('staff').emit('dashboard:update', { type: 'counselor_case', event, caseId, data });
        }
    }
    /**
     * Send a direct notification to a specific user
     */
    static notifyUser(userId, event, data) {
        if (this.io) {
            this.io.to(`user:${userId}`).emit(event, data);
        }
    }
}
exports.SocketService = SocketService;
//# sourceMappingURL=socketService.js.map