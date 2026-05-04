/**
 * Simple keyword-based relevance scoring for RAG.
 * In a future version, this can be replaced by vector embeddings (pgvector).
 */
export declare class RagService {
    private static stopWords;
    static getGroundingContext(query: string, limit?: number): Promise<string>;
    private static tokenize;
    private static calculateScore;
}
//# sourceMappingURL=ragService.d.ts.map