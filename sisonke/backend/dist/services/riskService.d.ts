import { SafetyRoute } from '../data/zimbabweRagKnowledge';
export type RiskLevel = 'low' | 'medium' | 'high';
type RiskDetection = {
    level: RiskLevel;
    route?: SafetyRoute;
};
export declare function detectRisk(message: string): RiskDetection;
export declare function detectRiskLevel(message: string): RiskLevel;
export declare function safeBotReply(message: string, riskLevel: RiskLevel, persona: 'male' | 'female'): {
    text: string;
    shouldEscalate: boolean;
};
export {};
//# sourceMappingURL=riskService.d.ts.map