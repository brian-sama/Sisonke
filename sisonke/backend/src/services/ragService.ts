import { and, eq, isNull } from 'drizzle-orm';
import { db } from '../db';
import { resources, cmsContent } from '../db/schema';
import { allZimbabweRagCards } from '../data/zimbabweRagKnowledge';

/**
 * RAG Service for Sisonke
 * This service handles the "Grounding" of AI responses by retrieving 
 * relevant, approved mental health and SRHR content before the LLM generates a reply.
 */

type GroundingSource = {
  id: string;
  title: string;
  content: string;
  category: string;
  type: 'resource' | 'cms';
};

/**
 * Simple keyword-based relevance scoring for RAG.
 * In a future version, this can be replaced by vector embeddings (pgvector).
 */
export class RagService {
  private static stopWords = new Set([
    'i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 'your', 'yours', 
    'he', 'him', 'his', 'she', 'her', 'hers', 'it', 'its', 'they', 'them', 'their', 
    'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'am', 'is', 'are', 
    'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does', 
    'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 
    'while', 'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 
    'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down', 
    'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once'
  ]);

  static async getGroundingContext(query: string, limit = 3): Promise<string> {
    const tokens = this.tokenize(query);
    if (tokens.length === 0) return '';

    // Fetch potential candidates from DB
    const [resRows, cmsRows] = await Promise.all([
      db.select().from(resources).where(and(eq(resources.status, 'published'), isNull(resources.deletedAt))).limit(50),
      db.select().from(cmsContent).where(eq(cmsContent.status, 'published')).limit(50)
    ]);

    const candidates: GroundingSource[] = [
      ...allZimbabweRagCards.map(card => ({
        id: card.id,
        title: card.title,
        content: card.content,
        category: card.category,
        type: 'cms' as const
      })),
      ...resRows.map(r => ({
        id: r.id,
        title: r.title,
        content: r.content || r.description || '',
        category: r.category || 'General',
        type: 'resource' as const
      })),
      ...cmsRows.map(c => ({
        id: c.id,
        title: c.title,
        content: c.body,
        category: c.category,
        type: 'cms' as const
      }))
    ];

    // Score and rank
    const ranked = candidates
      .map(c => ({ content: c, score: this.calculateScore(tokens, c) }))
      .filter(item => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, limit);

    if (ranked.length === 0) return '';

    // Format context for LLM prompt
    return ranked.map(item => {
      const c = item.content;
      return `SOURCE [${c.type.toUpperCase()}]: ${c.title}\nCATEGORY: ${c.category}\nCONTENT: ${c.content.slice(0, 800)}`;
    }).join('\n---\n');
  }

  private static tokenize(text: string): string[] {
    return text.toLowerCase()
      .replace(/[^\p{L}\p{N}\s]/gu, '')
      .split(/\s+/)
      .filter(t => t.length > 2 && !this.stopWords.has(t));
  }

  private static calculateScore(queryTokens: string[], source: GroundingSource): number {
    let score = 0;
    const searchArea = `${source.title} ${source.category} ${source.content}`.toLowerCase();
    
    queryTokens.forEach(token => {
      if (searchArea.includes(token)) {
        score += 1;
        // Boost score if token is in title
        if (source.title.toLowerCase().includes(token)) score += 2;
      }
    });
    
    return score;
  }
}
