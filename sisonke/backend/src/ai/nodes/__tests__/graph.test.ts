import { invokeSisonkeGraph } from '../../graph';
import type { SisonkeGraphInput } from '../../types';

// Mock both AI providers so tests never make real network calls.
jest.mock('../localModelNode', () => ({
  localModelNode: jest.fn(async () => ({ response: 'mock-local-response', aiProvider: 'ollama' })),
}));
jest.mock('../geminiFallbackNode', () => ({
  geminiFallbackNode: jest.fn(async () => ({})),
}));

const base: SisonkeGraphInput = {
  message: '',
  persona: 'female',
};

describe('sisonkeGraph — routing invariants', () => {
  it('routes a neutral message all the way to a response without escalating', async () => {
    const result = await invokeSisonkeGraph({ ...base, message: 'I am feeling okay today' });
    expect(result.escalationRequired).not.toBe(true);
    expect(result.response).toBeTruthy();
  });

  it('CRITICAL: a suicidal message must never reach localModelNode or geminiFallbackNode', async () => {
    const { localModelNode } = require('../localModelNode');
    const { geminiFallbackNode } = require('../geminiFallbackNode');
    (localModelNode as jest.Mock).mockClear();
    (geminiFallbackNode as jest.Mock).mockClear();

    await invokeSisonkeGraph({ ...base, message: 'I want to end my life tonight' });

    expect(localModelNode).not.toHaveBeenCalled();
    expect(geminiFallbackNode).not.toHaveBeenCalled();
  });

  it('CRITICAL: a high-risk message sets escalationRequired=true and returns a hardcoded response', async () => {
    const result = await invokeSisonkeGraph({ ...base, message: 'I want to kill myself' });
    expect(result.escalationRequired).toBe(true);
    expect(result.riskLevel).toBe('high');
    expect(result.response).toBeTruthy();
    expect(result.aiProvider).toBe('rules');
  });

  it('CRITICAL: a sexual assault disclosure routes to escalation without LLM', async () => {
    const { localModelNode } = require('../localModelNode');
    (localModelNode as jest.Mock).mockClear();

    const result = await invokeSisonkeGraph({ ...base, message: 'someone raped me' });

    expect(result.riskLevel).toBe('high');
    expect(result.escalationRequired).toBe(true);
    expect(localModelNode).not.toHaveBeenCalled();
  });

  it('a greeting on turn 0 short-circuits to a rules-based response without LLM', async () => {
    const { localModelNode } = require('../localModelNode');
    (localModelNode as jest.Mock).mockClear();

    const result = await invokeSisonkeGraph({ ...base, message: 'hello', turnsElapsed: 0 });

    expect(result.aiProvider).toBe('rules');
    expect(result.response).toBeTruthy();
    expect(localModelNode).not.toHaveBeenCalled();
  });

  it('a medium-risk message does not escalate but produces a response', async () => {
    const result = await invokeSisonkeGraph({ ...base, message: 'I have been drinking heavily lately' });
    expect(result.escalationRequired).not.toBe(true);
    expect(result.response).toBeTruthy();
  });

  it('populates handoffSummary only on high-risk escalation', async () => {
    const highRisk = await invokeSisonkeGraph({ ...base, message: 'I want to die' });
    expect(highRisk.handoffSummary).toBeTruthy();

    const lowRisk = await invokeSisonkeGraph({ ...base, message: 'I am a bit sad today' });
    expect(lowRisk.handoffSummary).toBeFalsy();
  });
});
