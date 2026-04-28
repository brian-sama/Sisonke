"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const types_1 = require("../types");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const router = (0, express_1.Router)();
// Get all questions with filtering
router.get('/', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const query = types_1.QuestionQuerySchema.parse(req.query);
    let baseQuery = db_1.db.select().from(schema_1.questions).$dynamic();
    // Add filters
    const conditions = [];
    if (query.category) {
        conditions.push((0, drizzle_orm_1.eq)(schema_1.questions.category, query.category));
    }
    if (query.answered !== undefined) {
        conditions.push((0, drizzle_orm_1.eq)(schema_1.questions.isAnswered, query.answered));
    }
    // Only show published questions to non-admin users
    if (!req.user || req.user.role !== 'admin') {
        conditions.push((0, drizzle_orm_1.eq)(schema_1.questions.status, 'published'));
        conditions.push((0, drizzle_orm_1.eq)(schema_1.questions.isPublished, true));
    }
    // Apply conditions
    if (conditions.length > 0) {
        baseQuery = baseQuery.where((0, drizzle_orm_1.and)(...conditions));
    }
    // Add ordering (newest first)
    baseQuery = baseQuery.orderBy((0, drizzle_orm_1.desc)(schema_1.questions.createdAt));
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
router.get('/:id', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { id } = req.params;
    // Get question
    const question = await db_1.db
        .select()
        .from(schema_1.questions)
        .where((0, drizzle_orm_1.eq)(schema_1.questions.id, id))
        .limit(1);
    if (!question.length) {
        return res.status(404).json({
            success: false,
            error: 'Question not found',
        });
    }
    // Check if question is published (unless admin)
    if (!req.user || req.user.role !== 'admin') {
        if (!question[0].isPublished) {
            return res.status(404).json({
                success: false,
                error: 'Question not found',
            });
        }
    }
    // Get answers for this question
    const questionAnswers = await db_1.db
        .select()
        .from(schema_1.answers)
        .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.answers.questionId, id), (0, drizzle_orm_1.eq)(schema_1.answers.isPublished, true)))
        .orderBy((0, drizzle_orm_1.desc)(schema_1.answers.answeredAt));
    // Increment view count
    await db_1.db
        .update(schema_1.questions)
        .set({ viewCount: (question[0].viewCount ?? 0) + 1 })
        .where((0, drizzle_orm_1.eq)(schema_1.questions.id, id));
    res.json({
        success: true,
        data: {
            ...question[0],
            answers: questionAnswers,
        },
    });
}));
// Submit new question (anonymous)
router.post('/', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const validatedData = types_1.CreateQuestionSchema.parse(req.body);
    // Check for urgent keywords
    const urgentKeywords = ['suicide', 'kill myself', 'end my life', 'self-harm', 'hurt myself'];
    const isUrgent = urgentKeywords.some(keyword => validatedData.title.toLowerCase().includes(keyword) ||
        validatedData.description.toLowerCase().includes(keyword));
    const newQuestion = await db_1.db
        .insert(schema_1.questions)
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
router.post('/:id/answers', auth_1.authMiddleware, auth_1.adminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { id } = req.params;
    const validatedData = types_1.CreateAnswerSchema.parse({ ...req.body, questionId: id });
    // Check if question exists
    const question = await db_1.db
        .select()
        .from(schema_1.questions)
        .where((0, drizzle_orm_1.eq)(schema_1.questions.id, id))
        .limit(1);
    if (!question.length) {
        return res.status(404).json({
            success: false,
            error: 'Question not found',
        });
    }
    const newAnswer = await db_1.db
        .insert(schema_1.answers)
        .values({
        ...validatedData,
        isPublished: true, // Admin answers are published immediately
    })
        .returning();
    // Update question as answered
    await db_1.db
        .update(schema_1.questions)
        .set({
        isAnswered: true,
        isPublished: true, // Publish the question when answered
    })
        .where((0, drizzle_orm_1.eq)(schema_1.questions.id, id));
    res.status(201).json({
        success: true,
        data: newAnswer[0],
    });
}));
// Mark answer as helpful
router.post('/answers/:answerId/helpful', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { answerId } = req.params;
    const answer = await db_1.db
        .select()
        .from(schema_1.answers)
        .where((0, drizzle_orm_1.eq)(schema_1.answers.id, answerId))
        .limit(1);
    if (!answer.length) {
        return res.status(404).json({
            success: false,
            error: 'Answer not found',
        });
    }
    const updatedAnswer = await db_1.db
        .update(schema_1.answers)
        .set({ helpfulCount: (answer[0].helpfulCount ?? 0) + 1 })
        .where((0, drizzle_orm_1.eq)(schema_1.answers.id, answerId))
        .returning();
    // Also update question helpful count
    const parentQuestion = await db_1.db
        .select()
        .from(schema_1.questions)
        .where((0, drizzle_orm_1.eq)(schema_1.questions.id, answer[0].questionId))
        .limit(1);
    await db_1.db
        .update(schema_1.questions)
        .set({ helpfulCount: (parentQuestion[0]?.helpfulCount ?? 0) + 1 })
        .where((0, drizzle_orm_1.eq)(schema_1.questions.id, answer[0].questionId));
    res.json({
        success: true,
        data: updatedAnswer[0],
    });
}));
// Report question or answer
router.post('/:id/report', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { id } = req.params;
    const { reason, description } = req.body;
    if (!reason || typeof reason !== 'string') {
        return res.status(400).json({
            success: false,
            error: 'Reason is required',
        });
    }
    // Check if question exists
    const question = await db_1.db
        .select()
        .from(schema_1.questions)
        .where((0, drizzle_orm_1.eq)(schema_1.questions.id, id))
        .limit(1);
    if (!question.length) {
        return res.status(404).json({
            success: false,
            error: 'Question not found',
        });
    }
    // Create report
    await db_1.db
        .insert(schema_1.reports)
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
router.get('/categories/list', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
exports.default = router;
//# sourceMappingURL=questions.js.map