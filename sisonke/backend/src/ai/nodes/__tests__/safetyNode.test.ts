import { safetyNode } from '../safetyNode';
import type { SisonkeGraphState } from '../../types';

const base: SisonkeGraphState = {
  message: '',
  persona: 'female',
};

describe('safetyNode', () => {
  it('returns low risk for a neutral message', async () => {
    const result = await safetyNode({ ...base, message: 'I am feeling a bit tired today' });
    expect(result.riskLevel).toBe('low');
    expect(result.escalationRequired).toBe(false);
    expect(result.conversationState).not.toBe('ESCALATE');
  });

  it('returns high risk and sets ESCALATE for a suicidal statement', async () => {
    const result = await safetyNode({ ...base, message: 'I want to kill myself tonight' });
    expect(result.riskLevel).toBe('high');
    expect(result.escalationRequired).toBe(true);
    expect(result.conversationState).toBe('ESCALATE');
  });

  it('returns high risk for a self-harm phrase', async () => {
    const result = await safetyNode({ ...base, message: 'I have been cutting myself' });
    expect(result.riskLevel).toBe('high');
    expect(result.escalationRequired).toBe(true);
  });

  it('returns high risk for a sexual assault disclosure', async () => {
    const result = await safetyNode({ ...base, message: 'someone raped me last night' });
    expect(result.riskLevel).toBe('high');
    expect(result.escalationRequired).toBe(true);
  });

  it('does not override an already-flagged high risk level passed in state', async () => {
    const result = await safetyNode({ ...base, message: 'hello', riskLevel: 'high' });
    expect(result.riskLevel).toBe('high');
  });

  it('uses safetySource of rules (not a model)', async () => {
    const result = await safetyNode({ ...base, message: 'I am fine' });
    expect(result.safetySource).toBe('rules');
  });
});
