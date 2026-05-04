import { RiskLevel } from './riskService';
export declare function generateLocalChatReply(input: {
    message: string;
    history?: Array<{
        sender: 'user' | 'bot';
        content: string;
    }>;
    persona: 'male' | 'female';
    riskLevel: RiskLevel;
    approvedContext?: string;
}): Promise<string | undefined>;
//# sourceMappingURL=ollamaService.d.ts.map