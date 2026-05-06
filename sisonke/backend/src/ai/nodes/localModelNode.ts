import { HumanMessage, SystemMessage } from '@langchain/core/messages';
import { ChatOllama } from '@langchain/ollama';
import { personaPrompts, sisonkeFriendPrompt } from '../prompts/sisonkeFriendPrompt';
import { SisonkeGraphState } from '../types';
import { validateModelOutput } from '../validation';
import { systemFallbacks } from '../data/fallbacks';

const defaultBaseUrl = 'http://127.0.0.1:11434';
const defaultModel = 'qwen2.5:1.5b';

function historyText(state: SisonkeGraphState) {
  return (state.history || [])
    .slice(-5)
    .map((item) => `${item.sender === 'user' ? 'User' : 'Sisonke Friend'}: ${item.content}`)
    .join('\n');
}

export async function localModelNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  if (state.response) return {};
  if (state.riskLevel === 'high') return {};
  if (process.env.LOCAL_AI_ENABLED !== 'true') {
    return { response: undefined, fallbackReason: 'local_ai_disabled' };
  }

  const llm = new ChatOllama({
    model: process.env.OLLAMA_CHAT_MODEL || defaultModel,
    baseUrl: process.env.OLLAMA_BASE_URL || defaultBaseUrl,
    temperature: 0.35,
    numPredict: 120,
    numCtx: 1400,
  });

  const personaMode = state.personaMode || 'warm_validation';
  const prompt = await sisonkeFriendPrompt.format({
    conversationState: state.conversationState || 'EXPLORE',
    detectedPrimaryEmotion: state.detectedPrimaryEmotion || 'unclear',
    detectedIntent: state.detectedIntent || 'sharing_feelings',
    riskLevel: state.riskLevel || 'low',
    personaRules: personaPrompts[personaMode],
    preferredName: state.preferredName || 'friend',
    culturalContextNote: state.culturalContextNote || 'None.',
    approvedContext: state.approvedContext || 'None.',
    interventionText: state.interventionText || 'None.',
    historyText: historyText(state) || 'None.',
    message: state.message,
  });

  try {
    const result = await llm.invoke([
      new SystemMessage(prompt),
      new HumanMessage(state.message),
    ], {
      signal: AbortSignal.timeout(Number(process.env.OLLAMA_TIMEOUT_MS || 12000)),
    });
    const validated = validateModelOutput(String(result.content || ''));
    return {
      response: validated.text,
      fallbackReason: validated.fallbackReason,
      aiProvider: 'ollama',
    };
  } catch {
    return {
      response: systemFallbacks.llm_timeout,
      fallbackReason: 'llm_timeout',
      aiProvider: 'rules',
    };
  }
}
