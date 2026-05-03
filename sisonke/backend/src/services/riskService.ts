export type RiskLevel = 'low' | 'medium' | 'high';

const highRiskTerms = [
  'suicide',
  'kill myself',
  'end my life',
  'hurt myself',
  'abuse',
  'rape',
  'violence',
  'unsafe',
  'being hurt',
];

const mediumRiskTerms = [
  'overwhelmed',
  'panic',
  'alone',
  'hopeless',
  'depressed',
  'self harm',
  'can not cope',
  "can't cope",
];

export function detectRiskLevel(message: string): RiskLevel {
  const normalized = message.toLowerCase();
  if (highRiskTerms.some((term) => normalized.includes(term))) return 'high';
  if (mediumRiskTerms.some((term) => normalized.includes(term))) return 'medium';
  return 'low';
}

export function safeBotReply(message: string, riskLevel: RiskLevel, persona: 'male' | 'female') {
  const friend = persona === 'male' ? 'brother' : 'sister';

  if (riskLevel === 'high') {
    return {
      text: `I am really glad you told me. This sounds serious, so I am connecting you with a trained counselor now. Please move near a trusted person or safe place while we do that.`,
      shouldEscalate: true,
    };
  }

  if (riskLevel === 'medium') {
    return {
      text: `Thank you for opening up. I can stay with you for simple grounding, but it may help to talk to a counselor too. What is one thing making today feel heavy?`,
      shouldEscalate: false,
    };
  }

  return {
    text: `I hear you. As your E-Friend, I can help with general support, self-care ideas, and approved resources. Tell me a little more about what you need, ${friend}.`,
    shouldEscalate: false,
  };
}
