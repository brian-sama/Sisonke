import { Server } from 'socket.io';
import { Server as HttpServer } from 'http';
import jwt from 'jsonwebtoken';

/**
 * SocketService handles real-time bidirectional communication
 * between counselors and users for live support sessions.
 */
export class SocketService {
  private static io: Server;

  static init(server: HttpServer) {
    this.io = new Server(server, {
      cors: {
        origin: '*', // Adjust for production
        methods: ['GET', 'POST']
      }
    });

    this.io.use((socket, next) => {
      const token = socket.handshake.auth.token;
      if (!token) return next(new Error('Authentication error'));

      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dev_secret') as any;
        socket.data.user = decoded;
        next();
      } catch (err) {
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

      if (isStaff) socket.join('staff');
      if (isAdmin) socket.join('admins');
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
      socket.on('join_case', (caseId: string) => {
        socket.join(`case:${caseId}`);
        console.log(`User ${user.id} joined case room: ${caseId}`);
      });

      // Leave a case room
      socket.on('leave_case', (caseId: string) => {
        socket.leave(`case:${caseId}`);
      });

      // Send a message to a case
      socket.on('send_message', (data: { caseId: string; content: string }) => {
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
  static notifyStaff(event: string, data: any) {
    if (this.io) {
      this.io.to('staff').emit(event, data);
    }
  }

  /**
   * Send an alert to all counselors (e.g. for new high-risk cases)
   */
  static notifyCounselors(event: string, data: any) {
    if (this.io) {
      this.io.to('counselors').emit(event, data);
    }
  }

  /**
   * Send an alert specifically to admins
   */
  static notifyAdmins(event: string, data: any) {
    if (this.io) {
      this.io.to('admins').emit(event, data);
    }
  }

  /**
   * Broadcast dashboard updates to all connected staff (admins/counselors)
   */
  static broadcastDashboardUpdate(data: any) {
    if (this.io) {
      this.io.to('staff').emit('dashboard:update', data);
    }
  }

  static emitCaseEvent(caseId: string, userId: string | null | undefined, event: string, data: any) {
    if (this.io) {
      this.io.to(`case:${caseId}`).emit(event, data);
      this.io.to('staff').emit(event, data);
      if (userId) this.io.to(`user:${userId}`).emit(event, data);
      this.io.to('staff').emit('dashboard:update', { type: 'counselor_case', event, caseId, data });
    }
  }

  /**
   * Send a direct notification to a specific user
   */
  static notifyUser(userId: string, event: string, data: any) {
    if (this.io) {
      this.io.to(`user:${userId}`).emit(event, data);
    }
  }
}
