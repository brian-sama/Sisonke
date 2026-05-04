import { safetyRules, SafetyRoute, zimbabweEmergencyContacts } from '../data/zimbabweRagKnowledge';

export type RiskLevel = 'low' | 'medium' | 'high';

type RiskDetection = {
  level: RiskLevel;
  route?: SafetyRoute;
};

export function detectRisk(message: string): RiskDetection {
  const normalized = message.toLowerCase().replace(/\s+/g, ' ').trim();

  const redRule = safetyRules.find((rule) => rule.risk === 'red' && rule.terms.some((term) => normalized.includes(term)));
  if (redRule) return { level: 'high', route: redRule.route };

  const amberRule = safetyRules.find((rule) => rule.risk === 'amber' && rule.terms.some((term) => normalized.includes(term)));
  if (amberRule) return { level: 'medium', route: amberRule.route };

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
    };
  }

  if (riskLevel === 'medium') {
    return {
      text: `Thank you for opening up. I can stay with you for simple grounding, but a human supporter may help too. Try one slow breath now, then tell me one thing making today feel heavy.`,
      shouldEscalate: false,
    };
  }

  return {
    text: `I hear you, ${friend}. I can help with general support, self-care ideas, and approved Zimbabwe resources. Tell me a little more about what you need today.`,
    shouldEscalate: false,
  };
}
