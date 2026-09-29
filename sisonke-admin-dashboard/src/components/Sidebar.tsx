import React from 'react';
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
  icon: React.ComponentType<{ size?: number; strokeWidth?: number; className?: string }>;
  roles?: string[]; // required roles if any
}

interface NavGroup {
  label: string;
  items: NavItem[];
}

export const Sidebar = ({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) => {
  const location = useLocation();
  const { hasAnyRole } = useAuth();

  const navGroups: NavGroup[] = [
    {
      label: 'Core',
      items: [
        { name: 'Dashboard', path: '/', icon: BarChart },
        { name: 'Analytics', path: '/analytics', icon: Activity },
        { name: 'Cohort Trends', path: '/cohort', icon: TrendingUp },
        { name: 'NGO Report', path: '/ngo-report', icon: FileText },
      ],
    },
    {
      label: 'Safety & Trust',
      items: [
        { name: 'Emergency Vault', path: '/emergency', icon: Phone },
        { name: 'Safety Rules', path: '/safety', icon: ShieldAlert, roles: ['admin', 'system-admin', 'super-admin', 'safety-reviewer'] },
        { name: 'Moderation', path: '/moderation', icon: MessageSquare, roles: ['admin', 'moderator', 'super-admin'] },
      ],
    },
    {
      label: 'Knowledge',
      items: [
        { name: 'Resources CMS', path: '/resources', icon: BookOpen, roles: ['admin', 'content-admin', 'content-manager', 'super-admin'] },
        { name: 'FAQ Bank', path: '/faq', icon: HelpCircle, roles: ['admin', 'content-admin', 'content-manager', 'super-admin'] },
      ],
    },
    {
      label: 'Care Portal',
      items: [
        { name: 'People Needing Support', path: '/cases', icon: UserCheck, roles: ['admin', 'counselor', 'super-admin'] },
        { name: 'Workload', path: '/workload', icon: Users, roles: ['admin', 'counselor', 'super-admin'] },
        { name: 'Crisis Log', path: '/crisis-log', icon: AlertTriangle, roles: ['admin', 'counselor', 'super-admin', 'safety-reviewer'] },
      ],
    },
    {
      label: 'Outreach',
      items: [{ name: 'Campaigns', path: '/outreach', icon: Bell, roles: ['admin', 'content-admin', 'super-admin'] }],
    },
    {
      label: 'System',
      items: [
        { name: 'People & Roles', path: '/users', icon: Users, roles: ['admin', 'system-admin', 'super-admin'] },
        { name: 'Governance', path: '/settings', icon: SettingsIcon },
      ],
    },
  ];

  return (
    <>
      <div
        className={cn(
          'fixed inset-0 bg-primary-dark/10 backdrop-blur-sm z-40 lg:hidden transition-opacity',
          isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
        )}
        onClick={onClose}
      />
      <motion.aside
        initial={false}
        animate={{ x: isOpen ? 0 : -300 }}
        className={cn(
          'fixed top-0 left-0 bottom-0 w-72 bg-white border-r border-zinc-100 z-50 lg:translate-x-0 transition-transform shadow-2xl lg:shadow-none',
          isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        )}
      >
        <div className="p-8 pb-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-primary rounded-2xl flex items-center justify-center shadow-lg shadow-primary/20">
              <Shield className="text-white" size={24} strokeWidth={2.5} />
            </div>
            <h1 className="text-2xl font-display font-black text-zinc-900 tracking-tight italic uppercase">Sisonke</h1>
          </div>
          <button onClick={onClose} className="lg:hidden p-2 text-zinc-400 hover:text-zinc-900 transition-colors">
            <X size={20} strokeWidth={3} />
          </button>
        </div>

        <nav className="p-6 space-y-8 overflow-y-auto max-h-[calc(100vh-160px)] custom-scrollbar">
          {navGroups.map((group) => {
            const visibleItems = group.items.filter((item) => !item.roles || hasAnyRole(item.roles));
            if (visibleItems.length === 0) return null;

            return (
              <div key={group.label} className="space-y-2">
                <p className="px-4 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 mb-4">{group.label}</p>
                <div className="space-y-1">
                  {visibleItems.map((item) => {
                    const isActive = location.pathname === item.path;
                    const Icon = item.icon;
                    return (
                      <Link
                        key={item.path}
                        to={item.path}
                        onClick={() => onClose()}
                        className={cn(
                          'flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-bold transition-all group relative overflow-hidden',
                          isActive
                            ? 'bg-primary text-white shadow-lg shadow-primary/20'
                            : 'text-zinc-500 hover:bg-primary-dim hover:text-primary'
                        )}
                      >
                        {isActive && (
                          <motion.div layoutId="sidebar-active" className="absolute inset-0 bg-primary -z-10" />
                        )}
                        <Icon
                          size={20}
                          strokeWidth={isActive ? 3 : 2.5}
                          className={cn(
                            'transition-transform group-hover:scale-110',
                            isActive ? 'text-white' : 'text-zinc-400 group-hover:text-primary'
                          )}
                        />
                        {item.name}
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
              <p className="text-[10px] font-black text-zinc-400 uppercase tracking-widest leading-none mb-1">Local Time</p>
              <p className="text-sm font-display font-bold text-zinc-900">Bulawayo • 08:39</p>
            </div>
            <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          </div>
        </div>
      </motion.aside>
    </>
  );
};
