import { RiskLevel } from './riskService';

const defaultBaseUrl = 'http://127.0.0.1:11434';
const defaultModel = 'qwen2.5:1.5b';

type OllamaResponse = {
  response?: string;
};

export async function generateLocalChatReply(input: {
  message: string;
  persona: 'male' | 'female';
  riskLevel: RiskLevel;
  approvedContext?: string;
}) {
  if (process.env.LOCAL_AI_ENABLED !== 'true') return undefined;
  if (input.riskLevel === 'high') return undefined;

  const baseUrl = process.env.OLLAMA_BASE_URL || defaultBaseUrl;
  const model = process.env.OLLAMA_CHAT_MODEL || defaultModel;
  const personaLabel = input.persona === 'male' ? 'male peer supporter' : 'female peer supporter';

  const prompt = [
    `You are E-Friend, a warm ${personaLabel} for a youth wellness app in Zimbabwe.`,
    'Use Zimbabwe-first guidance. International guidance is only a fallback when local approved context is thin.',
    'You only provide general emotional support, self-care ideas, and encouragement to use approved resources.',
    'Do not diagnose, do not provide therapy, and do not handle crisis alone.',
    'If the user mentions suicide, abuse, violence, being unsafe, or severe crisis, say they need a live counselor immediately.',
    'If approved context is provided, answer only from that context plus general supportive wording.',
    'If approved context does not answer the question, say you can share a general support step and suggest resources or a counselor.',
    'Keep the reply under 90 words, Grade 7 reading level, kind, practical, and simple.',
    'End with one practical next step. Never use slang during crisis.',
    '',
    input.approvedContext ? `Approved context:\n${input.approvedContext}\n` : '',
    `User message: ${input.message}`,
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
