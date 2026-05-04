export type SafetyRoute = 'self_harm' | 'active_violence' | 'sexual_assault' | 'forced_marriage' | 'substance_emergency';
export type SafetyRule = {
    route: SafetyRoute;
    risk: 'red' | 'amber';
    terms: string[];
};
export type ZimbabweContact = {
    id: string;
    name: string;
    phoneNumber: string;
    category: string;
    description: string;
    country: 'ZW';
};
export type KnowledgeCard = {
    id: string;
    title: string;
    category: 'mental-health' | 'srhr' | 'emergency' | 'substance-use' | 'wellness' | 'guide';
    tags: string[];
    riskLevel: 'green' | 'amber' | 'red';
    content: string;
};
export declare const zimbabweEmergencyContacts: ZimbabweContact[];
export declare const safetyRules: SafetyRule[];
export declare const zimbabweKnowledgeCards: KnowledgeCard[];
export declare const goldFaqCards: KnowledgeCard[];
export declare const allZimbabweRagCards: KnowledgeCard[];
//# sourceMappingURL=zimbabweRagKnowledge.d.ts.map