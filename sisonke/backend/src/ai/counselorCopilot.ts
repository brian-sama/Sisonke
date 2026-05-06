import { HumanMessage, SystemMessage } from '@langchain/core/messages';
import { ChatOllama } from '@langchain/ollama';
import { validateModelOutput } from './validation';

type CaseContext = {
  issueCategory: string;
  riskLevel: string;
  status: string;
  summary?: string | null;
  messages: Array<{
    senderRole: string;
    content: string;
    createdAt?: Date | null;
  }>;
};

function transcript(context: CaseContext) {
  const lines = context.messages
    .slice(-12)
    .map((message) => `${message.senderRole}: ${message.content}`)
    .join('\n');
  return lines || context.summary || 'No message transcript available.';
}

async function invokeCounselorModel(system: string, user: string) {
  if (process.env.LOCAL_AI_ENABLED !== 'true') return undefined;

  const llm = new ChatOllama({
    model: process.env.OLLAMA_CHAT_MODEL || 'qwen2.5:1.5b',
    baseUrl: process.env.OLLAMA_BASE_URL || 'http://127.0.0.1:11434',
    temperature: 0.2,
    numPredict: 180,
    numCtx: 1800,
  });

  const result = await llm.invoke([
    new SystemMessage(system),
    new HumanMessage(user),
  ], {
    signal: AbortSignal.timeout(Number(process.env.OLLAMA_TIMEOUT_MS || 12000)),
  });

  return validateModelOutput(String(result.content || '')).text;
}

export async function generateCounselorSummary(context: CaseContext) {
  const deterministic = [
    `Issue: ${context.issueCategory}`,
    `Risk: ${context.riskLevel}`,
    `Status: ${context.status}`,
    context.summary ? `Existing summary: ${context.summary}` : '',
    `Recent transcript:\n${transcript(context)}`,
  ].filter(Boolean).join('\n');

  try {
    const modelSummary = await invokeCounselorModel(
      [
        'You help Zimbabwean counselors review support cases.',
        'Summarize only what is present in the transcript.',
        'Do not invent symptoms, diagnosis, names, locations, or facts.',
        'Use 3 short sentences maximum.',
      ].join('\n'),
      deterministic,
    );
    return modelSummary || deterministic;
  } catch {
    return deterministic;
  }
}

export async function generateCounselorDraftReply(context: CaseContext) {
  try {
    const draft = await invokeCounselorModel(
      [
        'You draft messages for a human counselor in Zimbabwe.',
        'The counselor will review before sending.',
        'Use warm, brief, non-judgmental language.',
        'Do not diagnose, promise outcomes, or give legal/medical instructions.',
        'If risk is high, encourage immediate human/emergency support and safety.',
        'Maximum 3 short sentences.',
      ].join('\n'),
      [
        `Case risk: ${context.riskLevel}`,
        `Case issue: ${context.issueCategory}`,
        `Recent transcript:\n${transcript(context)}`,
        'Draft the next counselor reply.',
      ].join('\n\n'),
    );

    return draft || 'Thank you for sharing this with me. I am here with you, and your safety matters right now.';
  } catch {
    return 'Thank you for sharing this with me. I am here with you, and your safety matters right now.';
  }
}

export function deterministicRiskReview(context: CaseContext) {
  const text = `${context.summary || ''}\n${transcript(context)}`.toLowerCase();
  const flags = [
    ['self_harm', /(suicide|kill myself|end my life|hurt myself|want to die|sleep forever)/],
    ['gbv_or_active_violence', /(hitting me|beating me|not safe at home|locked me in|domestic violence)/],
    ['sexual_assault', /(raped|forced me|sexual assault|bad touch|private parts|need pep)/],
    ['substance_emergency', /(overdose|collapsed|heart racing|took too much|mutoriro|guka|broncleer|diaper)/],
    ['forced_marriage', /(forced marriage|older man|family wants me to marry|lobola|marry before 18)/],
  ]
    .filter(([, pattern]) => (pattern as RegExp).test(text))
    .map(([label]) => label);

  const reviewedRisk = flags.length > 0 ? 'high' : context.riskLevel;
  return {
    reviewedRisk,
    flags,
    recommendation: reviewedRisk === 'high'
      ? 'Keep this in urgent counselor review. Use survivor-centered safety planning and verified referral contacts.'
      : 'Continue supportive counseling and monitor for risk changes.',
  };
}
