import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { questions, answers, reports } from '../db/schema';
import { eq, and, desc, asc } from 'drizzle-orm';
import { CreateQuestionSchema, CreateAnswerSchema, QuestionQuerySchema } from '../types';
import { optionalAuth, authMiddleware, adminOnly, hasAnyRole } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

// Get all questions with filtering
router.get('/', optionalAuth, asyncHandler(async (req, res) => {
  const query = QuestionQuerySchema.parse(req.query);
  
  let baseQuery = db.select().from(questions).$dynamic();
  
  // Add filters
  const conditions = [];
  
  if (query.category) {
    conditions.push(eq(questions.category, query.category));
  }
  
  if (query.answered !== undefined) {
    conditions.push(eq(questions.isAnswered, query.answered));
  }
  
  // Only show published questions to non-admin users
  if (!hasAnyRole(req.user, ['admin', 'super-admin'])) {
    conditions.push(eq(questions.status, 'published'));
    conditions.push(eq(questions.isPublished, true));
  }
  
  // Apply conditions
  if (conditions.length > 0) {
    baseQuery = baseQuery.where(and(...conditions));
  }
  
  // Add ordering (newest first)
  baseQuery = baseQuery.orderBy(desc(questions.createdAt));
  
  // Apply pagination
  const allQuestions = await baseQuery;
  const paginatedQuestions = allQuestions.slice(query.offset, query.offset + query.limit);
  
  res.json({
    success: true,
    data: {
      questions: paginatedQuestions,
      total: allQuestions.length,
      hasMore: query.offset + query.limit < allQuestions.length,
    },
  });
}));

// Get single question with answers
router.get('/:id', optionalAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  // Get question
  const question = await db
    .select()
    .from(questions)
    .where(eq(questions.id, id))
    .limit(1);
  
  if (!question.length) {
    return res.status(404).json({
      success: false,
      error: 'Question not found',
    });
  }
  
  // Check if question is published (unless admin)
  if (!hasAnyRole(req.user, ['admin', 'super-admin'])) {
    if (!question[0].isPublished) {
      return res.status(404).json({
        success: false,
        error: 'Question not found',
      });
    }
  }
  
  // Get answers for this question
  const questionAnswers = await db
    .select()
    .from(answers)
    .where(and(eq(answers.questionId, id), eq(answers.isPublished, true)))
    .orderBy(desc(answers.answeredAt));
  
  // Increment view count
  await db
    .update(questions)
    .set({ viewCount: (question[0].viewCount ?? 0) + 1 })
    .where(eq(questions.id, id));
  
  res.json({
    success: true,
    data: {
      ...question[0],
      answers: questionAnswers,
    },
  });
}));

// Submit new question (anonymous)
router.post('/', optionalAuth, asyncHandler(async (req, res) => {
  const validatedData = CreateQuestionSchema.parse(req.body);
  
  // Check for urgent keywords
  const urgentKeywords = ['suicide', 'kill myself', 'end my life', 'self-harm', 'hurt myself'];
  const isUrgent = urgentKeywords.some(keyword => 
    validatedData.title.toLowerCase().includes(keyword) || 
    validatedData.description.toLowerCase().includes(keyword)
  );
  
  const newQuestion = await db
    .insert(questions)
    .values({
      ...validatedData,
      deviceId: req.user?.deviceId || validatedData.deviceId,
      flaggedForUrgent: isUrgent,
      isPublished: false, // Requires review
    })
    .returning();
  
  res.status(201).json({
    success: true,
    data: {
      ...newQuestion[0],
      message: isUrgent 
        ? 'Your question has been flagged for urgent review. Please consider contacting emergency services.'
        : 'Your question has been submitted for review.',
    },
  });
}));

// Submit answer to question (admin only)
router.post('/:id/answers', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const validatedData = CreateAnswerSchema.parse({ ...req.body, questionId: id });
  
  // Check if question exists
  const question = await db
    .select()
    .from(questions)
    .where(eq(questions.id, id))
    .limit(1);
  
  if (!question.length) {
    return res.status(404).json({
      success: false,
      error: 'Question not found',
    });
  }
  
  const newAnswer = await db
    .insert(answers)
    .values({
      ...validatedData,
      isPublished: true, // Admin answers are published immediately
    })
    .returning();
  
  // Update question as answered
  await db
    .update(questions)
    .set({ 
      isAnswered: true,
      isPublished: true, // Publish the question when answered
    })
    .where(eq(questions.id, id));
  
  res.status(201).json({
    success: true,
    data: newAnswer[0],
  });
}));

// Mark answer as helpful
router.post('/answers/:answerId/helpful', optionalAuth, asyncHandler(async (req, res) => {
  const { answerId } = req.params;
  
  const answer = await db
    .select()
    .from(answers)
    .where(eq(answers.id, answerId))
    .limit(1);
  
  if (!answer.length) {
    return res.status(404).json({
      success: false,
      error: 'Answer not found',
    });
  }
  
  const updatedAnswer = await db
    .update(answers)
    .set({ helpfulCount: (answer[0].helpfulCount ?? 0) + 1 })
    .where(eq(answers.id, answerId))
    .returning();
  
  // Also update question helpful count
  const parentQuestion = await db
    .select()
    .from(questions)
    .where(eq(questions.id, answer[0].questionId))
    .limit(1);
  await db
    .update(questions)
    .set({ helpfulCount: (parentQuestion[0]?.helpfulCount ?? 0) + 1 })
    .where(eq(questions.id, answer[0].questionId));
  
  res.json({
    success: true,
    data: updatedAnswer[0],
  });
}));

// Report question or answer
router.post('/:id/report', optionalAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { reason, description } = req.body;
  
  if (!reason || typeof reason !== 'string') {
    return res.status(400).json({
      success: false,
      error: 'Reason is required',
    });
  }
  
  // Check if question exists
  const question = await db
    .select()
    .from(questions)
    .where(eq(questions.id, id))
    .limit(1);
  
  if (!question.length) {
    return res.status(404).json({
      success: false,
      error: 'Question not found',
    });
  }
  
  // Create report
  await db
    .insert(reports)
    .values({
      type: 'question',
      resourceId: id,
      reason,
      description,
      reporterDeviceId: req.user?.deviceId,
    });
  
  res.json({
    success: true,
    message: 'Report submitted for review',
  });
}));

// Get categories
router.get('/categories/list', asyncHandler(async (req, res) => {
  const categories = [
    { id: 'mental-health', name: 'Mental Health', description: 'Questions about mental wellness and support' },
    { id: 'srhr', name: 'SRHR', description: 'Sexual and Reproductive Health Rights questions' },
    { id: 'emergency', name: 'Emergency', description: 'Urgent crisis and emergency questions' },
    { id: 'relationships', name: 'Relationships', description: 'Questions about relationships and social issues' },
    { id: 'general', name: 'General', description: 'General wellness and health questions' },
  ];
  
  res.json({
    success: true,
    data: categories,
  });
}));

export default router;
