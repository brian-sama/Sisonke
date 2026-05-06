import { generateGeminiFallback } from '../../services/geminiService';
import { SisonkeGraphState } from '../types';
import { validateModelOutput } from '../validation';

export async function geminiFallbackNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  if (state.riskLevel === 'high') return {};
  if (process.env.EXTERNAL_AI_FALLBACK_ENABLED !== 'true') return {};
  if (state.response && !state.fallbackReason) return {};

  const geminiReply = await generateGeminiFallback({
    message: state.message,
    history: state.history,
    persona: state.persona,
    riskLevel: state.riskLevel || 'low',
    approvedContext: state.approvedContext,
    localReply: state.response,
  });

  if (!geminiReply) return {};
  const validated = validateModelOutput(geminiReply);
  return {
    response: validated.text,
    fallbackReason: validated.fallbackReason,
    aiProvider: 'gemini',
  };
}
