"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateGeminiFallback = generateGeminiFallback;
function shouldUseGeminiFallback(message, localReply) {
    if (!process.env.GEMINI_API_KEY)
        return false;
    // Loosen to allow all low-risk queries to benefit from Gemini's conversational ability
    return true;
}
async function generateGeminiFallback(input) {
    if (input.riskLevel === 'high')
        return undefined;
    if (!shouldUseGeminiFallback(input.message, input.localReply))
        return undefined;
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey)
        return undefined;
    const model = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
    const baseUrl = process.env.GEMINI_BASE_URL || 'https://generativelanguage.googleapis.com/v1beta';
    const personaLabel = input.persona === 'male' ? 'male peer supporter' : 'female peer supporter';
    const historyLines = input.history?.map(h => `${h.sender === 'user' ? 'User' : 'E-Friend'}: ${h.content}`).join('\n') || '';
    const prompt = [
        `You are E-Friend, a warm ${personaLabel} in a youth wellness app in Zimbabwe.`,
        'Ubuntu Style: Be warm, empathetic, and respectful. Use clear, simple Grade 7 English.',
        'Guidance: Give general support and approved-resource guidance only. Do not diagnose or provide therapy.',
        'Rules: If the user is in severe crisis, stop chat and tell them to contact a human counselor immediately.',
        'Context: Use the provided approved context as your source of truth for resources.',
        '',
        input.approvedContext ? `Approved Context:\n${input.approvedContext}\n` : '',
        historyLines ? `Previous Conversation:\n${historyLines}\n` : '',
        `User: ${input.message}`,
        'E-Friend:',
    ].join('\n');
    try {
        const response = await fetch(`${baseUrl}/models/${model}:generateContent?key=${apiKey}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                contents: [{ parts: [{ text: prompt }] }],
                generationConfig: {
                    temperature: 0.7, // Slightly higher for more natural small talk
                    maxOutputTokens: 160,
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