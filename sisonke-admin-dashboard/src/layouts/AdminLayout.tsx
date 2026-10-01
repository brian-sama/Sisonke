import React, { useState } from 'react';
import { motion, AnimatePresence, useReducedMotion } from 'motion/react';
import { useLocation } from 'react-router-dom';
import { Sidebar } from '../components/Sidebar';
import { TopBar } from '../components/TopBar';
import { useAuth } from '../context/AuthContext';
import { SkipLink, ErrorBoundary } from '../components';

interface AdminLayoutProps {
  children: React.ReactNode;
  title: string;
}

export const AdminLayout: React.FC<AdminLayoutProps> = ({ children, title }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { user, logout } = useAuth();
  const location = useLocation();
  const shouldReduceMotion = useReducedMotion();

  React.useEffect(() => {
    document.title = `${title} | Sisonke Platform`;
  }, [title]);

  return (
    <div className="min-h-screen bg-white">
      <SkipLink targetId="main-content" />
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="lg:pl-72 min-h-screen flex flex-col">
        <TopBar
          title={title}
          user={user}
          onLogout={logout}
          onMenuOpen={() => setSidebarOpen(true)}
        />
        <main
          id="main-content"
          tabIndex={-1}
          className="flex-1 bg-zinc-50/10 focus:outline-none"
          role="main"
          aria-label={title}
        >
          <ErrorBoundary>
            <AnimatePresence mode="wait">
              <motion.div
                key={location.pathname}
                initial={shouldReduceMotion ? false : { opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={shouldReduceMotion ? undefined : { opacity: 0, y: -10 }}
                transition={{ duration: shouldReduceMotion ? 0 : 0.2 }}
                className="min-h-full"
              >
                {children}
              </motion.div>
            </AnimatePresence>
          </ErrorBoundary>
        </main>
      </div>
    </div>
  );
};
