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

  // Multilingual & adversarial red-team checks (audit §3.1 B)
  it('escalates obfuscated / leetspeak English crisis phrases', async () => {
    for (const msg of ['i want to k1ll mys3lf', 'feeling like I want to unalive myself', 'k.y.s tonight']) {
      const result = await safetyNode({ ...base, message: msg });
      expect(result.riskLevel).toBe('high');
      expect(result.escalationRequired).toBe(true);
      expect(result.conversationState).toBe('ESCALATE');
    }
  });

  it('escalates Shona crisis and assault disclosures', async () => {
    for (const msg of [
      'Ndiri kuda kuzviuraya nhasi',
      'Handichadi kurarama, ndoda kufa',
      'Akandibata chibharo nezuro',
    ]) {
      const result = await safetyNode({ ...base, message: msg });
      expect(result.riskLevel).toBe('high');
      expect(result.escalationRequired).toBe(true);
    }
  });

  it('escalates Ndebele and mixed-language crisis disclosures', async () => {
    for (const msg of [
      'Ngifuna ukuzibulala today, everything hurts',
      'Angisafuni ukuphila',
      'Wangidlwengula izolo',
    ]) {
      const result = await safetyNode({ ...base, message: msg });
      expect(result.riskLevel).toBe('high');
      expect(result.escalationRequired).toBe(true);
    }
  });
});
