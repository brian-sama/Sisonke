export declare class QAService {
    static getQuestions(category?: any, isAdmin?: boolean): Promise<{
        id: string;
        deviceId: string | null;
        createdAt: Date | null;
        updatedAt: Date | null;
        title: string;
        description: string;
        category: "mental-health" | "srhr" | "emergency" | "relationships" | "general";
        status: "draft" | "review" | "published" | "archived";
        isPublished: boolean | null;
        viewCount: number | null;
        publishedAt: Date | null;
        deletedAt: Date | null;
        submittedAt: Date | null;
        isAnswered: boolean | null;
        flaggedForUrgent: boolean | null;
        helpfulCount: number | null;
    }[]>;
    static getQuestionWithAnswers(id: string, isAdmin?: boolean): Promise<{
        answers: {
            id: string;
            createdAt: Date | null;
            content: string;
            isPublished: boolean | null;
            helpfulCount: number | null;
            questionId: string;
            expertName: string | null;
            expertRole: string | null;
            answeredAt: Date | null;
        }[];
        id: string;
        deviceId: string | null;
        createdAt: Date | null;
        updatedAt: Date | null;
        title: string;
        description: string;
        category: "mental-health" | "srhr" | "emergency" | "relationships" | "general";
        status: "draft" | "review" | "published" | "archived";
        isPublished: boolean | null;
        viewCount: number | null;
        publishedAt: Date | null;
        deletedAt: Date | null;
        submittedAt: Date | null;
        isAnswered: boolean | null;
        flaggedForUrgent: boolean | null;
        helpfulCount: number | null;
    } | null>;
    static submitQuestion(data: {
        title: string;
        description: string;
        category: any;
        deviceId?: string;
    }): Promise<{
        id: string;
        deviceId: string | null;
        createdAt: Date | null;
        updatedAt: Date | null;
        title: string;
        description: string;
        category: "mental-health" | "srhr" | "emergency" | "relationships" | "general";
        status: "draft" | "review" | "published" | "archived";
        isPublished: boolean | null;
        viewCount: number | null;
        publishedAt: Date | null;
        deletedAt: Date | null;
        submittedAt: Date | null;
        isAnswered: boolean | null;
        flaggedForUrgent: boolean | null;
        helpfulCount: number | null;
    }[]>;
}
//# sourceMappingURL=qaService.d.ts.map