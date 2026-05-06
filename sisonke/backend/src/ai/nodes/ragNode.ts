import { RagService } from '../../services/ragService';
import { selectIntervention } from '../data/interventions';
import { SisonkeGraphState } from '../types';

export async function ragNode(state: SisonkeGraphState): Promise<Partial<SisonkeGraphState>> {
  if (state.response || state.riskLevel === 'high') return {};

  const approvedContext = state.approvedContext || await RagService.getGroundingContext(state.message);
  const intervention = selectIntervention(state.message, state.detectedPrimaryEmotion);

  return {
    approvedContext,
    interventionId: intervention?.id,
    interventionText: intervention
      ? `${intervention.exerciseName}: ${intervention.instructionBlocks.slice(0, 2).join(' ')}`
      : undefined,
    personaMode: intervention && state.conversationState === 'GROUNDING'
      ? 'practical_support'
      : state.personaMode,
  };
}
