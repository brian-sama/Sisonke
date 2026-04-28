import { db } from '../db';
import { resources } from '../db/schema';
import { eq, and, ilike, desc } from 'drizzle-orm';
import { ResourceQuerySchema } from '../types';

export class ResourceService {
  static async getAll(query: any, isAdmin: boolean = false) {
    const validatedQuery = ResourceQuerySchema.parse(query);

    let baseQuery = db.select().from(resources);

    const conditions = [];

    if (validatedQuery.category) {
      conditions.push(eq(resources.category, validatedQuery.category));
    }

    if (validatedQuery.search) {
      conditions.push(ilike(resources.title, `%${validatedQuery.search}%`));
    }

    if (validatedQuery.language) {
      conditions.push(eq(resources.language, validatedQuery.language));
    }

    if (!isAdmin) {
      conditions.push(eq(resources.isPublished, true));
    }

    if (conditions.length > 0) {
      baseQuery = baseQuery.where(and(...conditions)) as any;
    }

    const results = await baseQuery.orderBy(desc(resources.createdAt));

    const paginated = results.slice(validatedQuery.offset, validatedQuery.offset + validatedQuery.limit);

    return {
      resources: paginated,
      total: results.length,
      hasMore: validatedQuery.offset + validatedQuery.limit < results.length,
    };
  }

  static async getById(id: string, isAdmin: boolean = false) {
    const resource = await db.select().from(resources).where(eq(resources.id, id)).limit(1);

    if (!resource.length) return null;
    if (!isAdmin && !resource[0].isPublished) return null;

    return resource[0];
  }

  static async incrementViews(id: string) {
    const resource = await this.getById(id, true);
    if (!resource) return;

    await db.update(resources)
      .set({ viewCount: (resource.viewCount || 0) + 1 })
      .where(eq(resources.id, id));
  }
}
