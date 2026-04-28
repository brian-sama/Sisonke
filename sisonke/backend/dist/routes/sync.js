"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const errorHandler_1 = require("../middleware/errorHandler");
const router = (0, express_1.Router)();
function parseSince(value) {
    if (typeof value !== 'string' || value.trim() === '')
        return null;
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
}
router.get('/public', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const since = parseSince(req.query.since);
    const changedResourceConditions = [
        (0, drizzle_orm_1.eq)(schema_1.resources.status, 'published'),
        (0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt),
    ];
    const changedContactConditions = [
        (0, drizzle_orm_1.eq)(schema_1.emergencyContacts.status, 'published'),
        (0, drizzle_orm_1.eq)(schema_1.emergencyContacts.isActive, true),
        (0, drizzle_orm_1.isNull)(schema_1.emergencyContacts.deletedAt),
    ];
    const changedQuestionConditions = [
        (0, drizzle_orm_1.eq)(schema_1.questions.status, 'published'),
        (0, drizzle_orm_1.eq)(schema_1.questions.isPublished, true),
        (0, drizzle_orm_1.isNull)(schema_1.questions.deletedAt),
    ];
    if (since) {
        changedResourceConditions.push((0, drizzle_orm_1.or)((0, drizzle_orm_1.gt)(schema_1.resources.updatedAt, since), (0, drizzle_orm_1.gt)(schema_1.resources.publishedAt, since)));
        changedContactConditions.push((0, drizzle_orm_1.or)((0, drizzle_orm_1.gt)(schema_1.emergencyContacts.updatedAt, since), (0, drizzle_orm_1.gt)(schema_1.emergencyContacts.publishedAt, since)));
        changedQuestionConditions.push((0, drizzle_orm_1.or)((0, drizzle_orm_1.gt)(schema_1.questions.updatedAt, since), (0, drizzle_orm_1.gt)(schema_1.questions.publishedAt, since)));
    }
    const [publishedResources, contacts, publishedQuestions] = await Promise.all([
        db_1.db.select().from(schema_1.resources).where((0, drizzle_orm_1.and)(...changedResourceConditions)),
        db_1.db.select().from(schema_1.emergencyContacts).where((0, drizzle_orm_1.and)(...changedContactConditions)),
        db_1.db.select().from(schema_1.questions).where((0, drizzle_orm_1.and)(...changedQuestionConditions)),
    ]);
    const questionIds = publishedQuestions.map((question) => question.id);
    const publishedAnswers = questionIds.length === 0
        ? []
        : await db_1.db.select().from(schema_1.answers).where((0, drizzle_orm_1.eq)(schema_1.answers.isPublished, true));
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
exports.default = router;
//# sourceMappingURL=sync.js.map