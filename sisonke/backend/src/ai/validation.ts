import { systemFallbacks } from './data/fallbacks';

const unsafePatterns = [
  /\bdiagnos(e|is|ed)\b/i,
  /\b(stop|start|increase|decrease)\s+(your\s+)?(medication|medicine|pills)\b/i,
  /\bguarantee\b/i,
  /\byou should kill\b/i,
  /\bhurt yourself\b/i,
  /\bit'?s your fault\b/i,
  /\beverything will be okay\b/i,
];

function sentenceCount(text: string) {
  return text.split(/[.!?]+/).map((part) => part.trim()).filter(Boolean).length;
}

export function validateModelOutput(text?: string) {
  const trimmed = (text || '').trim();
  if (!trimmed) {
    return { text: systemFallbacks.llm_timeout, fallbackReason: 'empty_output' };
  }

  if (unsafePatterns.some((pattern) => pattern.test(trimmed))) {
    return {
      text: systemFallbacks.toxic_output_caught_by_filter,
      fallbackReason: 'unsafe_output',
    };
  }

  const words = trimmed.split(/\s+/);
  const uniqueWords = new Set(words.map((word) => word.toLowerCase()));
  if (words.length > 12 && uniqueWords.size / words.length < 0.45) {
    return {
      text: systemFallbacks.repetition_detected,
      fallbackReason: 'repetition_detected',
    };
  }

  if (sentenceCount(trimmed) > 3) {
    const shortened = trimmed.match(/[^.!?]+[.!?]+/g)?.slice(0, 3).join(' ').trim();
    return { text: shortened || trimmed.split(/\s+/).slice(0, 45).join(' '), fallbackReason: 'trimmed_length' };
  }

  return { text: trimmed };
}
