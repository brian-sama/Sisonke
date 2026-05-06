import { LocalExpressionMatch } from '../types';

export const localExpressions: LocalExpressionMatch[] = [
  {
    phrase: 'ndakaneta',
    language: 'Shona',
    literal: 'I am tired',
    emotionalWeight: 'Deep emotional or physical burnout. Feeling depleted.',
    targetMode: 'gentle_listener',
    suggestedResponseStyle: 'validate_exhaustion',
  },
  {
    phrase: 'angisafuni',
    language: 'Ndebele',
    literal: "I don't want anymore",
    emotionalWeight: 'Giving up, hitting a wall, deep frustration or hopelessness.',
    targetMode: 'grounding_presence',
    suggestedResponseStyle: 'grounding_presence',
  },
  {
    phrase: 'zvinorema',
    language: 'Shona',
    literal: 'It is heavy',
    emotionalWeight: 'Carrying a massive emotional or practical burden.',
    targetMode: 'warm_validation',
    suggestedResponseStyle: 'acknowledge_burden',
  },
  {
    phrase: 'life inzima',
    language: 'Mixed/Ndebele slang',
    literal: 'Life is difficult',
    emotionalWeight: 'General struggle with systemic or daily pressures.',
    targetMode: 'warm_validation',
    suggestedResponseStyle: 'shared_humanity',
  },
  {
    phrase: 'ngikhathele',
    language: 'Ndebele',
    literal: 'I am tired',
    emotionalWeight: 'Exhaustion similar to ndakaneta. Needs rest, not advice.',
    targetMode: 'gentle_listener',
    suggestedResponseStyle: 'validate_exhaustion',
  },
  {
    phrase: 'zvakaoma',
    language: 'Shona',
    literal: 'It is difficult/hard',
    emotionalWeight: 'Facing a tough situation, feeling stuck.',
    targetMode: 'warm_validation',
    suggestedResponseStyle: 'soft_exploration',
  },
  {
    phrase: 'kufungisisa',
    language: 'Shona',
    literal: 'Thinking too much',
    emotionalWeight: 'Rumination, worry, anxiety, or emotional overload.',
    targetMode: 'grounding_presence',
    suggestedResponseStyle: 'reduce_overwhelm',
  },
  {
    phrase: 'ngozi',
    language: 'Shona cultural expression',
    literal: 'Avenging spirit',
    emotionalWeight: 'A culturally meaningful way to express fear, distress, or family trauma.',
    targetMode: 'warm_validation',
    suggestedResponseStyle: 'respect_worldview_then_ground',
  },
];

export function matchLocalExpressions(message: string) {
  const normalized = message.toLowerCase();
  return localExpressions.filter((entry) => normalized.includes(entry.phrase.toLowerCase()));
}
