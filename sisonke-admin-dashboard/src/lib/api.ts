export const fetchStats = () => fetch("/api/admin/stats").then(res => res.json());
export const fetchContacts = () => fetch("/api/emergency/contacts").then(res => res.json());
export const fetchResources = () => fetch("/api/resources").then(res => res.json());
export const fetchFAQs = () => fetch("/api/admin/faqs").then(res => res.json());
export const fetchRules = () => fetch("/api/admin/safety-rules").then(res => res.json());
export const fetchCases = () => fetch("/api/counselor/cases").then(res => res.json());
export const fetchPosts = () => fetch("/api/community/posts").then(res => res.json());
export const fetchAnalytics = () => fetch("/api/analytics/summary").then(res => res.json());
