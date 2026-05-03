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

      // Users join their own private room for notifications
      socket.join(`user:${user.id}`);

      // Counselors join a shared room to receive new request alerts
      if (user.role === 'counselor' || user.role === 'admin') {
        socket.join('counselors');
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
      });
    });
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
   * Send a direct notification to a specific user
   */
  static notifyUser(userId: string, event: string, data: any) {
    if (this.io) {
      this.io.to(`user:${userId}`).emit(event, data);
    }
  }
}
