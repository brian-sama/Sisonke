import { RiskLevel } from './riskService';
export declare function generateLocalChatReply(input: {
    message: string;
    persona: 'male' | 'female';
    riskLevel: RiskLevel;
    approvedContext?: string;
}): Promise<string | undefined>;
//# sourceMappingURL=ollamaService.d.ts.map