import { matchLocalExpressions } from '../data/localExpressions';
import { SisonkeGraphState, PersonaMode } from '../types';

function inferEmotion(message: string) {
  const text = message.toLowerCase();
  if (/(ndakaneta|ngikhathele|tired|exhausted|burnt out|burned out)/.test(text)) return 'exhausted';
  if (/(panic|anxious|anxiety|heart racing|kufungisisa|overwhelmed|spiral)/.test(text)) return 'overwhelmed';
  if (/(sad|lonely|alone|empty|numb|hopeless)/.test(text)) return 'sad';
  if (/(angry|furious|mad|frustrated)/.test(text)) return 'frustrated';
  if (/(thanks|thank you|better now|i need to go|bye)/.test(text)) return 'relieved_or_closing';
  return 'unclear';
}

function inferIntent(message: string) {
  const text = message.toLowerCase();
  if (/(help|what do i do|advice|how can i)/.test(text)) return 'seeking_support';
  if (/(vent|listen|hear me|talk)/.test(text)) return 'needs_listening';
  if (/(thanks|bye|go now|later)/.test(text)) return 'closing';
  return 'sharing_feelings';
}

function modeForEmotion(emotion: string, localMode?: PersonaMode): PersonaMode {
  if (localMode) return localMode;
  if (emotion === 'exhausted' || emotion === 'sad') return 'gentle_listener';
  if (emotion === 'overwhelmed') return 'grounding_presence';
  return 'warm_validation';
}

export async function emotionNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  const matches = matchLocalExpressions(state.message);
  const detectedPrimaryEmotion = inferEmotion(state.message);
  const detectedIntent = inferIntent(state.message);
  const firstMatch = matches[0];

  return {
    detectedPrimaryEmotion,
    detectedIntent,
    detectedLanguage: firstMatch?.language || 'unknown',
    matchedLocalExpressions: matches,
    personaMode: modeForEmotion(detectedPrimaryEmotion, firstMatch?.targetMode),
    culturalContextNote: matches
      .map((match) => `The user used "${match.phrase}" (${match.language}), meaning "${match.literal}". Emotional weight: ${match.emotionalWeight}`)
      .join('\n'),
  };
}
