"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RagService = void 0;
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const zimbabweRagKnowledge_1 = require("../data/zimbabweRagKnowledge");
/**
 * Simple keyword-based relevance scoring for RAG.
 * In a future version, this can be replaced by vector embeddings (pgvector).
 */
class RagService {
    static stopWords = new Set([
        'i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 'your', 'yours',
        'he', 'him', 'his', 'she', 'her', 'hers', 'it', 'its', 'they', 'them', 'their',
        'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'am', 'is', 'are',
        'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does',
        'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until',
        'while', 'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into',
        'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down',
        'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once'
    ]);
    static async getGroundingContext(query, limit = 3) {
        const tokens = this.tokenize(query);
        if (tokens.length === 0)
            return '';
        // Fetch potential DB candidates, but keep the graph useful during local
        // development when Postgres content has not been migrated or seeded yet.
        const dbLookup = Promise.all([
            db_1.db.select().from(schema_1.resources).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.resources.status, 'published'), (0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt))).limit(50),
            db_1.db.select().from(schema_1.cmsContent).where((0, drizzle_orm_1.eq)(schema_1.cmsContent.status, 'published')).limit(50)
        ]);
        const timeoutMs = Number(process.env.RAG_DB_TIMEOUT_MS || 1500);
        const timeout = new Promise((_, reject) => setTimeout(() => reject(new Error('RAG DB lookup timed out')), timeoutMs));
        const [resRows, cmsRows] = await Promise.race([dbLookup, timeout]).catch((error) => {
            console.warn('RAG DB lookup failed; using bundled approved cards only.', error);
            return [[], []];
        });
        const candidates = [
            ...zimbabweRagKnowledge_1.allZimbabweRagCards.map(card => ({
                id: card.id,
                title: card.title,
                content: card.content,
                category: card.category,
                type: 'cms'
            })),
            ...resRows.map(r => ({
                id: r.id,
                title: r.title,
                content: r.content || r.description || '',
                category: r.category || 'General',
                type: 'resource'
            })),
            ...cmsRows.map(c => ({
                id: c.id,
                title: c.title,
                content: c.body,
                category: c.category,
                type: 'cms'
            }))
        ];
        // Score and rank
        const ranked = candidates
            .map(c => ({ content: c, score: this.calculateScore(tokens, c) }))
            .filter(item => item.score > 0)
            .sort((a, b) => b.score - a.score)
            .slice(0, limit);
        if (ranked.length === 0)
            return '';
        // Format context for LLM prompt
        return ranked.map(item => {
            const c = item.content;
            return `SOURCE [${c.type.toUpperCase()}]: ${c.title}\nCATEGORY: ${c.category}\nCONTENT: ${c.content.slice(0, 800)}`;
        }).join('\n---\n');
    }
    static tokenize(text) {
        return text.toLowerCase()
            .replace(/[^\p{L}\p{N}\s]/gu, '')
            .split(/\s+/)
            .filter(t => t.length > 2 && !this.stopWords.has(t));
    }
    static calculateScore(queryTokens, source) {
        let score = 0;
        const searchArea = `${source.title} ${source.category} ${source.content}`.toLowerCase();
        queryTokens.forEach(token => {
            if (searchArea.includes(token)) {
                score += 1;
                // Boost score if token is in title
                if (source.title.toLowerCase().includes(token))
                    score += 2;
            }
        });
        return score;
    }
}
exports.RagService = RagService;
//# sourceMappingURL=ragService.js.map