import { stageNode } from '../stageNode';
import type { SisonkeGraphState } from '../../types';

const base: SisonkeGraphState = {
  message: '',
  persona: 'female',
};

describe('stageNode', () => {
  it('returns INIT state and a deterministic greeting for a first-turn hello', async () => {
    const result = await stageNode({ ...base, message: 'hello', turnsElapsed: 0 });
    expect(result.conversationState).toBe('INIT');
    expect(result.response).toBeTruthy();
    expect(result.aiProvider).toBe('rules');
  });

  it('treats Shona greeting mhoroi as INIT', async () => {
    const result = await stageNode({ ...base, message: 'mhoroi', turnsElapsed: 0 });
    expect(result.conversationState).toBe('INIT');
    expect(result.response).toBeTruthy();
  });

  it('treats Ndebele greeting sawubona as INIT', async () => {
    const result = await stageNode({ ...base, message: 'sawubona', turnsElapsed: 0 });
    expect(result.conversationState).toBe('INIT');
    expect(result.response).toBeTruthy();
  });

  it('bypasses greeting for hello said mid-conversation', async () => {
    const result = await stageNode({ ...base, message: 'hello', turnsElapsed: 3 });
    expect(result.conversationState).not.toBe('INIT');
  });

  it('sets GROUNDING when emotion is overwhelmed', async () => {
    const result = await stageNode({
      ...base,
      message: 'I cannot cope',
      detectedPrimaryEmotion: 'overwhelmed',
      turnsElapsed: 2,
    });
    expect(result.conversationState).toBe('GROUNDING');
    expect(result.personaMode).toBe('grounding_presence');
  });

  it('sets WIND_DOWN when intent is closing', async () => {
    const result = await stageNode({
      ...base,
      message: 'thanks bye',
      detectedIntent: 'closing',
    });
    expect(result.conversationState).toBe('WIND_DOWN');
  });

  it('sets EXPLORE for early turns with no specific emotion', async () => {
    const result = await stageNode({ ...base, message: 'I have a lot going on', turnsElapsed: 1 });
    expect(result.conversationState).toBe('EXPLORE');
  });

  it('sets SUPPORT_OR_LISTEN for later turns', async () => {
    const result = await stageNode({ ...base, message: 'I have a lot going on', turnsElapsed: 5 });
    expect(result.conversationState).toBe('SUPPORT_OR_LISTEN');
  });

  it('forces ESCALATE state when riskLevel is high', async () => {
    const result = await stageNode({ ...base, message: 'I want to die', riskLevel: 'high' });
    expect(result.conversationState).toBe('ESCALATE');
    expect(result.personaMode).toBe('hardcoded_escalation');
  });
});
