import { RiskLevel } from './riskService';

const defaultBaseUrl = 'http://127.0.0.1:11434';
const defaultModel = 'qwen2.5:1.5b';

type OllamaResponse = {
  response?: string;
};

export async function generateLocalChatReply(input: {
  message: string;
  history?: Array<{ sender: 'user' | 'bot'; content: string }>;
  persona: 'male' | 'female';
  riskLevel: RiskLevel;
  approvedContext?: string;
}) {
  if (process.env.LOCAL_AI_ENABLED !== 'true') return undefined;
  if (input.riskLevel === 'high') return undefined;

  const baseUrl = process.env.OLLAMA_BASE_URL || defaultBaseUrl;
  const model = process.env.OLLAMA_CHAT_MODEL || defaultModel;
  const personaLabel = input.persona === 'male' ? 'male peer supporter' : 'female peer supporter';

  const historyLines = input.history?.map(h => 
    `${h.sender === 'user' ? 'User' : 'E-Friend'}: ${h.content}`
  ).join('\n') || '';

  const prompt = [
    `You are E-Friend, a warm ${personaLabel} for a youth wellness app in Zimbabwe.`,
    'Style: Warm, respectful, brief. Use plain Grade 7 English.',
    'Guidance: Emotional support and approved resource navigation only. No therapy or diagnosis.',
    'Rules: If crisis is detected, tell user they need a live counselor now.',
    '',
    input.approvedContext ? `Approved context:\n${input.approvedContext}\n` : '',
    historyLines ? `Previous Conversation:\n${historyLines}\n` : '',
    `User: ${input.message}`,
    'E-Friend:',
  ].join('\n');

  try {
    const response = await fetch(`${baseUrl}/api/generate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model,
        prompt,
        stream: false,
        options: {
          temperature: 0.4,
          num_predict: 120,
          num_ctx: 1024,
        },
      }),
      signal: AbortSignal.timeout(Number(process.env.OLLAMA_TIMEOUT_MS || 12000)),
    });

    if (!response.ok) return undefined;

    const data = await response.json() as OllamaResponse;
    return data.response?.trim() || undefined;
  } catch {
    return undefined;
  }
}
