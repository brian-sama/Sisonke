import { safetyRules, SafetyRoute, zimbabweEmergencyContacts } from '../data/zimbabweRagKnowledge';

export type RiskLevel = 'low' | 'medium' | 'high';

type RiskDetection = {
  level: RiskLevel;
  route?: SafetyRoute;
};

const LEET_MAP: Record<string, string> = {
  '0': 'o',
  '1': 'i',
  '3': 'e',
  '4': 'a',
  '5': 's',
  '7': 't',
  '@': 'a',
  '$': 's',
};

/**
 * Normalizes slang, leetspeak, punctuation obfuscation, and repeated letters
 * so safety rules catch spelling variations across English, Shona, and Ndebele
 * (audit §3.1 B).
 */
export function normalizeSafetyText(message: string): string {
  const lowered = message.toLowerCase();
  const deleeted = lowered.replace(/[013457@$]/g, (ch) => LEET_MAP[ch] ?? ch);
  return deleeted
    .replace(/[^a-z\s]/g, ' ')
    .replace(/([a-z])\1{2,}/g, '$1$1')
    .replace(/\s+/g, ' ')
    .trim();
}

const MULTILINGUAL_RED_PATTERNS: Array<{ route: SafetyRoute; pattern: RegExp }> = [
  // English slang / obfuscated / indirect self-harm & suicide
  {
    route: 'self_harm',
    pattern:
      /\b(k\s*y\s*s|unalive\s+myself|end\s+my\s+life|want\s+to\s+die|wanna\s+die|take\s+my\s+own\s+life|kill\s+myself|hang\s+myself|cut\s+myself|cutting\s+myself|overdose\s+on\s+pills)\b/,
  },
  // Shona crisis & self-harm phrases (including common spelling variants)
  {
    route: 'self_harm',
    pattern:
      /\b(kuzviuraya|ndoda\s+kufa|ndirikuda\s+kufa|ndiri\s+kuda\s+kufa|ndoda\s+kuzviuraya|ndiri\s+kuda\s+kuzviuraya|ndichazviuraya|handichadi\s+kurarama|zviri\s+nani\s+ndife|ndinoda\s+kufa)\b/,
  },
  // Ndebele crisis & self-harm phrases
  {
    route: 'self_harm',
    pattern:
      /\b(ukuzibulala|ngifuna\s+ukufa|ngizozibulala|ngizibulale|angisafuni\s+ukuphila|ngifuna\s+ukuzibulala|kungcono\s+ngife)\b/,
  },
  // English, Shona & Ndebele sexual assault / abuse disclosures
  {
    route: 'sexual_assault',
    pattern:
      /\b(raped|rape|sexually\s+assaulted|sexual\s+assault|molested|akandibata\s+chibharo|ndakabatwa\s+chibharo|wandibata\s+chibharo|wangidlwengula|ngadlwengulwa|forced\s+himself\s+on\s+me)\b/,
  },
];

export const AI_CLINICAL_DISCLAIMER =
  'Sisonke AI provides supportive information and is not a substitute for professional medical diagnosis or emergency care.';

export function detectRisk(message: string): RiskDetection {
  const rawNormalized = message.toLowerCase().replace(/\s+/g, ' ').trim();
  const normalized = normalizeSafetyText(message);

  for (const candidate of [rawNormalized, normalized]) {
    const redRule = safetyRules.find(
      (rule) => rule.risk === 'red' && rule.terms.some((term) => candidate.includes(term)),
    );
    if (redRule) return { level: 'high', route: redRule.route };
  }

  for (const extra of MULTILINGUAL_RED_PATTERNS) {
    if (extra.pattern.test(normalized)) {
      return { level: 'high', route: extra.route };
    }
  }

  for (const candidate of [rawNormalized, normalized]) {
    const amberRule = safetyRules.find(
      (rule) => rule.risk === 'amber' && rule.terms.some((term) => candidate.includes(term)),
    );
    if (amberRule) return { level: 'medium', route: amberRule.route };
  }

  return { level: 'low' };
}

export function detectRiskLevel(message: string): RiskLevel {
  return detectRisk(message).level;
}

function contactLine(ids: string[]) {
  return ids
    .map((id) => zimbabweEmergencyContacts.find((contact) => contact.id === id))
    .filter(Boolean)
    .map((contact) => `${contact!.name}: ${contact!.phoneNumber}`)
    .join('\n');
}

function highRiskReply(route?: SafetyRoute) {
  if (route === 'sexual_assault') {
    return [
      'I am really sorry this happened. This is not your fault, and you need human help now.',
      'Please move to a safer place or trusted adult if you can. Get medical care as soon as possible because HIV prevention medicine called PEP is time-sensitive.',
      contactLine(['zw-adult-rape-clinic', 'zw-childline-116', 'zw-musasa-econet', 'zw-national-emergency']),
      'Ask for the Victim Friendly Unit at the nearest police station if you need to report safely.',
    ].join('\n\n');
  }

  if (route === 'active_violence' || route === 'forced_marriage') {
    return [
      'I am glad you told me. Your safety comes first right now.',
      'If it is safe to move, go near other people: a neighbor, school office, clinic, church office, or trusted adult. Stay away from kitchens, garages, or locked rooms if violence is happening.',
      contactLine(['zw-childline-116', 'zw-musasa-econet', 'zw-national-emergency']),
      'If you go to police, ask for the Victim Friendly Unit.',
    ].join('\n\n');
  }

  if (route === 'substance_emergency') {
    return [
      'This could be medically urgent. Please do not try to sleep it off or handle it alone.',
      'Tell someone nearby exactly what was taken and get medical help now, especially if there is chest pain, trouble breathing, collapse, confusion, or violence.',
      contactLine(['zw-national-emergency', 'zw-childline-116', 'zw-ubh', 'zw-parirenyatwa']),
    ].join('\n\n');
  }

  return [
    'I am really glad you told me. You do not have to carry this alone.',
    'Please move away from anything you could use to hurt yourself and go near one trusted person if you can. Tell them: I am not safe alone right now.',
    contactLine(['zw-childline-116', 'zw-friendship-bench', 'zw-national-emergency']),
  ].join('\n\n');
}

export function safeBotReply(message: string, riskLevel: RiskLevel, persona: 'male' | 'female') {
  const friend = persona === 'male' ? 'brother' : 'sister';
  const detection = detectRisk(message);

  if (riskLevel === 'high') {
    return {
      text: highRiskReply(detection.route),
      shouldEscalate: true,
      disclaimer: AI_CLINICAL_DISCLAIMER,
    };
  }

  if (riskLevel === 'medium') {
    return {
      text: `Thank you for opening up. I can stay with you for simple grounding, but a human supporter may help too. Try one slow breath now, then tell me one thing making today feel heavy.`,
      shouldEscalate: false,
      disclaimer: AI_CLINICAL_DISCLAIMER,
    };
  }

  return {
    text: `I hear you, ${friend}. I can help with general support, self-care ideas, and approved Zimbabwe resources. Tell me a little more about what you need today.`,
    shouldEscalate: false,
    disclaimer: AI_CLINICAL_DISCLAIMER,
  };
}
