import { Server as HttpServer } from 'http';
/**
 * SocketService handles real-time bidirectional communication
 * between counselors and users for live support sessions.
 */
export declare class SocketService {
    private static io;
    static init(server: HttpServer): void;
    /**
     * Send an alert to all counselors (e.g. for new high-risk cases)
     */
    static notifyCounselors(event: string, data: any): void;
    /**
     * Send a direct notification to a specific user
     */
    static notifyUser(userId: string, event: string, data: any): void;
}
//# sourceMappingURL=socketService.d.ts.map