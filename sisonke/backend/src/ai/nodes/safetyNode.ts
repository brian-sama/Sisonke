import { detectRisk } from '../../services/riskService';
import { SisonkeGraphState } from '../types';

export async function safetyNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  const detection = detectRisk(state.message);
  // Always run fresh detection — never let the caller downgrade a safe check.
  // Caller-supplied 'high' is honoured (e.g. counselor override) but cannot suppress a detected high.
  const riskLevel = state.riskLevel === 'high' || detection.level === 'high'
    ? 'high'
    : detection.level === 'medium' || state.riskLevel === 'medium'
      ? 'medium'
      : 'low';

  return {
    riskLevel,
    escalationRequired: riskLevel === 'high',
    safetySource: 'rules',
    conversationState: riskLevel === 'high' ? 'ESCALATE' : state.conversationState,
  };
}
