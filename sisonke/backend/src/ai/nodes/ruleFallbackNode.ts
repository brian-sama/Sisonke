import { deterministicGreeting } from '../data/fallbacks';
import { SisonkeGraphState } from '../types';

function firstContextTitle(context?: string) {
  const match = context?.match(/SOURCE \[[^\]]+\]:\s*(.+)/);
  return match?.[1]?.trim();
}

function userAddress(persona: SisonkeGraphState['persona']) {
  return persona === 'male' ? 'brother' : 'sister';
}

function softQuestion(state: SisonkeGraphState) {
  if (state.detectedIntent === 'seeking_support') {
    return 'What feels like the smallest part we can handle first?';
  }
  if (state.detectedIntent === 'needs_listening') {
    return 'You can tell me the part that feels heaviest.';
  }
  return 'What is the strongest feeling in it right now?';
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

  if (state.conversationState === 'INIT') {
    return deterministicGreeting(state.turnsElapsed || 0);
  }

  if (state.conversationState === 'WIND_DOWN') {
    return `I am glad you came here, ${name}. Take the gentlest next step you can, and come back when you need company.`;
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
      state.interventionText || 'Let us slow it down: name one thing you can see, then take one easy breath.',
    ].filter(Boolean).join(' ');
  }

  if (emotion === 'exhausted') {
    return [
      localLine,
      `I hear how tired you are, ${name}. You do not need to solve everything in this one moment.`,
      'What would feel kindest to your body in the next few minutes?',
    ].filter(Boolean).join(' ');
  }

  if (emotion === 'sad') {
    return [
      localLine,
      `I am sorry it feels this lonely, ${name}. I am here with you, and we can go slowly.`,
      softQuestion(state),
    ].filter(Boolean).join(' ');
  }

  if (emotion === 'frustrated') {
    return [
      localLine,
      `That frustration makes sense, ${name}. Something important feels blocked or unfair.`,
      softQuestion(state),
    ].filter(Boolean).join(' ');
  }

  if (resourceTitle) {
    return `I hear you, ${name}. There is an approved Sisonke resource we can ground this in: ${resourceTitle}. ${softQuestion(state)}`;
  }

  return [
    localLine,
    `I hear you, ${name}. I will not rush to fix it or judge it.`,
    softQuestion(state),
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
