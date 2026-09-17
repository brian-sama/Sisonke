import { PersonaMode, ConversationState, ChatHistoryItem } from '../ai/types';
import { RiskLevel } from './riskService';
export declare function generateGeminiFallback(input: {
    message: string;
    history?: ChatHistoryItem[];
    persona: 'male' | 'female';
    riskLevel: RiskLevel;
    approvedContext?: string;
    localReply?: string;
    detectedPrimaryEmotion?: string;
    detectedIntent?: string;
    personaMode?: PersonaMode;
    culturalContextNote?: string;
    interventionText?: string;
    preferredName?: string;
    conversationState?: ConversationState;
}): Promise<string | undefined>;
//# sourceMappingURL=geminiService.d.ts.map