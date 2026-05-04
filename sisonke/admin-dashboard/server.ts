import express from "express";
import { createServer as createViteServer } from "vite";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

  // Mock Data
  let emergencyContacts = [
    { id: "1", name: "Childline Zimbabwe", phoneNumber: "116", category: "child-protection", description: "24/7 free helpline for children", country: "Zimbabwe", status: "published", isActive: true },
    { id: "2", name: "Musasa Project", phoneNumber: "08080074", category: "gbv", description: "Shelter and support for GBV survivors", country: "Zimbabwe", status: "published", isActive: true },
  ];

  let resources = [
    { id: "1", title: "Understanding Stress", category: "mental-health", language: "English", status: "published", offlineAvailability: true, updatedAt: new Date().toISOString(), content: "# Stress Management\n\nStress is a natural part of life...", tags: ["stress", "wellness"], isPublished: true, isOfflineAvailable: true, readingTimeMinutes: 5 },
    { id: "2", title: "Amanzi Health Guide", category: "wellness", language: "Shona", status: "draft", offlineAvailability: false, updatedAt: new Date().toISOString(), content: "Content here...", tags: ["health"], isPublished: false, isOfflineAvailable: false, readingTimeMinutes: 3 },
  ];

  let faqs = [
    { id: "1", question: "How can I get help for depression?", goldAnswer: "You can talk to a counselor...", topic: "mental-health", riskLevel: "amber", language: "English" },
  ];

  let safetyRules = [
    { id: "1", route: "self_harm", risk: "red", terms: ["suicide", "end it all"], responseTemplate: "Please contact emergency services immediately.", active: true },
  ];

  let counselorCases = [
    { id: "1", status: "requested", riskLevel: "high", summary: "Crisis situation reported", assignedCounselor: null, updatedAt: new Date().toISOString() },
  ];

  let communityPosts = [
    { id: "1", content: "I feel lonely today.", status: "pending", ageGroup: "15-18", updatedAt: new Date().toISOString() },
  ];

  // API Routes
  app.get("/api/admin/stats", (req, res) => {
    res.json({
      totalUsers: 1250,
      guestSessions: 450,
      chatbotSessions: 890,
      highRiskEscalations: 12,
      counselorCasesWaiting: counselorCases.filter(c => c.status === 'requested').length,
      publishedResources: resources.filter(r => r.isPublished).length,
      communityPostsPending: communityPosts.filter(p => p.status === 'pending').length,
    });
  });

  app.get("/api/emergency/contacts", (req, res) => res.json(emergencyContacts));
  app.post("/api/emergency/contacts", (req, res) => {
    const contact = { id: Math.random().toString(36).substr(2, 9), ...req.body };
    emergencyContacts.push(contact);
    res.status(201).json(contact);
  });
  app.put("/api/emergency/contacts/:id", (req, res) => {
    emergencyContacts = emergencyContacts.map(c => c.id === req.params.id ? { ...c, ...req.body } : c);
    res.json({ success: true });
  });
  app.delete("/api/emergency/contacts/:id", (req, res) => {
    emergencyContacts = emergencyContacts.filter(c => c.id !== req.params.id);
    res.json({ success: true });
  });

  app.get("/api/resources", (req, res) => res.json(resources));
  app.post("/api/resources", (req, res) => {
    const resource = { id: Math.random().toString(36).substr(2, 9), ...req.body, updatedAt: new Date().toISOString() };
    resources.push(resource);
    res.status(201).json(resource);
  });
  app.put("/api/resources/:id", (req, res) => {
    resources = resources.map(r => r.id === req.params.id ? { ...r, ...req.body, updatedAt: new Date().toISOString() } : r);
    res.json({ success: true });
  });
  app.delete("/api/resources/:id", (req, res) => {
    resources = resources.filter(r => r.id !== req.params.id);
    res.json({ success: true });
  });

  app.get("/api/admin/faqs", (req, res) => res.json(faqs));
  app.post("/api/admin/faqs", (req, res) => {
    const faq = { id: Math.random().toString(36).substr(2, 9), ...req.body };
    faqs.push(faq);
    res.status(201).json(faq);
  });

  app.get("/api/admin/safety-rules", (req, res) => res.json(safetyRules));
  app.post("/api/admin/safety-rules/test", (req, res) => {
    const { message } = req.body;
    // Simple mock detection
    const detected = safetyRules.find(rule => rule.terms.some(term => message.toLowerCase().includes(term.toLowerCase())));
    res.json(detected ? { detected: true, rule: detected } : { detected: false });
  });

  app.get("/api/counselor/cases", (req, res) => res.json(counselorCases));
  app.put("/api/counselor/cases/:id", (req, res) => {
    counselorCases = counselorCases.map(c => c.id === req.params.id ? { ...c, ...req.body } : c);
    res.json({ success: true });
  });

  app.get("/api/community/posts", (req, res) => res.json(communityPosts));
  app.put("/api/community/posts/:id/moderate", (req, res) => {
    communityPosts = communityPosts.map(p => p.id === req.params.id ? { ...p, status: req.body.status } : p);
    res.json({ success: true });
  });

  app.get("/api/analytics/summary", (req, res) => {
    res.json({
      appOpens: [40, 50, 45, 60, 55, 70, 65],
      resourceViews: [20, 25, 30, 22, 28, 35, 30],
      highRiskEvents: [1, 0, 2, 0, 1, 3, 0],
    });
  });

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
