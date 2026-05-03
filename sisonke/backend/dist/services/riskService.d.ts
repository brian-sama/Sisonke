export type RiskLevel = 'low' | 'medium' | 'high';
export declare function detectRiskLevel(message: string): RiskLevel;
export declare function safeBotReply(message: string, riskLevel: RiskLevel, persona: 'male' | 'female'): {
    text: string;
    shouldEscalate: boolean;
};
//# sourceMappingURL=riskService.d.ts.map