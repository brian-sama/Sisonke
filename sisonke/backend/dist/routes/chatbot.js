"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const riskService_1 = require("../services/riskService");
const socketService_1 = require("../services/socketService");
const express_1 = require("express");
const graph_1 = require("../ai/graph");
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
    const fallbackReply = (0, riskService_1.safeBotReply)(input.message, riskLevel, input.persona);
    const graphResult = await (0, graph_1.invokeSisonkeGraph)({
        userId: req.user?.id,
        deviceId: input.deviceId,
        sessionId: session.id,
        message: input.message,
        persona: input.persona,
        riskLevel,
        turnsElapsed: history.length,
        history: formattedHistory,
    });
    const finalRiskLevel = graphResult.riskLevel || riskLevel;
    const reply = {
        ...fallbackReply,
        text: graphResult.response || fallbackReply.text,
    };
    let caseId;
    if (finalRiskLevel === 'high') {
        const [createdCase] = await db_1.db.insert(schema_1.counselorCases).values({
            userId: req.user?.id,
            issueCategory: 'High-risk chatbot escalation',
            status: 'escalated',
            riskLevel: 'high',
            source: 'chatbot',
            summary: (graphResult.handoffSummary || input.message).slice(0, 2000),
            updatedAt: new Date(),
        }).returning();
        caseId = createdCase.id;
        await db_1.db
            .update(schema_1.chatbotSessions)
            .set({ escalatedCaseId: caseId, updatedAt: new Date() })
            .where((0, drizzle_orm_1.eq)(schema_1.chatbotSessions.id, session.id));
        await db_1.db.insert(schema_1.analyticsEvents).values({
            event: 'counselor_escalated',
            category: 'chatbot',
            metadata: {
                riskLevel: finalRiskLevel,
                conversationState: graphResult.conversationState,
                emotion: graphResult.detectedPrimaryEmotion,
            },
        });
        socketService_1.SocketService.broadcastDashboardUpdate({ type: 'counselor_case', action: 'escalated' });
    }
    await db_1.db.insert(schema_1.chatbotMessages).values({
        sessionId: session.id,
        sender: 'bot',
        content: reply.text,
        riskLevel: finalRiskLevel,
    });
    await db_1.db.insert(schema_1.analyticsEvents).values({
        event: 'chatbot_session_started',
        category: finalRiskLevel,
        metadata: {
            persona: input.persona,
            conversationState: graphResult.conversationState,
            emotion: graphResult.detectedPrimaryEmotion,
            intent: graphResult.detectedIntent,
            localExpressions: graphResult.matchedLocalExpressions?.map((item) => item.phrase) || [],
            aiProvider: graphResult.aiProvider || 'rules',
            fallbackReason: graphResult.fallbackReason,
        },
    });
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'chatbot_session', action: 'created' });
    res.json({
        success: true,
        data: {
            sessionId: session.id,
            reply: reply.text,
            riskLevel: finalRiskLevel,
            conversationState: graphResult.conversationState || (finalRiskLevel === 'high' ? 'ESCALATE' : 'EXPLORE'),
            primaryEmotion: graphResult.detectedPrimaryEmotion || 'unclear',
            intent: graphResult.detectedIntent || 'sharing_feelings',
            intervention: graphResult.interventionId ? {
                id: graphResult.interventionId,
                text: graphResult.interventionText,
            } : null,
            escalationRequired: finalRiskLevel === 'high',
            counselorCaseId: caseId,
            grounded: Boolean(graphResult.approvedContext),
            aiProvider: finalRiskLevel === 'high' ? 'rules' : graphResult.aiProvider || 'rules',
            safetySource: graphResult.safetySource || 'rules',
        },
    });
}));
exports.default = router;
//# sourceMappingURL=chatbot.js.map