import { emotionNode } from '../emotionNode';
import type { SisonkeGraphState } from '../../types';

const base: SisonkeGraphState = {
  message: '',
  persona: 'female',
};

describe('emotionNode', () => {
  it('detects exhaustion from English keyword', async () => {
    const result = await emotionNode({ ...base, message: 'I am so tired and burnt out' });
    expect(result.detectedPrimaryEmotion).toBe('exhausted');
  });

  it('detects exhaustion from Ndebele keyword ngikhathele', async () => {
    const result = await emotionNode({ ...base, message: 'ngikhathele kakhulu' });
    expect(result.detectedPrimaryEmotion).toBe('exhausted');
    expect(result.detectedLanguage).not.toBe('unknown');
  });

  it('detects exhaustion from Shona keyword ndakaneta', async () => {
    const result = await emotionNode({ ...base, message: 'ndakaneta zvakanyanya' });
    expect(result.detectedPrimaryEmotion).toBe('exhausted');
  });

  it('detects overwhelmed emotion', async () => {
    const result = await emotionNode({ ...base, message: 'I am completely overwhelmed right now' });
    expect(result.detectedPrimaryEmotion).toBe('overwhelmed');
    expect(result.personaMode).toBe('grounding_presence');
  });

  it('detects sadness', async () => {
    const result = await emotionNode({ ...base, message: 'I feel so empty and lonely' });
    expect(result.detectedPrimaryEmotion).toBe('sad');
  });

  it('detects closing intent', async () => {
    const result = await emotionNode({ ...base, message: 'thanks i need to go now bye' });
    expect(result.detectedIntent).toBe('closing');
  });

  it('detects seeking support intent', async () => {
    const result = await emotionNode({ ...base, message: 'what do i do, i need help' });
    expect(result.detectedIntent).toBe('seeking_support');
  });

  it('returns matchedLocalExpressions array', async () => {
    const result = await emotionNode({ ...base, message: 'I am okay' });
    expect(Array.isArray(result.matchedLocalExpressions)).toBe(true);
  });
});
