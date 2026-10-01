import React, { useEffect } from 'react';
import {
  BarChart,
  Activity,
  TrendingUp,
  FileText,
  Phone,
  ShieldAlert,
  MessageSquare,
  BookOpen,
  HelpCircle,
  UserCheck,
  Users,
  AlertTriangle,
  Bell,
  Settings as SettingsIcon,
  Shield,
  X,
} from 'lucide-react';
import { motion } from 'motion/react';
import { Link, useLocation } from 'react-router-dom';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { useAuth } from '../context/AuthContext';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface NavItem {
  name: string;
  path: string;
  icon: React.ComponentType<{ size?: number; strokeWidth?: number; className?: string; 'aria-hidden'?: boolean }>;
  roles?: string[];
}

interface NavGroup {
  label: string;
  items: NavItem[];
}

export const Sidebar = ({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) => {
  const location = useLocation();
  const { hasAnyRole } = useAuth();

  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  const navGroups: NavGroup[] = [
    {
      label: 'Executive & Insights',
      items: [
        { name: 'Dashboard Overview', path: '/', icon: BarChart },
        { name: 'Analytics & Traffic', path: '/analytics', icon: Activity },
        { name: 'Cohort Mood Trends', path: '/cohort', icon: TrendingUp },
        { name: 'NGO Funder Report', path: '/ngo-report', icon: FileText },
      ],
    },
    {
      label: 'Clinical Care Portal',
      items: [
        { name: 'Support Cases', path: '/cases', icon: UserCheck, roles: ['admin', 'counselor', 'super-admin'] },
        { name: 'Counselor Workload', path: '/workload', icon: Users, roles: ['admin', 'counselor', 'super-admin'] },
        { name: 'Crisis Response Log', path: '/crisis-log', icon: AlertTriangle, roles: ['admin', 'counselor', 'super-admin', 'safety-reviewer'] },
      ],
    },
    {
      label: 'Safety & Content CMS',
      items: [
        { name: 'Emergency Vault', path: '/emergency', icon: Phone },
        { name: 'Content Moderation', path: '/moderation', icon: MessageSquare, roles: ['admin', 'moderator', 'super-admin'] },
        { name: 'Chatbot Safety Rules', path: '/safety', icon: ShieldAlert, roles: ['admin', 'system-admin', 'super-admin', 'safety-reviewer'] },
        { name: 'Resources CMS', path: '/resources', icon: BookOpen, roles: ['admin', 'content-admin', 'content-manager', 'super-admin'] },
        { name: 'FAQ Knowledge Bank', path: '/faq', icon: HelpCircle, roles: ['admin', 'content-admin', 'content-manager', 'super-admin'] },
        { name: 'Outreach Campaigns', path: '/outreach', icon: Bell, roles: ['admin', 'content-admin', 'super-admin'] },
      ],
    },
    {
      label: 'Governance & Settings',
      items: [
        { name: 'People & Roles', path: '/users', icon: Users, roles: ['admin', 'system-admin', 'super-admin'] },
        { name: 'System Settings', path: '/settings', icon: SettingsIcon },
      ],
    },
  ];


  return (
    <>
      <div
        className={cn(
          'fixed inset-0 bg-primary-dark/20 backdrop-blur-sm z-40 lg:hidden transition-opacity',
          isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
        )}
        onClick={onClose}
        aria-hidden="true"
      />
      <aside
        aria-label="Main Navigation"
        className={cn(
          'fixed top-0 left-0 bottom-0 w-72 bg-white border-r border-zinc-100 z-50 transition-transform duration-300 ease-in-out shadow-2xl lg:shadow-none',
          'lg:translate-x-0',
          isOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        <div className="p-8 pb-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-primary rounded-2xl flex items-center justify-center shadow-lg shadow-primary/20" aria-hidden="true">
              <Shield className="text-white" size={24} strokeWidth={2.5} />
            </div>
            <h1 className="text-2xl font-display font-black text-zinc-900 tracking-tight italic uppercase">Sisonke</h1>
          </div>
          <button
            onClick={onClose}
            aria-label="Close navigation menu"
            className="lg:hidden p-2 text-zinc-500 hover:text-zinc-900 rounded-xl hover:bg-zinc-100 transition-colors"
          >
            <X size={20} strokeWidth={3} />
          </button>
        </div>

        <nav className="p-6 space-y-8 overflow-y-auto max-h-[calc(100vh-160px)] custom-scrollbar" aria-label="Primary site links">
          {navGroups.map((group) => {
            const visibleItems = group.items.filter((item) => !item.roles || hasAnyRole(item.roles));
            if (visibleItems.length === 0) return null;

            return (
              <div key={group.label} className="space-y-2">
                <p className="px-4 text-[11px] font-black uppercase tracking-[0.2em] text-zinc-500 mb-4">{group.label}</p>
                <div className="space-y-1" role="list">
                  {visibleItems.map((item) => {
                    const isActive = location.pathname === item.path;
                    const Icon = item.icon;
                    return (
                      <Link
                        key={item.path}
                        to={item.path}
                        onClick={() => onClose()}
                        aria-current={isActive ? 'page' : undefined}
                        className={cn(
                          'flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-bold transition-all group relative overflow-hidden',
                          isActive
                            ? 'bg-primary text-white shadow-lg shadow-primary/20'
                            : 'text-zinc-700 hover:bg-primary-dim hover:text-primary'
                        )}
                      >
                        {isActive && (
                          <motion.div layoutId="sidebar-active" className="absolute inset-0 bg-primary -z-10" />
                        )}
                        <Icon
                          size={20}
                          strokeWidth={isActive ? 3 : 2.5}
                          aria-hidden={true}
                          className={cn(
                            'transition-transform group-hover:scale-110',
                            isActive ? 'text-white' : 'text-zinc-500 group-hover:text-primary'
                          )}
                        />
                        <span>{item.name}</span>
                      </Link>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </nav>

        <div className="absolute bottom-6 left-6 right-6">
          <div className="p-5 bg-zinc-50 rounded-[2rem] border border-zinc-100 flex items-center justify-between">
            <div className="flex flex-col">
              <p className="text-[10px] font-black text-zinc-500 uppercase tracking-widest leading-none mb-1">Local Time</p>
              <p className="text-sm font-display font-bold text-zinc-900">Bulawayo • 08:39</p>
            </div>
            <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" aria-hidden="true" />
          </div>
        </div>
      </aside>
    </>
  );
};
