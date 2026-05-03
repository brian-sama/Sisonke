"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.retrieveApprovedContext = retrieveApprovedContext;
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const stopWords = new Set([
    'about',
    'after',
    'again',
    'what',
    'when',
    'where',
    'which',
    'with',
    'from',
    'that',
    'this',
    'have',
    'need',
    'help',
    'feel',
    'like',
    'your',
    'you',
    'and',
    'the',
    'for',
    'are',
]);
function tokensFor(text) {
    return text
        .toLowerCase()
        .replace(/[^a-z0-9\s-]/g, ' ')
        .split(/\s+/)
        .filter((token) => token.length > 2 && !stopWords.has(token));
}
function scoreContent(queryTokens, item) {
    const haystack = `${item.title} ${item.category} ${item.body}`.toLowerCase();
    return queryTokens.reduce((score, token) => score + (haystack.includes(token) ? 1 : 0), 0);
}
async function retrieveApprovedContext(query, limit = 4) {
    const queryTokens = tokensFor(query);
    if (!queryTokens.length)
        return '';
    const [resourceRows, cmsRows] = await Promise.all([
        db_1.db
            .select()
            .from(schema_1.resources)
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.resources.status, 'published'), (0, drizzle_orm_1.eq)(schema_1.resources.isPublished, true), (0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt)))
            .limit(100),
        db_1.db
            .select()
            .from(schema_1.cmsContent)
            .where((0, drizzle_orm_1.eq)(schema_1.cmsContent.status, 'published'))
            .limit(100),
    ]);
    const candidates = [
        ...resourceRows.map((item) => ({
            title: item.title,
            category: item.category,
            body: item.content || item.description,
            source: 'resource',
        })),
        ...cmsRows.map((item) => ({
            title: item.title,
            category: item.category,
            body: item.body,
            source: 'cms',
        })),
    ];
    return candidates
        .map((item) => ({ item, score: scoreContent(queryTokens, item) }))
        .filter((entry) => entry.score > 0)
        .sort((a, b) => b.score - a.score)
        .slice(0, limit)
        .map(({ item }) => {
        const body = item.body.length > 700 ? `${item.body.slice(0, 700)}...` : item.body;
        return `[${item.source}] ${item.title} (${item.category})\n${body}`;
    })
        .join('\n\n');
}
//# sourceMappingURL=resourceRetrievalService.js.map