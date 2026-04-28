import { db } from '../db';
import { questions, answers } from '../db/schema';
import { eq, and, desc } from 'drizzle-orm';

export class QAService {
  static async getQuestions(category?: any, isAdmin: boolean = false) {
    let baseQuery = db.select().from(questions);

    const conditions = [];
    if (category) {
      conditions.push(eq(questions.category, category));
    }

    if (!isAdmin) {
      conditions.push(eq(questions.isPublished, true));
    }

    if (conditions.length > 0) {
      baseQuery = baseQuery.where(and(...conditions)) as any;
    }

    return await baseQuery.orderBy(desc(questions.submittedAt));
  }

  static async getQuestionWithAnswers(id: string, isAdmin: boolean = false) {
    const question = await db.select().from(questions).where(eq(questions.id, id)).limit(1);

    if (!question.length) return null;
    if (!isAdmin && !question[0].isPublished) return null;

    const questionAnswers = await db.select().from(answers)
      .where(and(
        eq(answers.questionId, id),
        isAdmin ? undefined : eq(answers.isPublished, true)
      ) as any);

    return {
      ...question[0],
      answers: questionAnswers
    };
  }

  static async submitQuestion(data: { title: string, description: string, category: any, deviceId?: string }) {
    return await db.insert(questions).values({
      ...data,
      isPublished: false, // Must be moderated
      isAnswered: false,
    }).returning();
  }
}
