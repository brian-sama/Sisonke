"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.QAService = void 0;
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
class QAService {
    static async getQuestions(category, isAdmin = false) {
        let baseQuery = db_1.db.select().from(schema_1.questions);
        const conditions = [];
        if (category) {
            conditions.push((0, drizzle_orm_1.eq)(schema_1.questions.category, category));
        }
        if (!isAdmin) {
            conditions.push((0, drizzle_orm_1.eq)(schema_1.questions.isPublished, true));
        }
        if (conditions.length > 0) {
            baseQuery = baseQuery.where((0, drizzle_orm_1.and)(...conditions));
        }
        return await baseQuery.orderBy((0, drizzle_orm_1.desc)(schema_1.questions.submittedAt));
    }
    static async getQuestionWithAnswers(id, isAdmin = false) {
        const question = await db_1.db.select().from(schema_1.questions).where((0, drizzle_orm_1.eq)(schema_1.questions.id, id)).limit(1);
        if (!question.length)
            return null;
        if (!isAdmin && !question[0].isPublished)
            return null;
        const questionAnswers = await db_1.db.select().from(schema_1.answers)
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.answers.questionId, id), isAdmin ? undefined : (0, drizzle_orm_1.eq)(schema_1.answers.isPublished, true)));
        return {
            ...question[0],
            answers: questionAnswers
        };
    }
    static async submitQuestion(data) {
        return await db_1.db.insert(schema_1.questions).values({
            ...data,
            isPublished: false, // Must be moderated
            isAnswered: false,
        }).returning();
    }
}
exports.QAService = QAService;
//# sourceMappingURL=qaService.js.map