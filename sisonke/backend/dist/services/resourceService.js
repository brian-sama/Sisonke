"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ResourceService = void 0;
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const types_1 = require("../types");
class ResourceService {
    static async getAll(query, isAdmin = false) {
        const validatedQuery = types_1.ResourceQuerySchema.parse(query);
        let baseQuery = db_1.db.select().from(schema_1.resources);
        const conditions = [];
        if (validatedQuery.category) {
            conditions.push((0, drizzle_orm_1.eq)(schema_1.resources.category, validatedQuery.category));
        }
        if (validatedQuery.search) {
            conditions.push((0, drizzle_orm_1.ilike)(schema_1.resources.title, `%${validatedQuery.search}%`));
        }
        if (validatedQuery.language) {
            conditions.push((0, drizzle_orm_1.eq)(schema_1.resources.language, validatedQuery.language));
        }
        if (!isAdmin) {
            conditions.push((0, drizzle_orm_1.eq)(schema_1.resources.isPublished, true));
        }
        if (conditions.length > 0) {
            baseQuery = baseQuery.where((0, drizzle_orm_1.and)(...conditions));
        }
        const results = await baseQuery.orderBy((0, drizzle_orm_1.desc)(schema_1.resources.createdAt));
        const paginated = results.slice(validatedQuery.offset, validatedQuery.offset + validatedQuery.limit);
        return {
            resources: paginated,
            total: results.length,
            hasMore: validatedQuery.offset + validatedQuery.limit < results.length,
        };
    }
    static async getById(id, isAdmin = false) {
        const resource = await db_1.db.select().from(schema_1.resources).where((0, drizzle_orm_1.eq)(schema_1.resources.id, id)).limit(1);
        if (!resource.length)
            return null;
        if (!isAdmin && !resource[0].isPublished)
            return null;
        return resource[0];
    }
    static async incrementViews(id) {
        const resource = await this.getById(id, true);
        if (!resource)
            return;
        await db_1.db.update(schema_1.resources)
            .set({ viewCount: (resource.viewCount || 0) + 1 })
            .where((0, drizzle_orm_1.eq)(schema_1.resources.id, id));
    }
}
exports.ResourceService = ResourceService;
//# sourceMappingURL=resourceService.js.map