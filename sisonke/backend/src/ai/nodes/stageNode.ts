import { deterministicGreeting } from '../data/fallbacks';
import { SisonkeGraphState } from '../types';

export async function stageNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  if (state.riskLevel === 'high') {
    return { conversationState: 'ESCALATE', personaMode: 'hardcoded_escalation' };
  }

  const turnsElapsed = state.turnsElapsed || 0;
  if (turnsElapsed === 0 && /^(hi|hey|hello|mhoroi|sawubona|hie)\b/i.test(state.message.trim())) {
    return {
      conversationState: 'INIT',
      response: deterministicGreeting(turnsElapsed),
      aiProvider: 'rules',
    };
  }

  if (state.detectedIntent === 'closing') {
    return { conversationState: 'WIND_DOWN' };
  }

  if (state.detectedPrimaryEmotion === 'overwhelmed') {
    return { conversationState: 'GROUNDING', personaMode: 'grounding_presence' };
  }

  if (turnsElapsed < 4) {
    return { conversationState: 'EXPLORE' };
  }

  return { conversationState: 'SUPPORT_OR_LISTEN' };
}
