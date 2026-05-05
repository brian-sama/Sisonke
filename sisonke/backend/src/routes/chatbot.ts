import { desc, eq } from 'drizzle-orm';
import { db } from '../db';
import { analyticsEvents, chatbotMessages, chatbotSessions, counselorCases } from '../db/schema';
import { optionalAuth } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { ChatbotMessageSchema } from '../types';
import { detectRiskLevel, safeBotReply } from '../services/riskService';
import { generateLocalChatReply } from '../services/ollamaService';
import { generateGeminiFallback } from '../services/geminiService';
import { RagService } from '../services/ragService';
import { SocketService } from '../services/socketService';
import { Router } from 'express';

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

  const approvedContext = await RagService.getGroundingContext(input.message);
  const fallbackReply = safeBotReply(input.message, riskLevel, input.persona);
  
  const localReply = await generateLocalChatReply({
    message: input.message,
    history: formattedHistory,
    persona: input.persona,
    riskLevel,
    approvedContext,
  });
  
  const geminiReply = await generateGeminiFallback({
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
  let caseId: string | undefined;

  if (riskLevel === 'high') {
    const [createdCase] = await db.insert(counselorCases).values({
      userId: req.user?.id,
      issueCategory: 'High-risk chatbot escalation',
      status: 'escalated',
      riskLevel: 'high',
      source: 'chatbot',
      summary: input.message.slice(0, 2000),
      updatedAt: new Date(),
    }).returning();
    caseId = createdCase.id;
    await db
      .update(chatbotSessions)
      .set({ escalatedCaseId: caseId, updatedAt: new Date() })
      .where(eq(chatbotSessions.id, session.id));
    await db.insert(analyticsEvents).values({ event: 'counselor_escalated', category: 'chatbot', metadata: { riskLevel } });
    SocketService.broadcastDashboardUpdate({ type: 'counselor_case', action: 'escalated' });
  }

  await db.insert(chatbotMessages).values({
    sessionId: session.id,
    sender: 'bot',
    content: reply.text,
    riskLevel,
  });

  await db.insert(analyticsEvents).values({
    event: 'chatbot_session_started',
    category: riskLevel,
    metadata: { persona: input.persona },
  });
  
  SocketService.broadcastDashboardUpdate({ type: 'chatbot_session', action: 'created' });

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

export default router;
