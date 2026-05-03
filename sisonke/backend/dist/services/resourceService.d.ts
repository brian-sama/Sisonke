export declare class ResourceService {
    static getAll(query: any, isAdmin?: boolean): Promise<{
        resources: {
            id: string;
            createdAt: Date | null;
            updatedAt: Date | null;
            title: string;
            description: string;
            content: string | null;
            category: "emergency" | "srhr" | "mental-health" | "substance-use" | "wellness" | "guide";
            tags: string[] | null;
            authorId: string | null;
            imageUrl: string | null;
            readingTimeMinutes: number | null;
            language: string | null;
            status: "draft" | "review" | "published" | "archived";
            isPublished: boolean | null;
            isOfflineAvailable: boolean | null;
            viewCount: number | null;
            downloadCount: number | null;
            publishedAt: Date | null;
            deletedAt: Date | null;
        }[];
        total: number;
        hasMore: boolean;
    }>;
    static getById(id: string, isAdmin?: boolean): Promise<{
        id: string;
        createdAt: Date | null;
        updatedAt: Date | null;
        title: string;
        description: string;
        content: string | null;
        category: "emergency" | "srhr" | "mental-health" | "substance-use" | "wellness" | "guide";
        tags: string[] | null;
        authorId: string | null;
        imageUrl: string | null;
        readingTimeMinutes: number | null;
        language: string | null;
        status: "draft" | "review" | "published" | "archived";
        isPublished: boolean | null;
        isOfflineAvailable: boolean | null;
        viewCount: number | null;
        downloadCount: number | null;
        publishedAt: Date | null;
        deletedAt: Date | null;
    } | null>;
    static incrementViews(id: string): Promise<void>;
}
//# sourceMappingURL=resourceService.d.ts.map