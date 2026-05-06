import { detectRisk } from '../../services/riskService';
import { SisonkeGraphState } from '../types';

export async function safetyNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  const detection = detectRisk(state.message);
  return {
    riskLevel: state.riskLevel || detection.level,
    escalationRequired: detection.level === 'high',
    safetySource: 'rules',
    conversationState: detection.level === 'high' ? 'ESCALATE' : state.conversationState,
  };
}
