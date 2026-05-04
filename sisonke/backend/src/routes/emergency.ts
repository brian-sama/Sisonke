import { Router } from 'express';
import { db } from '../db';
import { emergencyContacts } from '../db/schema';
import { and, eq } from 'drizzle-orm';
import { optionalAuth, authMiddleware, adminOnly } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { zimbabweEmergencyContacts } from '../data/zimbabweRagKnowledge';

const router = Router();

// Get all emergency contacts
router.get('/contacts', asyncHandler(async (req, res) => {
  const dbContacts = await db
    .select()
    .from(emergencyContacts)
    .where(and(eq(emergencyContacts.isActive, true), eq(emergencyContacts.status, 'published')))
    .orderBy(emergencyContacts.category, emergencyContacts.name);

  const seededContacts = zimbabweEmergencyContacts.map((contact) => ({
    id: contact.id,
    name: contact.name,
    phone_number: contact.phoneNumber,
    category: contact.category,
    description: contact.description,
    country: contact.country,
    is_active: true,
    status: 'published',
    created_at: new Date().toISOString(),
  }));

  const allContacts = [
    ...seededContacts,
    ...dbContacts.map(c => ({
      id: c.id,
      name: c.name,
      phone_number: c.phoneNumber,
      category: c.category,
      description: c.description,
      country: c.country,
      is_active: c.isActive,
      status: c.status,
      created_at: c.createdAt.toISOString(),
    })).filter((dbContact) => !seededContacts.some((seeded) => seeded.phone_number === dbContact.phone_number && seeded.name === dbContact.name)),
  ];
  
  // Group by category
  const groupedContacts = allContacts.reduce((acc, contact) => {
    if (!acc[contact.category]) {
      acc[contact.category] = [];
    }
    acc[contact.category].push(contact);
    return acc;
  }, {} as Record<string, any[]>);
  
  res.json({
    success: true,
    data: {
      contacts: groupedContacts,
      total: allContacts.length,
      last_updated: new Date().toISOString(),
    },
  });
}));

// Get emergency contacts by category
router.get('/contacts/:category', asyncHandler(async (req, res) => {
  const { category } = req.params;
  
  const dbContacts = await db
    .select()
    .from(emergencyContacts)
    .where(and(eq(emergencyContacts.category, category), eq(emergencyContacts.isActive, true)))
    .orderBy(emergencyContacts.name);

  const seededContacts = zimbabweEmergencyContacts
    .filter((contact) => contact.category === category)
    .map((contact) => ({
      ...contact,
      status: 'published',
      isActive: true,
      createdAt: null,
      updatedAt: null,
      publishedAt: null,
      deletedAt: null,
    }));

  const contacts = [
    ...seededContacts,
    ...dbContacts.filter((dbContact) => !seededContacts.some((seeded) => seeded.phoneNumber === dbContact.phoneNumber && seeded.name === dbContact.name)),
  ];
  
  res.json({
    success: true,
    data: contacts,
  });
}));

// Add new emergency contact (admin only)
router.post('/contacts', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { name, phoneNumber, category, description, country = 'ZW' } = req.body;
  
  if (!name || !phoneNumber || !category) {
    return res.status(400).json({
      success: false,
      error: 'Name, phone number, and category are required',
    });
  }
  
  const newContact = await db
    .insert(emergencyContacts)
    .values({
      name,
      phoneNumber,
      category,
      description,
      country,
      isActive: true,
    })
    .returning();
  
  res.status(201).json({
    success: true,
    data: newContact[0],
  });
}));

// Update emergency contact (admin only)
router.put('/contacts/:id', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { name, phoneNumber, category, description, isActive } = req.body;
  
  // Check if contact exists
  const existingContact = await db
    .select()
    .from(emergencyContacts)
    .where(eq(emergencyContacts.id, id))
    .limit(1);
  
  if (!existingContact.length) {
    return res.status(404).json({
      success: false,
      error: 'Emergency contact not found',
    });
  }
  
  const updatedContact = await db
    .update(emergencyContacts)
    .set({
      ...(name && { name }),
      ...(phoneNumber && { phoneNumber }),
      ...(category && { category }),
      ...(description !== undefined && { description }),
      ...(isActive !== undefined && { isActive }),
      updatedAt: new Date(),
    })
    .where(eq(emergencyContacts.id, id))
    .returning();
  
  res.json({
    success: true,
    data: updatedContact[0],
  });
}));

// Delete emergency contact (admin only)
router.delete('/contacts/:id', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  // Check if contact exists
  const existingContact = await db
    .select()
    .from(emergencyContacts)
    .where(eq(emergencyContacts.id, id))
    .limit(1);
  
  if (!existingContact.length) {
    return res.status(404).json({
      success: false,
      error: 'Emergency contact not found',
    });
  }
  
  await db.delete(emergencyContacts).where(eq(emergencyContacts.id, id));
  
  res.json({
    success: true,
    message: 'Emergency contact deleted successfully',
  });
}));

// Get emergency toolkit resources
router.get('/toolkit', asyncHandler(async (req, res) => {
  const toolkit = {
    breathing_exercises: [
      {
        id: 'belly-breathing',
        title: 'Deep Belly Breathing',
        description: 'Put one hand on your chest and one on your belly. Breathe in so your belly rises, then breathe out slowly.',
        inhale_seconds: 4,
        hold_seconds: 0,
        exhale_seconds: 6,
        cycles: 5,
      },
      {
        id: 'box-breathing',
        title: 'Box Breathing',
        description: 'Breathe in, hold, out, hold - all for 4 counts',
        inhale_seconds: 4,
        hold_seconds: 4,
        exhale_seconds: 4,
        cycles: 4,
      },
    ],
    grounding_exercises: [
      {
        id: '5-4-3-2-1',
        title: '5-4-3-2-1 Grounding',
        description: 'Use your senses to ground yourself in the present',
        steps: [
          'Name 5 things you can SEE around you',
          'Name 4 things you can FEEL',
          'Name 3 things you can HEAR',
          'Name 2 things you can SMELL',
          'Name 1 thing you can TASTE',
        ],
      },
    ],
    safety_plan_steps: [
      { id: '1', title: 'Move to Safety', description: 'If it is safe to move, go near other people or a trusted adult.', order: 1 },
      { id: '2', title: 'Avoid Danger Spots', description: 'Stay away from kitchens, garages, locked rooms, or weapons during violence.', order: 2 },
      { id: '3', title: 'Contact Help', description: 'Call Childline 116, Musasa for GBV, Adult Rape Clinic for rape, or 999 for immediate danger.', order: 3 },
    ],
    quick_exit_url: 'https://www.google.com/search?q=weather+today',
  };
  
  res.json({
    success: true,
    data: toolkit,
  });
}));

// Quick exit endpoint (returns neutral content)
router.get('/quick-exit', asyncHandler(async (req, res) => {
  // Return a neutral page that looks like a weather app or news site
  const neutralContent = {
    title: 'Weather Today',
    content: {
      temperature: '24°C',
      condition: 'Partly Cloudy',
      forecast: 'Pleasant weather expected throughout the day',
      location: 'Harare, Zimbabwe',
    },
    // Add some random weather data to make it look realistic
    hourly: [
      { time: '9:00 AM', temp: '22°C', condition: 'Sunny' },
      { time: '12:00 PM', temp: '26°C', condition: 'Partly Cloudy' },
      { time: '3:00 PM', temp: '25°C', condition: 'Cloudy' },
      { time: '6:00 PM', temp: '21°C', condition: 'Clear' },
    ],
  };
  
  res.json({
    success: true,
    data: neutralContent,
  });
}));

export default router;
