import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { AdminLayout } from './layouts/AdminLayout';

// Pages
import { LoginPage } from './pages/LoginPage';
import { ChangePasswordPage } from './pages/ChangePasswordPage';
import { Dashboard } from './pages/Dashboard';
import { EmergencyContacts } from './pages/EmergencyContacts';
import { ResourcesCMS } from './pages/ResourcesCMS';
import { FAQBank } from './pages/FAQBank';
import { SafetyRules } from './pages/SafetyRules';
import { CounselorCases } from './pages/CounselorCases';
import { ModerationQueue } from './pages/ModerationQueue';
import { Analytics } from './pages/Analytics';
import { CounselorWorkload } from './pages/CounselorWorkload';
import { CrisisLog } from './pages/CrisisLog';
import { CohortInsights } from './pages/CohortInsights';
import { OutreachCampaigns } from './pages/OutreachCampaigns';
import { NGOReport } from './pages/NGOReport';
import { PeopleManagement } from './pages/PeopleManagement';
import { Settings } from './pages/Settings';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: string[];
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children, allowedRoles }) => {
  const { user, hasAnyRole } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  if (allowedRoles && !hasAnyRole(allowedRoles)) {
    return <Navigate to="/" replace />;
  }
  return <>{children}</>;
};

function AppRoutes() {
  const { user, login, logout, isAuthenticated, authError, authLoading, finishPasswordChange } = useAuth();

  if (!isAuthenticated) {
    return <LoginPage onLogin={login} error={authError} loading={authLoading} />;
  }

  if (user?.mustChangePassword) {
    return <ChangePasswordPage onDone={finishPasswordChange} onLogout={logout} />;
  }

  return (
    <Router>
      <Routes>
        <Route
          path="/"
          element={
            <AdminLayout title="Dashboard">
              <Dashboard />
            </AdminLayout>
          }
        />
        <Route
          path="/emergency"
          element={
            <AdminLayout title="Emergency Contacts">
              <EmergencyContacts />
            </AdminLayout>
          }
        />
        <Route
          path="/resources"
          element={
            <ProtectedRoute allowedRoles={['admin', 'content-admin', 'content-manager', 'super-admin']}>
              <AdminLayout title="Resources CMS">
                <ResourcesCMS />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/faq"
          element={
            <ProtectedRoute allowedRoles={['admin', 'content-admin', 'content-manager', 'super-admin']}>
              <AdminLayout title="FAQ Bank">
                <FAQBank />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/safety"
          element={
            <ProtectedRoute allowedRoles={['admin', 'system-admin', 'super-admin', 'safety-reviewer']}>
              <AdminLayout title="Chatbot Safety">
                <SafetyRules />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/cases"
          element={
            <ProtectedRoute allowedRoles={['admin', 'counselor', 'super-admin']}>
              <AdminLayout title="Counselor Cases">
                <CounselorCases />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/moderation"
          element={
            <ProtectedRoute allowedRoles={['admin', 'moderator', 'super-admin']}>
              <AdminLayout title="Content Moderation">
                <ModerationQueue />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/analytics"
          element={
            <AdminLayout title="Analytics">
              <Analytics />
            </AdminLayout>
          }
        />
        <Route
          path="/workload"
          element={
            <ProtectedRoute allowedRoles={['admin', 'counselor', 'super-admin']}>
              <AdminLayout title="Counselor Workload">
                <CounselorWorkload />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/crisis-log"
          element={
            <ProtectedRoute allowedRoles={['admin', 'counselor', 'super-admin', 'safety-reviewer']}>
              <AdminLayout title="Crisis Response Log">
                <CrisisLog />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/cohort"
          element={
            <AdminLayout title="Cohort Mood Insights">
              <CohortInsights />
            </AdminLayout>
          }
        />
        <Route
          path="/outreach"
          element={
            <ProtectedRoute allowedRoles={['admin', 'content-admin', 'super-admin']}>
              <AdminLayout title="Outreach Campaigns">
                <OutreachCampaigns />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/ngo-report"
          element={
            <AdminLayout title="NGO Partner Report">
              <NGOReport />
            </AdminLayout>
          }
        />
        <Route
          path="/users"
          element={
            <ProtectedRoute allowedRoles={['admin', 'system-admin', 'super-admin']}>
              <AdminLayout title="People & Roles">
                <PeopleManagement />
              </AdminLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/settings"
          element={
            <AdminLayout title="Settings">
              <Settings />
            </AdminLayout>
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppRoutes />
    </AuthProvider>
  );
}
