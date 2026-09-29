import React from 'react';
import { Menu, LogOut } from 'lucide-react';
import { AdminUser } from '../types';

interface TopBarProps {
  title: string;
  user: AdminUser | null;
  onLogout: () => void;
  onMenuOpen: () => void;
}

export const TopBar: React.FC<TopBarProps> = ({ title, user, onLogout, onMenuOpen }) => {
  const primaryRole = user?.roles?.[0] ? user.roles[0].replace('-', ' ') : 'Admin';

  return (
    <header className="h-20 bg-white/80 backdrop-blur-md flex items-center justify-between px-6 lg:px-10 sticky top-0 z-30">
      <div className="flex items-center gap-4">
        <button
          aria-label="Open navigation menu"
          onClick={onMenuOpen}
          className="lg:hidden p-2 text-zinc-500 hover:bg-zinc-100 rounded-xl"
        >
          <Menu size={24} />
        </button>
        <h2 className="text-xl font-display font-bold text-zinc-900">{title}</h2>
      </div>
      <div className="flex items-center gap-6">
        <div className="hidden sm:flex items-center gap-3 px-4 py-2 bg-primary-dim border border-primary-dim rounded-2xl">
          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold ring-4 ring-white shadow-sm">
            {(user?.name || user?.email || 'A')[0].toUpperCase()}
          </div>
          <div className="flex flex-col text-sm">
            <span className="font-semibold text-primary-dark leading-none mb-0.5">
              {user?.name || user?.email?.split('@')[0]}
            </span>
            <span className="text-[10px] text-primary font-bold uppercase tracking-wider">
              {primaryRole}
            </span>
          </div>
        </div>
        <button
          onClick={onLogout}
          className="p-3 text-zinc-400 hover:text-rose-600 hover:bg-rose-50 rounded-2xl transition-all hover:rotate-12"
          title="Sign out"
        >
          <LogOut size={22} />
        </button>
      </div>
    </header>
  );
};
