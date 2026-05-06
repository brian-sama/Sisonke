import { desc, eq } from 'drizzle-orm';
import { db } from '../db';
import { analyticsEvents, chatbotMessages, chatbotSessions, counselorCases } from '../db/schema';
import { optionalAuth } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { ChatbotMessageSchema } from '../types';
import { detectRiskLevel, safeBotReply } from '../services/riskService';
import { SocketService } from '../services/socketService';
import { Router } from 'express';
import { invokeSisonkeGraph } from '../ai/graph';

const router = Router();

router.use(optionalAuth);

router.post('/message', asyncHandler(async (req, res) => {
  const input = ChatbotMessageSchema.parse(req.body);
  const riskLevel = detectRiskLevel(input.message);

  const [session] = input.sessionId
    ? await db
      .update(chatbotSessions)
      .set({ riskLevel, updatedAt: new Date() })
      .where(eq(chatbotSessions.id, input.sessionId))
      .returning()
    : await db.insert(chatbotSessions).values({
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
  const history = await db
    .select()
    .from(chatbotMessages)
    .where(eq(chatbotMessages.sessionId, session.id))
    .orderBy(desc(chatbotMessages.createdAt))
    .limit(5);

  const formattedHistory = history
    .reverse()
    .map(m => ({ sender: m.sender as 'user' | 'bot', content: m.content }));

  await db.insert(chatbotMessages).values({
    sessionId: session.id,
    sender: 'user',
    content: input.message,
    riskLevel,
  });

  const fallbackReply = safeBotReply(input.message, riskLevel, input.persona);

  const graphResult = await invokeSisonkeGraph({
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
  let caseId: string | undefined;

  if (finalRiskLevel === 'high') {
    const [createdCase] = await db.insert(counselorCases).values({
      userId: req.user?.id,
      issueCategory: 'High-risk chatbot escalation',
      status: 'escalated',
      riskLevel: 'high',
      source: 'chatbot',
      summary: (graphResult.handoffSummary || input.message).slice(0, 2000),
      updatedAt: new Date(),
    }).returning();
    caseId = createdCase.id;
    await db
      .update(chatbotSessions)
      .set({ escalatedCaseId: caseId, updatedAt: new Date() })
      .where(eq(chatbotSessions.id, session.id));
    await db.insert(analyticsEvents).values({
      event: 'counselor_escalated',
      category: 'chatbot',
      metadata: {
        riskLevel: finalRiskLevel,
        conversationState: graphResult.conversationState,
        emotion: graphResult.detectedPrimaryEmotion,
      },
    });
    SocketService.broadcastDashboardUpdate({ type: 'counselor_case', action: 'escalated' });
  }

  await db.insert(chatbotMessages).values({
    sessionId: session.id,
    sender: 'bot',
    content: reply.text,
    riskLevel: finalRiskLevel,
  });

  await db.insert(analyticsEvents).values({
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
  
  SocketService.broadcastDashboardUpdate({ type: 'chatbot_session', action: 'created' });

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

export default router;
