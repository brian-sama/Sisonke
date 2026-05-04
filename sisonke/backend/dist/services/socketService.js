"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SocketService = void 0;
const socket_io_1 = require("socket.io");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
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
        this.io.use((socket, next) => {
            const token = socket.handshake.auth.token;
            if (!token)
                return next(new Error('Authentication error'));
            try {
                const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || 'dev_secret');
                socket.data.user = decoded;
                next();
            }
            catch (err) {
                next(new Error('Authentication error'));
            }
        });
        this.io.on('connection', (socket) => {
            const user = socket.data.user;
            console.log(`User connected: ${user.id} (${user.role})`);
            const roles = Array.isArray(user.roles) ? user.roles : [user.role];
            // Users join their own private room for notifications
            socket.join(`user:${user.id}`);
            // Staff join shared rooms
            const isStaff = roles.includes('counselor') || roles.includes('admin') || roles.includes('super-admin');
            const isAdmin = roles.includes('admin') || roles.includes('super-admin');
            if (isStaff)
                socket.join('staff');
            if (isAdmin)
                socket.join('admins');
            if (roles.includes('counselor'))
                socket.join('counselors');
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
                    senderRole: user.role,
                    content: data.content,
                    timestamp: new Date().toISOString()
                });
            });
            socket.on('disconnect', () => {
                console.log(`User disconnected: ${user.id}`);
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