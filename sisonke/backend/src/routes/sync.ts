import { Router } from 'express';
import { and, eq, gt, isNull, or } from 'drizzle-orm';
import { db } from '../db';
import { emergencyContacts, resources, questions, answers } from '../db/schema';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

function parseSince(value: unknown) {
  if (typeof value !== 'string' || value.trim() === '') return null;
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

router.get('/public', asyncHandler(async (req, res) => {
  const since = parseSince(req.query.since);

  const changedResourceConditions = [
    eq(resources.status, 'published'),
    isNull(resources.deletedAt),
  ];
  const changedContactConditions = [
    eq(emergencyContacts.status, 'published'),
    eq(emergencyContacts.isActive, true),
    isNull(emergencyContacts.deletedAt),
  ];
  const changedQuestionConditions = [
    eq(questions.status, 'published'),
    eq(questions.isPublished, true),
    isNull(questions.deletedAt),
  ];

  if (since) {
    changedResourceConditions.push(or(gt(resources.updatedAt, since), gt(resources.publishedAt, since)) as any);
    changedContactConditions.push(or(gt(emergencyContacts.updatedAt, since), gt(emergencyContacts.publishedAt, since)) as any);
    changedQuestionConditions.push(or(gt(questions.updatedAt, since), gt(questions.publishedAt, since)) as any);
  }

  const [publishedResources, contacts, publishedQuestions] = await Promise.all([
    db.select().from(resources).where(and(...changedResourceConditions)),
    db.select().from(emergencyContacts).where(and(...changedContactConditions)),
    db.select().from(questions).where(and(...changedQuestionConditions)),
  ]);

  const questionIds = publishedQuestions.map((question) => question.id);
  const publishedAnswers = questionIds.length === 0
    ? []
    : await db.select().from(answers).where(eq(answers.isPublished, true));

  res.json({
    success: true,
    data: {
      serverTime: new Date().toISOString(),
      resources: publishedResources,
      emergencyContacts: contacts,
      questions: publishedQuestions.map((question) => ({
        ...question,
        answers: publishedAnswers.filter((answer) => answer.questionId === question.id),
      })),
    },
  });
}));

export default router;
