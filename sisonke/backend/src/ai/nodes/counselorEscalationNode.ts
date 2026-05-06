import { safeBotReply } from '../../services/riskService';
import { SisonkeGraphState } from '../types';

export async function counselorEscalationNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  const riskLevel = state.riskLevel || 'high';
  const reply = safeBotReply(state.message, riskLevel, state.persona);

  return {
    response: reply.text,
    escalationRequired: riskLevel === 'high',
    personaMode: 'hardcoded_escalation',
    conversationState: 'ESCALATE',
    aiProvider: 'rules',
    safetySource: 'rules',
    handoffSummary: [
      `Risk level: ${riskLevel}`,
      `Primary emotion: ${state.detectedPrimaryEmotion || 'unknown'}`,
      `User message: ${state.message.slice(0, 500)}`,
      state.culturalContextNote ? `Cultural context: ${state.culturalContextNote.slice(0, 500)}` : '',
    ].filter(Boolean).join('\n'),
  };
}
