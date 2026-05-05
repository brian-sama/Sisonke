"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const riskService_1 = require("../services/riskService");
const ollamaService_1 = require("../services/ollamaService");
const geminiService_1 = require("../services/geminiService");
const ragService_1 = require("../services/ragService");
const socketService_1 = require("../services/socketService");
const express_1 = require("express");
const router = (0, express_1.Router)();
router.use(auth_1.optionalAuth);
router.post('/message', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.ChatbotMessageSchema.parse(req.body);
    const riskLevel = (0, riskService_1.detectRiskLevel)(input.message);
    const [session] = input.sessionId
        ? await db_1.db
            .update(schema_1.chatbotSessions)
            .set({ riskLevel, updatedAt: new Date() })
            .where((0, drizzle_orm_1.eq)(schema_1.chatbotSessions.id, input.sessionId))
            .returning()
        : await db_1.db.insert(schema_1.chatbotSessions).values({
            userId: req.user?.id,
            deviceId: input.deviceId,
            persona: input.persona,
            riskLevel,
            updatedAt: new Date(),
        }).returning();
    if (!session) {
        return res.status(404).json({ success: false, error: 'Chat session not found.' });
    }
    // Fetch history BEFORE inserting current message to keep history clean for the AI
    const history = await db_1.db
        .select()
        .from(schema_1.chatbotMessages)
        .where((0, drizzle_orm_1.eq)(schema_1.chatbotMessages.sessionId, session.id))
        .orderBy((0, drizzle_orm_1.desc)(schema_1.chatbotMessages.createdAt))
        .limit(5);
    const formattedHistory = history
        .reverse()
        .map(m => ({ sender: m.sender, content: m.content }));
    await db_1.db.insert(schema_1.chatbotMessages).values({
        sessionId: session.id,
        sender: 'user',
        content: input.message,
        riskLevel,
    });
    const approvedContext = await ragService_1.RagService.getGroundingContext(input.message);
    const fallbackReply = (0, riskService_1.safeBotReply)(input.message, riskLevel, input.persona);
    const localReply = await (0, ollamaService_1.generateLocalChatReply)({
        message: input.message,
        history: formattedHistory,
        persona: input.persona,
        riskLevel,
        approvedContext,
    });
    const geminiReply = await (0, geminiService_1.generateGeminiFallback)({
        message: input.message,
        history: formattedHistory,
        persona: input.persona,
        riskLevel,
        approvedContext,
        localReply,
    });
    const reply = {
        ...fallbackReply,
        text: geminiReply || localReply || fallbackReply.text,
    };
    let caseId;
    if (riskLevel === 'high') {
        const [createdCase] = await db_1.db.insert(schema_1.counselorCases).values({
            userId: req.user?.id,
            issueCategory: 'High-risk chatbot escalation',
            status: 'escalated',
            riskLevel: 'high',
            source: 'chatbot',
            summary: input.message.slice(0, 2000),
            updatedAt: new Date(),
        }).returning();
        caseId = createdCase.id;
        await db_1.db
            .update(schema_1.chatbotSessions)
            .set({ escalatedCaseId: caseId, updatedAt: new Date() })
            .where((0, drizzle_orm_1.eq)(schema_1.chatbotSessions.id, session.id));
        await db_1.db.insert(schema_1.analyticsEvents).values({ event: 'counselor_escalated', category: 'chatbot', metadata: { riskLevel } });
        socketService_1.SocketService.broadcastDashboardUpdate({ type: 'counselor_case', action: 'escalated' });
    }
    await db_1.db.insert(schema_1.chatbotMessages).values({
        sessionId: session.id,
        sender: 'bot',
        content: reply.text,
        riskLevel,
    });
    await db_1.db.insert(schema_1.analyticsEvents).values({
        event: 'chatbot_session_started',
        category: riskLevel,
        metadata: { persona: input.persona },
    });
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'chatbot_session', action: 'created' });
    res.json({
        success: true,
        data: {
            sessionId: session.id,
            reply: reply.text,
            riskLevel,
            escalationRequired: riskLevel === 'high',
            counselorCaseId: caseId,
            grounded: approvedContext.length > 0,
            aiProvider: riskLevel === 'high' ? 'none' : geminiReply ? 'gemini' : localReply ? 'ollama' : 'rules',
        },
    });
}));
exports.default = router;
//# sourceMappingURL=chatbot.js.map