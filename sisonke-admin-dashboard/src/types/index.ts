export type Role =
  | 'user'
  | 'counselor'
  | 'moderator'
  | 'content-admin'
  | 'content-manager'
  | 'safety-reviewer'
  | 'analyst'
  | 'admin'
  | 'system-admin'
  | 'super-admin';

export interface AdminUser {
  email: string;
  roles: string[];
  name?: string;
  avatarUrl?: string;
  mustChangePassword?: boolean;
}

export interface AuthState {
  user: AdminUser | null;
  isAuthenticated: boolean;
  authError: string | null;
  authLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  finishPasswordChange: () => void;
  hasRole: (role: string) => boolean;
  hasAnyRole: (roles: string[]) => boolean;
}

export type RiskLevel = 'high' | 'medium' | 'low';

export interface EmergencyContact {
  id: string;
  name: string;
  phoneNumber: string;
  category: string;
  description: string;
  country?: string;
  status?: string;
  isActive: boolean;
}

export interface ResourceItem {
  id: string;
  title: string;
  content: string;
  category: 'mental-health' | 'srhr' | 'wellness' | 'emergency' | 'guide';
  language: string;
  isPublished: boolean;
  isOfflineAvailable?: boolean;
  tags?: string[];
  updatedAt: string;
}

export interface FAQItem {
  id: string;
  question: string;
  goldAnswer: string;
  topic: string;
  riskLevel: 'red' | 'amber' | 'green';
  language: string;
}

export interface SafetyRule {
  id: string;
  route: string;
  risk: 'red' | 'amber';
  terms: string[];
  responseTemplate: string;
  active?: boolean;
}

export interface CounselorCase {
  id: string;
  summary: string;
  riskLevel: 'high' | 'medium' | 'low';
  counselorId?: string | null;
  status?: string;
  createdAt?: string;
  updatedAt?: string;
}
