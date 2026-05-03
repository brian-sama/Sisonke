import { RiskLevel } from './riskService';
export declare function generateGeminiFallback(input: {
    message: string;
    persona: 'male' | 'female';
    riskLevel: RiskLevel;
    approvedContext?: string;
    localReply?: string;
}): Promise<string | undefined>;
//# sourceMappingURL=geminiService.d.ts.map