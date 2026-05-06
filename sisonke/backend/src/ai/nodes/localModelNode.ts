import { HumanMessage, SystemMessage } from '@langchain/core/messages';
import { ChatOllama } from '@langchain/ollama';
import { personaPrompts, sisonkeFriendPrompt } from '../prompts/sisonkeFriendPrompt';
import { SisonkeGraphState } from '../types';
import { validateModelOutput } from '../validation';

const defaultBaseUrl = 'http://127.0.0.1:11434';
const defaultModel = 'qwen2.5:1.5b';

async function isOllamaReachable(baseUrl: string) {
  const timeoutMs = Number(process.env.OLLAMA_HEALTH_TIMEOUT_MS || 1500);
  try {
    const response = await fetch(`${baseUrl.replace(/\/$/, '')}/api/tags`, {
      signal: AbortSignal.timeout(timeoutMs),
    });
    return response.ok;
  } catch {
    return false;
  }
}

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

  const baseUrl = process.env.OLLAMA_BASE_URL || defaultBaseUrl;
  if (!(await isOllamaReachable(baseUrl))) {
    return {
      fallbackReason: 'ollama_unreachable',
    };
  }

  const llm = new ChatOllama({
    model: process.env.OLLAMA_CHAT_MODEL || defaultModel,
    baseUrl,
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
    const timeoutMs = Number(process.env.OLLAMA_TIMEOUT_MS || 12000);
    const result = await Promise.race([
      llm.invoke(
        [
          new SystemMessage(prompt),
          new HumanMessage(state.message),
        ],
        { signal: AbortSignal.timeout(timeoutMs) },
      ),
      new Promise<never>((_, reject) =>
        setTimeout(() => reject(new Error('Ollama request timed out')), timeoutMs),
      ),
    ]);
    const validated = validateModelOutput(String(result.content || ''));
    return {
      response: validated.text,
      fallbackReason: validated.fallbackReason,
      aiProvider: 'ollama',
    };
  } catch {
    return {
      fallbackReason: 'llm_timeout',
    };
  }
}
