import { RiskLevel } from '../services/riskService';

export type ConversationState =
  | 'INIT'
  | 'EXPLORE'
  | 'SUPPORT_OR_LISTEN'
  | 'GROUNDING'
  | 'WIND_DOWN'
  | 'ESCALATE'
  | 'HANDOFF';

export type PersonaMode =
  | 'gentle_listener'
  | 'warm_validation'
  | 'grounding_presence'
  | 'practical_support'
  | 'hardcoded_escalation';

export type LocalExpressionMatch = {
  phrase: string;
  language: string;
  literal: string;
  emotionalWeight: string;
  targetMode: PersonaMode;
  suggestedResponseStyle: string;
};

export type ChatHistoryItem = {
  sender: 'user' | 'bot';
  content: string;
};

export type SisonkeGraphInput = {
  userId?: string;
  deviceId?: string;
  sessionId?: string;
  message: string;
  persona: 'male' | 'female';
  riskLevel?: RiskLevel;
  turnsElapsed?: number;
  history?: ChatHistoryItem[];
  approvedContext?: string;
  currentSessionState?: ConversationState;
  preferredName?: string;
};

export type SisonkeGraphState = SisonkeGraphInput & {
  detectedPrimaryEmotion?: string;
  detectedIntent?: string;
  detectedLanguage?: string;
  conversationState?: ConversationState;
  personaMode?: PersonaMode;
  matchedLocalExpressions?: LocalExpressionMatch[];
  culturalContextNote?: string;
  interventionId?: string;
  interventionText?: string;
  response?: string;
  fallbackReason?: string;
  escalationRequired?: boolean;
  safetySource?: 'rules' | 'model' | 'fallback';
  aiProvider?: 'ollama' | 'gemini' | 'rules';
  handoffSummary?: string;
};
