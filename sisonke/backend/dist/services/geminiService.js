"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateGeminiFallback = generateGeminiFallback;
function shouldUseGeminiFallback(message, localReply) {
    if (!process.env.GEMINI_API_KEY)
        return false;
    if (!localReply || localReply.trim().length < 20)
        return true;
    const normalized = message.toLowerCase();
    return [
        'contraception',
        'pregnant',
        'pregnancy',
        'translate',
        'summarize',
        'summarise',
        'explain',
        'srhr',
    ].some((term) => normalized.includes(term));
}
async function generateGeminiFallback(input) {
    if (input.riskLevel === 'high')
        return undefined;
    if (!shouldUseGeminiFallback(input.message, input.localReply))
        return undefined;
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey)
        return undefined;
    const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
    const baseUrl = process.env.GEMINI_BASE_URL || 'https://generativelanguage.googleapis.com/v1beta';
    const personaLabel = input.persona === 'male' ? 'male peer supporter' : 'female peer supporter';
    const prompt = [
        `You are E-Friend, a warm ${personaLabel} in a youth wellness app in Zimbabwe.`,
        'Give general support and approved-resource guidance only.',
        'Do not diagnose, do not provide therapy, and do not continue crisis support alone.',
        'For suicide, abuse, violence, or severe crisis, tell the user a trained counselor must help immediately.',
        'Use approved context when available. Do not invent organization-specific facts.',
        'Keep the reply under 100 words.',
        '',
        input.approvedContext ? `Approved context:\n${input.approvedContext}\n` : '',
        input.localReply ? `Local draft:\n${input.localReply}\n` : '',
        `User message: ${input.message}`,
    ].join('\n');
    try {
        const response = await fetch(`${baseUrl}/models/${model}:generateContent?key=${apiKey}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                contents: [{ parts: [{ text: prompt }] }],
                generationConfig: {
                    temperature: 0.3,
                    maxOutputTokens: 160,
                    thinkingConfig: {
                        thinkingBudget: 0,
                    },
                },
            }),
            signal: AbortSignal.timeout(Number(process.env.GEMINI_TIMEOUT_MS || 15000)),
        });
        if (!response.ok)
            return undefined;
        const data = await response.json();
        return data.candidates?.[0]?.content?.parts
            ?.map((part) => part.text || '')
            .join('')
            .trim() || undefined;
    }
    catch {
        return undefined;
    }
}
//# sourceMappingURL=geminiService.js.map