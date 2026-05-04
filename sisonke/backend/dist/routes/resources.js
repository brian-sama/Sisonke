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
// Get all resources with filtering and search
router.get('/', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const query = types_1.ResourceQuerySchema.parse(req.query);
    let baseQuery = db_1.db.select().from(schema_1.resources).$dynamic();
    // Add filters
    const conditions = [];
    if (query.category) {
        conditions.push((0, drizzle_orm_1.eq)(schema_1.resources.category, query.category));
    }
    if (query.search) {
        conditions.push((0, drizzle_orm_1.ilike)(schema_1.resources.title, `%${query.search}%`));
    }
    if (query.language) {
        conditions.push((0, drizzle_orm_1.eq)(schema_1.resources.language, query.language));
    }
    // Only show published resources to non-admin users
    if (!(0, auth_1.hasAnyRole)(req.user, ['admin', 'super-admin'])) {
        conditions.push((0, drizzle_orm_1.eq)(schema_1.resources.status, 'published'));
        conditions.push((0, drizzle_orm_1.eq)(schema_1.resources.isPublished, true));
    }
    // Apply conditions
    if (conditions.length > 0) {
        baseQuery = baseQuery.where((0, drizzle_orm_1.and)(...conditions));
    }
    // Add ordering (newest first)
    baseQuery = baseQuery.orderBy((0, drizzle_orm_1.desc)(schema_1.resources.createdAt));
    // Apply pagination
    const allResources = await baseQuery;
    const paginatedResources = allResources.slice(query.offset, query.offset + query.limit);
    res.json({
        success: true,
        data: {
            resources: paginatedResources,
            total: allResources.length,
            hasMore: query.offset + query.limit < allResources.length,
        },
    });
}));
// Get single resource
router.get('/:id', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { id } = req.params;
    const resource = await db_1.db
        .select()
        .from(schema_1.resources)
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, id))
        .limit(1);
    if (!resource.length) {
        return res.status(404).json({
            success: false,
            error: 'Resource not found',
        });
    }
    // Check if resource is published (unless admin)
    if (!(0, auth_1.hasAnyRole)(req.user, ['admin', 'super-admin'])) {
        if (!resource[0].isPublished) {
            return res.status(404).json({
                success: false,
                error: 'Resource not found',
            });
        }
    }
    // Increment view count
    await db_1.db
        .update(schema_1.resources)
        .set({ viewCount: (resource[0].viewCount ?? 0) + 1 })
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, id));
    res.json({
        success: true,
        data: resource[0],
    });
}));
// Create new resource (admin only)
router.post('/', auth_1.authMiddleware, auth_1.adminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const validatedData = types_1.CreateResourceSchema.parse(req.body);
    const newResource = await db_1.db
        .insert(schema_1.resources)
        .values({
        ...validatedData,
        authorId: req.user.id,
    })
        .returning();
    res.status(201).json({
        success: true,
        data: newResource[0],
    });
}));
// Update resource (admin only)
router.put('/:id', auth_1.authMiddleware, auth_1.adminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { id } = req.params;
    const validatedData = types_1.UpdateResourceSchema.parse(req.body);
    // Check if resource exists
    const existingResource = await db_1.db
        .select()
        .from(schema_1.resources)
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, id))
        .limit(1);
    if (!existingResource.length) {
        return res.status(404).json({
            success: false,
            error: 'Resource not found',
        });
    }
    const updatedResource = await db_1.db
        .update(schema_1.resources)
        .set({
        ...validatedData,
        updatedAt: new Date(),
    })
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, id))
        .returning();
    res.json({
        success: true,
        data: updatedResource[0],
    });
}));
// Delete resource (admin only)
router.delete('/:id', auth_1.authMiddleware, auth_1.adminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { id } = req.params;
    // Check if resource exists
    const existingResource = await db_1.db
        .select()
        .from(schema_1.resources)
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, id))
        .limit(1);
    if (!existingResource.length) {
        return res.status(404).json({
            success: false,
            error: 'Resource not found',
        });
    }
    await db_1.db.delete(schema_1.resources).where((0, drizzle_orm_1.eq)(schema_1.resources.id, id));
    res.json({
        success: true,
        message: 'Resource deleted successfully',
    });
}));
// Get resource for offline download
router.get('/:id/download', auth_1.optionalAuth, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const { id } = req.params;
    const resource = await db_1.db
        .select()
        .from(schema_1.resources)
        .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.resources.id, id), (0, drizzle_orm_1.eq)(schema_1.resources.isOfflineAvailable, true)))
        .limit(1);
    if (!resource.length) {
        return res.status(404).json({
            success: false,
            error: 'Resource not available for offline download',
        });
    }
    // Increment download count
    await db_1.db
        .update(schema_1.resources)
        .set({ downloadCount: (resource[0].downloadCount ?? 0) + 1 })
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, id));
    res.json({
        success: true,
        data: {
            id: resource[0].id,
            title: resource[0].title,
            content: resource[0].content,
            category: resource[0].category,
            tags: resource[0].tags,
            readingTimeMinutes: resource[0].readingTimeMinutes,
            downloadedAt: new Date().toISOString(),
        },
    });
}));
// Get categories
router.get('/categories/list', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const categories = [
        { id: 'mental-health', name: 'Mental Health', description: 'Resources for mental wellness and support' },
        { id: 'srhr', name: 'SRHR', description: 'Sexual and Reproductive Health Rights' },
        { id: 'emergency', name: 'Emergency Support', description: 'Crisis and emergency resources' },
        { id: 'substance-use', name: 'Substance Use', description: 'Support for substance use recovery' },
        { id: 'wellness', name: 'General Wellness', description: 'General health and wellness tips' },
        { id: 'guide', name: 'Guides', description: 'How-to guides and tutorials' },
    ];
    res.json({
        success: true,
        data: categories,
    });
}));
exports.default = router;
//# sourceMappingURL=resources.js.map