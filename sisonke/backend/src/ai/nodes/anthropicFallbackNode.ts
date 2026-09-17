import { generateAnthropicFallback } from '../../services/anthropicService';
import { SisonkeGraphState } from '../types';
import { validateModelOutput } from '../validation';

export async function anthropicFallbackNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  if (state.riskLevel === 'high') return {};
  if (process.env.EXTERNAL_AI_FALLBACK_ENABLED !== 'true') return {};
  if (state.response && !state.fallbackReason) return {};

  const anthropicReply = await generateAnthropicFallback({
    message: state.message,
    history: state.history,
    persona: state.persona,
    riskLevel: state.riskLevel || 'low',
    approvedContext: state.approvedContext,
    detectedPrimaryEmotion: state.detectedPrimaryEmotion,
    detectedIntent: state.detectedIntent,
    personaMode: state.personaMode,
    culturalContextNote: state.culturalContextNote,
    interventionText: state.interventionText,
    preferredName: state.preferredName,
    conversationState: state.conversationState,
  });

  if (!anthropicReply) return {};

  const validated = validateModelOutput(anthropicReply);
  return {
    response: validated.text,
    fallbackReason: validated.fallbackReason,
    aiProvider: 'anthropic',
  };
}
