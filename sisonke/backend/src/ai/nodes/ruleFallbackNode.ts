import { deterministicGreeting } from '../data/fallbacks';
import { SisonkeGraphState } from '../types';

function firstContextTitle(context?: string) {
  const match = context?.match(/SOURCE \[[^\]]+\]:\s*(.+)/);
  return match?.[1]?.trim();
}

function userAddress(persona: SisonkeGraphState['persona']) {
  return persona === 'male' ? 'brother' : 'sister';
}

const SOFT_QUESTIONS = [
  'What feels like the part carrying the most weight right now?',
  'You can take your time — is there anything specific sitting on your chest?',
  'What would feel gentlest or most comforting to you in this moment?',
  'I am right here with you. What is your mind replaying the most?',
  'Would you like to just vent, or do you prefer quiet company right now?',
];

function softQuestion(state: SisonkeGraphState, previousBotTexts: string[]) {
  if (state.detectedIntent === 'seeking_support') {
    return 'What feels like the smallest part we can take together first?';
  }
  if (state.detectedIntent === 'needs_listening') {
    return 'Take all the room you need. I am here listening.';
  }

  // Filter out questions already used in recent turns
  const available = SOFT_QUESTIONS.filter(
    (q) => !previousBotTexts.some((prev) => prev.includes(q.slice(0, 20))),
  );
  const pool = available.length > 0 ? available : SOFT_QUESTIONS;
  const index = (state.turnsElapsed || 0) % pool.length;
  return pool[index];
}

function localExpressionLine(state: SisonkeGraphState) {
  const match = state.matchedLocalExpressions?.[0];
  if (!match) return undefined;
  return `When you say "${match.phrase}", I hear that this has real weight for you.`;
}

function contextualResponse(state: SisonkeGraphState) {
  const name = state.preferredName || userAddress(state.persona);
  const emotion = state.detectedPrimaryEmotion || 'unclear';
  const resourceTitle = firstContextTitle(state.approvedContext);
  const localLine = localExpressionLine(state);

  const previousBotTexts = (state.history || [])
    .filter((h) => h.sender === 'bot')
    .map((h) => h.content);

  if (state.conversationState === 'INIT') {
    return deterministicGreeting(state.turnsElapsed || 0);
  }

  if (state.conversationState === 'WIND_DOWN') {
    return `I am glad you came here, ${name}. Take the gentlest next step you can, and remember you never have to carry things alone.`;
  }

  if (state.riskLevel === 'medium') {
    return [
      localLine,
      `Thank you for trusting me with that, ${name}. This sounds heavy enough that human support could help too, and I can stay with you for one small grounding step now.`,
      state.interventionText || 'Try one slow breath and notice one thing around you that tells you this moment is here.',
    ].filter(Boolean).join(' ');
  }

  if (emotion === 'overwhelmed') {
    return [
      localLine,
      `That sounds like a lot to hold at once, ${name}.`,
      state.interventionText || 'Let us slow it down together: feel your feet on the ground and take one easy breath.',
    ].filter(Boolean).join(' ');
  }

  if (emotion === 'exhausted') {
    const sleepOptions = [
      `I hear how deeply tired you are, ${name}. It is okay to put everything down right now and just rest.`,
      `Your mind and body are telling you they need rest, ${name}. You don't have to push through anything tonight.`,
      `I hear you, ${name}. Rest is not weakness — it is what heals us. What would feel kindest to your body right now?`,
    ];
    return [
      localLine,
      sleepOptions[(state.turnsElapsed || 0) % sleepOptions.length],
    ].filter(Boolean).join(' ');
  }

  if (emotion === 'sad') {
    const sadOptions = [
      `I hear the sadness in that, ${name}. You don't have to pretend everything is fine here.`,
      `I am sorry things feel this heavy, ${name}. I am right here with you, and we can take it one minute at a time.`,
    ];
    return [
      localLine,
      sadOptions[(state.turnsElapsed || 0) % sadOptions.length],
      softQuestion(state, previousBotTexts),
    ].filter(Boolean).join(' ');
  }

  if (emotion === 'frustrated') {
    return [
      localLine,
      `That frustration makes complete sense, ${name}. Something important feels blocked or unfair.`,
      softQuestion(state, previousBotTexts),
    ].filter(Boolean).join(' ');
  }

  if (resourceTitle && (state.detectedIntent === 'seeking_information' || state.detectedIntent === 'asking_for_resource')) {
    return `I hear you, ${name}. We have an approved resource on that topic: "${resourceTitle}". Would you like to talk about that?`;
  }

  // Dynamic empathetic pool that never repeats the same phrase back-to-back
  const generalEmpathyPool = [
    `I hear you, ${name}. I'm listening closely without any judgment.`,
    `Thank you for telling me that, ${name}. Take all the space you need.`,
    `I am sitting with you in this, ${name}. There's no pressure to rush or figure it out all at once.`,
    `I hear you, ${name}. Even just putting it into words takes courage.`,
  ];

  // Pick an empathy line not present in the last bot message
  const lastBotMsg = previousBotTexts[previousBotTexts.length - 1] || '';
  const freshEmpathy = generalEmpathyPool.find((line) => !lastBotMsg.includes(line.slice(0, 15))) || generalEmpathyPool[0];

  return [
    localLine,
    freshEmpathy,
    softQuestion(state, previousBotTexts),
  ].filter(Boolean).join(' ');
}

export async function ruleFallbackNode(
  state: SisonkeGraphState,
): Promise<Partial<SisonkeGraphState>> {
  if (state.riskLevel === 'high') return {};
  if (state.response && !state.fallbackReason) return {};
  if (state.aiProvider === 'gemini' && state.response) return {};

  return {
    response: contextualResponse(state),
    aiProvider: 'rules',
    fallbackReason: state.fallbackReason || 'model_unavailable',
  };
}
