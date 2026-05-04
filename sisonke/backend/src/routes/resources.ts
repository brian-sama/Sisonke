import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { resources, users } from '../db/schema';
import { eq, and, ilike, desc, asc } from 'drizzle-orm';
import { CreateResourceSchema, UpdateResourceSchema, ResourceQuerySchema } from '../types';
import { authMiddleware, optionalAuth, adminOnly, hasAnyRole } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

// Get all resources with filtering and search
router.get('/', optionalAuth, asyncHandler(async (req, res) => {
  const query = ResourceQuerySchema.parse(req.query);
  
  let baseQuery = db.select().from(resources).$dynamic();
  
  // Add filters
  const conditions = [];
  
  if (query.category) {
    conditions.push(eq(resources.category, query.category));
  }
  
  if (query.search) {
    conditions.push(
      ilike(resources.title, `%${query.search}%`)
    );
  }
  
  if (query.language) {
    conditions.push(eq(resources.language, query.language));
  }
  
  // Only show published resources to non-admin users
  if (!hasAnyRole(req.user, ['admin', 'super-admin'])) {
    conditions.push(eq(resources.status, 'published'));
    conditions.push(eq(resources.isPublished, true));
  }
  
  // Apply conditions
  if (conditions.length > 0) {
    baseQuery = baseQuery.where(and(...conditions));
  }
  
  // Add ordering (newest first)
  baseQuery = baseQuery.orderBy(desc(resources.createdAt));
  
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
router.get('/:id', optionalAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  const resource = await db
    .select()
    .from(resources)
    .where(eq(resources.id, id))
    .limit(1);
  
  if (!resource.length) {
    return res.status(404).json({
      success: false,
      error: 'Resource not found',
    });
  }
  
  // Check if resource is published (unless admin)
  if (!hasAnyRole(req.user, ['admin', 'super-admin'])) {
    if (!resource[0].isPublished) {
      return res.status(404).json({
        success: false,
        error: 'Resource not found',
      });
    }
  }
  
  // Increment view count
  await db
    .update(resources)
    .set({ viewCount: (resource[0].viewCount ?? 0) + 1 })
    .where(eq(resources.id, id));
  
  res.json({
    success: true,
    data: resource[0],
  });
}));

// Create new resource (admin only)
router.post('/', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const validatedData = CreateResourceSchema.parse(req.body);
  
  const newResource = await db
    .insert(resources)
    .values({
      ...validatedData,
      authorId: req.user!.id,
    })
    .returning();
  
  res.status(201).json({
    success: true,
    data: newResource[0],
  });
}));

// Update resource (admin only)
router.put('/:id', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const validatedData = UpdateResourceSchema.parse(req.body);
  
  // Check if resource exists
  const existingResource = await db
    .select()
    .from(resources)
    .where(eq(resources.id, id))
    .limit(1);
  
  if (!existingResource.length) {
    return res.status(404).json({
      success: false,
      error: 'Resource not found',
    });
  }
  
  const updatedResource = await db
    .update(resources)
    .set({
      ...validatedData,
      updatedAt: new Date(),
    })
    .where(eq(resources.id, id))
    .returning();
  
  res.json({
    success: true,
    data: updatedResource[0],
  });
}));

// Delete resource (admin only)
router.delete('/:id', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  // Check if resource exists
  const existingResource = await db
    .select()
    .from(resources)
    .where(eq(resources.id, id))
    .limit(1);
  
  if (!existingResource.length) {
    return res.status(404).json({
      success: false,
      error: 'Resource not found',
    });
  }
  
  await db.delete(resources).where(eq(resources.id, id));
  
  res.json({
    success: true,
    message: 'Resource deleted successfully',
  });
}));

// Get resource for offline download
router.get('/:id/download', optionalAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  const resource = await db
    .select()
    .from(resources)
    .where(and(eq(resources.id, id), eq(resources.isOfflineAvailable, true)))
    .limit(1);
  
  if (!resource.length) {
    return res.status(404).json({
      success: false,
      error: 'Resource not available for offline download',
    });
  }
  
  // Increment download count
  await db
    .update(resources)
    .set({ downloadCount: (resource[0].downloadCount ?? 0) + 1 })
    .where(eq(resources.id, id));
  
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
router.get('/categories/list', asyncHandler(async (req, res) => {
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

export default router;
