import React, { useState, useEffect } from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  LineChart, Line, PieChart, Pie, Cell, Legend
} from 'recharts';
import {
  Users, MessageSquare, AlertTriangle, Clock, BookOpen,
  ShieldAlert, Phone, HelpCircle, UserCheck, Shield,
  Settings as SettingsIcon, LogOut, Menu, X, Search,
  Plus, Edit2, Trash2, Check, ExternalLink, Filter, ChevronRight,
  Tag, Globe, PieChart as PieChartIcon, Activity, Lock, Mail,
  TrendingUp, Send, FileText, Layers, Bell, BarChart2
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  BrowserRouter as Router, 
  Routes, 
  Route, 
  Link, 
  useLocation, 
  useNavigate,
  Navigate
} from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { apiFetch, loginUser, clearSession } from './lib/api';
import {
  SisonkeCard,
  PageHeader,
  SectionLabel,
  RiskBadge,
  PrimaryButton,
  GhostButton,
  StatTile,
  EmptyState,
  SkeletonCard,
  SkeletonBlock,
} from './components';

// --- Utils ---
function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// --- Auth ---
const useAuth = () => {
  const [user, setUser] = useState<{ email: string; roles: string[] } | null>(() => {
    const saved = sessionStorage.getItem('sisonke_admin_user');
    return saved ? JSON.parse(saved) : null;
  });
  const [authError, setAuthError] = useState<string | null>(null);
  const [authLoading, setAuthLoading] = useState(false);

  const login = async (email: string, password: string) => {
    setAuthLoading(true);
    setAuthError(null);
    try {
      const { token, user: userData } = await loginUser(email, password);
      sessionStorage.setItem('sisonke_admin_token', token);
      sessionStorage.setItem('sisonke_admin_user', JSON.stringify({ email: userData.email, roles: userData.roles }));
      setUser({ email: userData.email, roles: userData.roles });
    } catch (err: any) {
      setAuthError(err.message || 'Login failed');
    } finally {
      setAuthLoading(false);
    }
  };

  const logout = () => {
    setUser(null);
    clearSession();
  };

  return { user, login, logout, isAuthenticated: !!user, authError, authLoading };
};

// --- Components ---

const Sidebar = ({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) => {
  const location = useLocation();
  
  const navGroups = [
    {
      label: 'Core',
      items: [
        { name: 'Dashboard', path: '/', icon: BarChart },
        { name: 'Analytics', path: '/analytics', icon: Activity },
        { name: 'Cohort Trends', path: '/cohort', icon: TrendingUp },
        { name: 'NGO Report', path: '/ngo-report', icon: FileText },
      ]
    },
    {
      label: 'Safety & Trust',
      items: [
        { name: 'Emergency Vault', path: '/emergency', icon: Phone },
        { name: 'Safety Rules', path: '/safety', icon: ShieldAlert },
        { name: 'Moderation', path: '/moderation', icon: MessageSquare },
      ]
    },
    {
      label: 'Knowledge',
      items: [
        { name: 'Resources CMS', path: '/resources', icon: BookOpen },
        { name: 'FAQ Bank', path: '/faq', icon: HelpCircle },
      ]
    },
    {
      label: 'Care Portal',
      items: [
        { name: 'People Needing Support', path: '/cases', icon: UserCheck },
        { name: 'Workload', path: '/workload', icon: Users },
        { name: 'Crisis Log', path: '/crisis-log', icon: AlertTriangle },
      ]
    },
    {
      label: 'Outreach',
      items: [
        { name: 'Campaigns', path: '/outreach', icon: Bell },
      ]
    },
    {
      label: 'System',
      items: [
        { name: 'Governance', path: '/settings', icon: SettingsIcon },
      ]
    }
  ];

  return (
    <>
      <div 
        className={cn(
          "fixed inset-0 bg-primary-dark/10 backdrop-blur-sm z-40 lg:hidden transition-opacity",
          isOpen ? "opacity-100" : "opacity-0 pointer-events-none"
        )} 
        onClick={onClose}
      />
      <motion.aside 
        initial={false}
        animate={{ x: isOpen ? 0 : -300 }}
        className={cn(
          "fixed top-0 left-0 bottom-0 w-72 bg-white border-r border-zinc-100 z-50 lg:translate-x-0 transition-transform shadow-2xl lg:shadow-none",
          isOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
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
          {navGroups.map((group) => (
            <div key={group.label} className="space-y-2">
              <p className="px-4 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 mb-4">{group.label}</p>
              <div className="space-y-1">
                {group.items.map((item) => {
                  const isActive = location.pathname === item.path;
                  const Icon = item.icon;
                  return (
                    <Link
                      key={item.path}
                      to={item.path}
                      onClick={() => onClose()}
                      className={cn(
                        "flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-bold transition-all group relative overflow-hidden",
                        isActive 
                          ? "bg-primary text-white shadow-lg shadow-primary/20" 
                          : "text-zinc-500 hover:bg-primary-dim hover:text-primary"
                      )}
                    >
                      {isActive && (
                        <motion.div 
                          layoutId="sidebar-active"
                          className="absolute inset-0 bg-primary -z-10"
                        />
                      )}
                      <Icon size={20} strokeWidth={isActive ? 3 : 2.5} className={cn(
                        "transition-transform group-hover:scale-110",
                        isActive ? "text-white" : "text-zinc-400 group-hover:text-primary"
                      )} />
                      {item.name}
                    </Link>
                  );
                })}
              </div>
            </div>
          ))}
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

const TopBar = ({ title, user, onLogout, onMenuOpen }: any) => (
  <header className="h-20 bg-white/80 backdrop-blur-md flex items-center justify-between px-6 lg:px-10 sticky top-0 z-30">
    <div className="flex items-center gap-4">
      <button onClick={onMenuOpen} className="lg:hidden p-2 text-zinc-500 hover:bg-zinc-100 rounded-xl">
        <Menu size={24} />
      </button>
      <h2 className="text-xl font-display font-bold text-zinc-900">{title}</h2>
    </div>
    <div className="flex items-center gap-6">
      <div className="hidden sm:flex items-center gap-3 px-4 py-2 bg-primary-dim border border-primary-dim rounded-2xl">
        <div className="w-8 h-8 rounded-full bg-primary-dim0 flex items-center justify-center text-white text-xs font-bold ring-4 ring-white shadow-sm">
          {user?.email?.[0].toUpperCase()}
        </div>
        <div className="flex flex-col text-sm">
          <span className="font-semibold text-primary-dark leading-none mb-0.5">{user?.email?.split('@')[0]}</span>
          <span className="text-[10px] text-primary font-bold uppercase tracking-wider">Super Admin</span>
        </div>
      </div>
      <button 
        onClick={onLogout}
        className="p-3 text-zinc-400 hover:text-rose-600 hover:bg-rose-50 rounded-2xl transition-all hover:rotate-12"
      >
        <LogOut size={22} />
      </button>
    </div>
  </header>
);

// Card is now SisonkeCard — keeping this alias for backward compat in this file
const Card = SisonkeCard;

// --- Pages ---

const Dashboard = () => {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/api/admin/stats').then(res => res.json()).then(data => {
      setStats(data);
      setLoading(false);
    });
  }, []);

  if (loading) return (
    <div className="p-10 space-y-8 max-w-7xl mx-auto">
      <SkeletonBlock className="h-8 w-48" />
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {[1,2,3,4,5,6].map(i => <SkeletonCard key={i} />)}
      </div>
    </div>
  );

  const tiles = [
    { title: 'People Registered',       value: stats.totalUsers,             icon: Users,         iconColor: 'text-primary',      iconBg: 'bg-primary-dim',  trend: '+12%' },
    { title: 'Guest Conversations',     value: stats.guestSessions,          icon: Clock,         iconColor: 'text-emerald-600',  iconBg: 'bg-emerald-50',   trend: '+8%'  },
    { title: 'E-Friend Conversations',  value: stats.chatbotSessions,        icon: MessageSquare, iconColor: 'text-blue-600',     iconBg: 'bg-blue-50',      trend: '+21%' },
    { title: 'People Needing Urgent Care', value: stats.highRiskEscalations, icon: AlertTriangle, iconColor: 'text-rose-600',     iconBg: 'bg-rose-50'                    },
    { title: 'People Needing Support',  value: stats.counselorCasesWaiting,  icon: UserCheck,     iconColor: 'text-amber-600',    iconBg: 'bg-amber-50'                   },
    { title: 'Whispers to Moderate',    value: stats.communityPostsPending,  icon: MessageSquare, iconColor: 'text-violet-600',   iconBg: 'bg-violet-50'                  },
  ];

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        {tiles.map((tile, i) => (
          <StatTile key={i} {...tile} />
        ))}
      </motion.div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <Card className="p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-display font-bold">Activity Pulse</h3>
            <div className="flex gap-2">
               <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-500">
                 <div className="w-3 h-3 rounded-full bg-primary-dim0" />
                 App Opens
               </div>
               <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-500">
                 <div className="w-3 h-3 rounded-full bg-blue-400" />
                 Chatbot
               </div>
            </div>
          </div>
          <div className="h-[320px]">
             <ResponsiveContainer width="100%" height="100%">
                <BarChart data={[
                  { name: 'Mon', apps: 400, chatbot: 240 },
                  { name: 'Tue', apps: 300, chatbot: 139 },
                  { name: 'Wed', apps: 200, chatbot: 980 },
                  { name: 'Thu', apps: 278, chatbot: 390 },
                  { name: 'Fri', apps: 189, chatbot: 480 },
                  { name: 'Sat', apps: 239, chatbot: 380 },
                  { name: 'Sun', apps: 349, chatbot: 430 },
                ]}>
                  <XAxis dataKey="name" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                  <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                  <Tooltip 
                    contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                  />
                  <Bar dataKey="apps" fill="#2E6F60" radius={[8, 8, 0, 0]} maxBarSize={32} />
                  <Bar dataKey="chatbot" fill="#60a5fa" radius={[8, 8, 0, 0]} maxBarSize={32} />
                </BarChart>
             </ResponsiveContainer>
          </div>
        </Card>

        <Card className="p-8">
          <h3 className="text-xl font-display font-bold mb-8">Alert Escalations</h3>
          <div className="h-[320px]">
             <ResponsiveContainer width="100%" height="100%">
                <LineChart data={[
                  { name: 'Week 1', alerts: 4 },
                  { name: 'Week 2', alerts: 7 },
                  { name: 'Week 3', alerts: 2 },
                  { name: 'Week 4', alerts: 12 },
                ]}>
                  <XAxis dataKey="name" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                  <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                  <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }} />
                  <defs>
                    <linearGradient id="lineGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#f43f5e" stopOpacity={0.8}/>
                      <stop offset="95%" stopColor="#f43f5e" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <Line 
                    type="monotone" 
                    dataKey="alerts" 
                    stroke="#f43f5e" 
                    strokeWidth={4} 
                    dot={{ r: 6, fill: '#f43f5e', strokeWidth: 3, stroke: '#fff' }} 
                    activeDot={{ r: 8, strokeWidth: 0 }}
                  />
                </LineChart>
             </ResponsiveContainer>
          </div>
        </Card>
      </div>
    </div>
  );
};

const EmergencyContacts = () => {
  const [contacts, setContacts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    apiFetch('/api/emergency/contacts').then(res => res.json()).then(data => {
      setContacts(data);
      setLoading(false);
    });
  }, []);

  const filtered = contacts.filter(c => c.name.toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div className="relative flex-1 max-w-lg">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
          <input 
            type="text" 
            placeholder="Find specialized support contacts..." 
            className="w-full pl-12 pr-6 py-4 bg-white border border-zinc-200 rounded-2xl shadow-sm focus:ring-4 focus:ring-primary-dim0/10 focus:border-primary focus:outline-none transition-all placeholder:text-zinc-400"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <button className="flex items-center justify-center gap-2 px-6 py-4 bg-primary text-white rounded-2xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 active:translate-y-0 transition-all">
          <Plus size={20} strokeWidth={3} /> Add New Contact
        </button>
      </div>

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead className="bg-zinc-50/50 border-b border-zinc-100">
              <tr>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Contact Details</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Classification</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Direct Line</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Live Status</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {filtered.map((contact) => (
                <tr key={contact.id} className="hover:bg-primary-dim/30 transition-colors group">
                  <td className="px-8 py-6">
                    <div className="font-display font-bold text-zinc-900 text-base">{contact.name}</div>
                    <div className="text-sm text-zinc-500 mt-0.5 line-clamp-1">{contact.description}</div>
                  </td>
                  <td className="px-8 py-6">
                    <span className="inline-flex items-center px-3 py-1 rounded-xl text-[11px] font-black uppercase tracking-wider bg-white border border-zinc-100 text-zinc-600 shadow-sm">
                      {contact.category.replace('-', ' ')}
                    </span>
                  </td>
                  <td className="px-8 py-6 font-mono text-base font-bold text-primary">{contact.phoneNumber}</td>
                  <td className="px-8 py-6">
                    <div className={cn(
                      "inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter",
                      contact.isActive ? "bg-emerald-100 text-emerald-700" : "bg-zinc-100 text-zinc-500"
                    )}>
                      <div className={cn("w-1.5 h-1.5 rounded-full", contact.isActive ? "bg-emerald-500 animate-pulse" : "bg-zinc-400")} />
                      {contact.isActive ? 'Active' : 'Offline'}
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button type="button" aria-label="Edit contact" className="p-2.5 text-zinc-400 hover:text-primary hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-100 transition-all">
                        <Edit2 size={18} />
                      </button>
                      <button type="button" aria-label="Remove contact" className="p-2.5 text-zinc-400 hover:text-rose-600 hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-100 transition-all">
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
};

const ResourcesCMS = () => {
  const [resources, setResources] = useState<any[]>([]);
  const [editing, setEditing] = useState<any>(null);

  useEffect(() => {
    apiFetch('/api/resources').then(res => res.json()).then(setResources);
  }, []);

  return (
    <div className="p-6 lg:p-10 grid grid-cols-1 lg:grid-cols-12 gap-10 max-w-screen-2xl mx-auto">
      <div className="lg:col-span-12 xl:col-span-8 space-y-8">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
           <div>
             <h3 className="text-3xl font-display font-black text-zinc-900 leading-tight">Content Library</h3>
             <p className="text-zinc-500 font-medium">Manage wellness guides and resources for Zimbabwe youth</p>
           </div>
           <button onClick={() => setEditing({ title: '', content: '', category: 'wellness', isPublished: false })} className="flex items-center justify-center gap-2 px-8 py-4 bg-primary text-white rounded-2xl font-bold hover:bg-primary-dark shadow-xl shadow-primary/20 active:scale-95 transition-all">
             <Plus size={20} strokeWidth={3} /> Create Resource
           </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {resources.map(r => (
              <Card key={r.id} className="p-0 border-none bg-white shadow-xl shadow-zinc-200/50 hover:shadow-2xl hover:shadow-primary-dim transition-all overflow-hidden group">
                <div className={cn(
                  "h-32 p-6 flex items-end relative overflow-hidden",
                  r.category === 'mental-health' ? "bg-primary" : 
                  r.category === 'srhr' ? "bg-rose-500" : "bg-amber-500"
                )}>
                  <div className="absolute top-4 right-4">
                    <span className={cn(
                      "px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider",
                      r.isPublished ? "bg-emerald-400/20 text-white" : "bg-white/20 text-white"
                    )}>
                      {r.isPublished ? 'Live' : 'Draft'}
                    </span>
                  </div>
                  <h4 className="font-display font-black text-white text-xl leading-tight group-hover:translate-x-2 transition-transform">{r.title}</h4>
                </div>
                <div className="p-6 space-y-4">
                  <div className="flex items-center gap-4 text-[10px] font-black uppercase tracking-widest text-zinc-400">
                    <span className="bg-zinc-100 px-2 py-1 rounded-lg">{r.category}</span>
                    <span>•</span>
                    <span>{r.language}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-zinc-500 font-medium italic">Updated {new Date(r.updatedAt).toLocaleDateString()}</span>
                    <button type="button" aria-label="Edit resource" onClick={() => setEditing(r)} className="w-10 h-10 rounded-xl bg-zinc-50 flex items-center justify-center hover:bg-primary-dim hover:text-primary transition-colors">
                      <Edit2 size={18} />
                    </button>
                  </div>
                </div>
              </Card>
            ))}
        </div>
      </div>

      <div className="lg:col-span-12 xl:col-span-4 self-start">
        <AnimatePresence mode="wait">
          {editing ? (
            <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95 }}>
              <Card className="p-10 space-y-10 sticky top-24 border-primary-dim ring-4 ring-primary-dim shadow-2xl">
                <div className="flex items-center justify-between">
                  <h3 className="font-display font-black text-2xl tracking-tight">{editing.id ? 'Refine' : 'Compose'}</h3>
                  <button type="button" aria-label="Close editor" onClick={() => setEditing(null)} className="w-8 h-8 rounded-full bg-zinc-100 flex items-center justify-center text-zinc-400 hover:text-rose-600 transition-colors"><X size={18} strokeWidth={3} /></button>
                </div>
                
                <div className="space-y-8">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Resource Title</label>
                    <input autoFocus value={editing.title} onChange={e => setEditing({...editing, title: e.target.value})} className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl font-display font-bold text-lg focus:ring-4 focus:ring-primary-mid outline-none transition-all" placeholder="Enter a catchy title..." />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Markdown Fabric</label>
                    <textarea 
                      rows={12} 
                      value={editing.content} 
                      onChange={e => setEditing({...editing, content: e.target.value})}
                      className="w-full p-4 bg-zinc-50 border border-zinc-200 rounded-xl font-mono text-xs leading-relaxed focus:ring-4 focus:ring-primary-mid outline-none transition-all resize-none"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Pillar</label>
                      <select value={editing.category} onChange={e => setEditing({...editing, category: e.target.value})} className="w-full p-3 bg-zinc-50 border border-zinc-200 rounded-xl font-bold text-sm focus:ring-4 focus:ring-primary-mid outline-none">
                        <option value="mental-health">🧠 Mental Health</option>
                        <option value="srhr">🩸 SRHR</option>
                        <option value="wellness">🌿 Wellness</option>
                      </select>
                    </div>
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Visibility</label>
                      <button 
                        onClick={() => setEditing({...editing, isPublished: !editing.isPublished})}
                        className={cn(
                          "w-full p-3 rounded-xl font-black text-[10px] uppercase tracking-widest flex items-center justify-center gap-2 transition-all shadow-sm",
                          editing.isPublished ? "bg-emerald-500 text-white" : "bg-zinc-100 text-zinc-500"
                        )}
                      >
                        {editing.isPublished ? <Check size={14} strokeWidth={4} /> : <div className="w-3.5 h-3.5 border-2 border-zinc-300 rounded-sm" />}
                        {editing.isPublished ? 'Published' : 'Draft Mode'}
                      </button>
                    </div>
                  </div>
                  <button className="w-full py-5 bg-zinc-900 text-white rounded-3xl font-display font-bold text-lg shadow-xl shadow-zinc-900/20 active:scale-95 transition-all">Save Resource & Notify Youth</button>
                </div>
              </Card>
            </motion.div>
          ) : (
            <div className="h-[600px] border-4 border-dashed border-zinc-100 rounded-[3rem] flex flex-col items-center justify-center p-12 text-center">
              <div className="w-20 h-20 bg-zinc-50 rounded-full flex items-center justify-center mb-6">
                <BookOpen className="text-zinc-200" size={32} />
              </div>
              <h4 className="text-xl font-display font-bold text-zinc-300 mb-2">Editor Inactive</h4>
              <p className="text-zinc-400 text-sm max-w-[200px]">Select a card to refine content or tap '+' to build a new wellness guide.</p>
            </div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
};

const FAQBank = () => {
  const [faqs, setFaqs] = useState<any[]>([]);
  useEffect(() => {
    apiFetch('/api/admin/faqs').then(res => res.json()).then(setFaqs);
  }, []);

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 bg-primary p-8 lg:p-12 rounded-[3.5rem] shadow-2xl relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full -translate-y-1/2 translate-x-1/2 blur-3xl pointer-events-none" />
        <div className="relative z-10">
          <h3 className="text-4xl font-display font-black text-white leading-tight">Gold FAQ Bank</h3>
          <p className="text-white/80 font-medium mt-1">High-quality, vetted answers for AI & Youth</p>
        </div>
        <button className="relative z-10 px-8 py-4 bg-white text-primary rounded-3xl font-black text-sm uppercase tracking-widest shadow-xl hover:scale-105 transition-transform active:scale-95">Add FAQ</button>
      </div>
      
      <div className="space-y-6">
        {faqs.map(faq => (
          <motion.div key={faq.id} whileHover={{ y: -4 }}>
            <Card className="p-10 border-none bg-white shadow-xl shadow-zinc-100/60 flex flex-col md:flex-row items-start gap-8">
               <div className={cn(
                 "shrink-0 w-16 h-16 rounded-3xl flex items-center justify-center font-display font-black text-2xl shadow-lg",
                 faq.riskLevel === 'red' ? "bg-rose-500 text-white shadow-rose-200" :
                 faq.riskLevel === 'amber' ? "bg-amber-500 text-white shadow-amber-200" : "bg-emerald-500 text-white shadow-emerald-200"
               )}>
                 {faq.riskLevel === 'red' ? '!' : '?'}
               </div>
               <div className="flex-1 space-y-5">
                 <div className="flex flex-wrap items-center gap-3">
                    <h4 className="text-2xl font-display font-black text-zinc-900 leading-tight">{faq.question}</h4>
                    <span className={cn(
                      "px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest",
                      faq.riskLevel === 'red' ? "bg-rose-100 text-rose-700" :
                      faq.riskLevel === 'amber' ? "bg-amber-100 text-amber-700" : "bg-emerald-100 text-emerald-700"
                    )}>
                      {faq.riskLevel} risk tier
                    </span>
                 </div>
                 <div className="p-6 bg-zinc-50 rounded-3xl border border-zinc-100 italic text-zinc-600 leading-relaxed text-lg">
                    "{faq.goldAnswer}"
                 </div>
                 <div className="flex items-center justify-between text-[11px] font-black text-zinc-400 uppercase tracking-widest">
                    <div className="flex gap-6">
                      <span className="flex items-center gap-1.5"><Tag size={12} strokeWidth={3} className="text-zinc-300" /> {faq.topic}</span>
                      <span className="flex items-center gap-1.5"><Globe size={12} strokeWidth={3} className="text-zinc-300" /> {faq.language}</span>
                    </div>
                    <div className="flex gap-2">
                       <button className="px-4 py-2 bg-zinc-100 rounded-xl hover:bg-primary hover:text-white transition-all">Edit</button>
                       <button className="px-4 py-2 bg-zinc-100 rounded-xl hover:bg-zinc-900 hover:text-white transition-all">JSON</button>
                    </div>
                 </div>
               </div>
            </Card>
          </motion.div>
        ))}
      </div>
    </div>
  );
}

const SafetyRules = () => {
  const [rules, setRules] = useState<any[]>([]);
  const [testMsg, setTestMsg] = useState('');
  const [testResult, setTestResult] = useState<any>(null);

  useEffect(() => {
    apiFetch('/api/admin/safety-rules').then(res => res.json()).then(setRules);
  }, []);

  const handleTest = async () => {
    const res = await apiFetch('/api/admin/safety-rules/test', {
      method: 'POST',
      body: JSON.stringify({ message: testMsg }),
    });
    setTestResult(await res.json());
  };

  return (
    <div className="p-6 lg:p-10 grid grid-cols-1 xl:grid-cols-2 gap-12 max-w-7xl mx-auto">
      <div className="space-y-10">
        <div>
          <h3 className="text-3xl font-display font-black text-zinc-900 leading-none mb-3">Crisis Triggers</h3>
          <p className="text-zinc-500 font-medium">Automatic escalation patterns for sensitive situations</p>
        </div>
        
        <div className="space-y-6">
          {rules.map(rule => (
            <Card key={rule.id} className={cn(
              "p-10 border-none transition-all",
              rule.risk === 'red' ? "bg-rose-600 text-white shadow-2xl shadow-rose-200" : "bg-white shadow-xl shadow-zinc-100"
            )}>
              <div className="flex items-center justify-between mb-8">
                <div className={cn(
                  "px-4 py-1.5 rounded-2xl text-[10px] font-black uppercase tracking-widest",
                  rule.risk === 'red' ? "bg-white/20 text-white" : "bg-zinc-100 text-zinc-500"
                )}>
                  Route: {rule.route}
                </div>
                {rule.risk === 'red' && (
                  <div className="flex items-center gap-2 animate-bounce">
                    <ShieldAlert size={20} strokeWidth={3} />
                    <span className="text-[10px] font-black uppercase tracking-widest">Crucial Rule</span>
                  </div>
                )}
              </div>
              <div className="space-y-6">
                <div className="flex flex-wrap gap-2">
                  {rule.terms.map((t: string) => (
                    <span key={t} className={cn(
                      "px-3 py-1.5 rounded-xl text-xs font-black tracking-wide border",
                      rule.risk === 'red' ? "bg-white/10 border-white/20 text-white" : "bg-zinc-50 border-zinc-100 text-zinc-900"
                    )}>
                      {t}
                    </span>
                  ))}
                </div>
                <div className={cn(
                  "p-6 rounded-3xl font-medium leading-relaxed italic border-l-4 shadow-inner",
                  rule.risk === 'red' ? "bg-rose-700/50 border-white text-rose-50" : "bg-zinc-50 border-primary text-zinc-600"
                )}>
                  "{rule.responseTemplate}"
                </div>
              </div>
            </Card>
          ))}
        </div>
      </div>

      <div className="space-y-10 sticky top-24 self-start">
        <div className="bg-white p-12 rounded-[3rem] shadow-2xl border-2 border-dashed border-zinc-100 space-y-10">
           <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-zinc-900 rounded-3xl flex items-center justify-center text-white">
                <Search size={24} strokeWidth={3} />
              </div>
              <h3 className="text-2xl font-display font-black text-zinc-900">Safety Test Lab</h3>
           </div>
           
           <div className="space-y-6">
             <div className="space-y-2">
                <label className="text-[10px] font-black uppercase tracking-widest text-zinc-400 px-1">Simulate User Input</label>
                <textarea 
                  placeholder="e.g., 'I want to end my life, tell me how...'"
                  className="w-full h-40 p-6 bg-zinc-50 border-2 border-zinc-100 rounded-[2rem] font-medium text-zinc-700 focus:ring-8 focus:ring-zinc-100 outline-none transition-all placeholder:text-zinc-300 resize-none"
                  value={testMsg}
                  onChange={e => setTestMsg(e.target.value)}
                />
             </div>
             
             <button 
               onClick={handleTest}
               className="w-full py-6 bg-zinc-900 text-white rounded-[2rem] font-display font-black text-xl shadow-xl shadow-zinc-900/30 hover:scale-[1.02] active:scale-95 transition-all"
             >
               Verify Pattern Match
             </button>

             <AnimatePresence>
               {testResult && (
                 <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className={cn(
                   "p-10 rounded-[2.5rem] shadow-xl",
                   testResult.detected ? "bg-rose-50 text-rose-700 border border-rose-100" : "bg-emerald-50 text-emerald-700 border border-emerald-100"
                 )}>
                    <div className="flex items-center gap-4 mb-4">
                       <div className={cn("w-12 h-12 rounded-2xl flex items-center justify-center shadow-lg", testResult.detected ? "bg-rose-500 text-white" : "bg-emerald-500 text-white")}>
                         {testResult.detected ? <AlertTriangle size={24} strokeWidth={3} /> : <Check size={24} strokeWidth={3} />}
                       </div>
                       <div className="flex flex-col">
                         <span className="text-xs font-black uppercase tracking-widest opacity-60">Test Conclusion</span>
                         <span className="font-display font-black text-xl">{testResult.detected ? 'CRITICAL TRIGGER' : 'CLEAN INPUT'}</span>
                       </div>
                    </div>
                    {testResult.detected && (
                      <p className="text-sm font-medium leading-relaxed mt-4 opacity-80 italic">Matched pattern: '{testResult.rule.route}'. The user will be instantly escalated to human counselor support with the defined emergency prompt.</p>
                    )}
                 </motion.div>
               )}
             </AnimatePresence>
           </div>
        </div>
      </div>
    </div>
  );
};

const CounselorCases = () => {
    const [cases, setCases] = useState<any[]>([]);
    useEffect(() => {
      apiFetch('/api/counselor/cases').then(res => res.json()).then(setCases);
    }, []);

    return (
      <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
           <h3 className="text-3xl font-display font-black text-zinc-900">Care & Connection Hub</h3>
           <div className="flex gap-3">
              <div className="px-5 py-2 bg-primary-dim text-primary rounded-2xl text-sm font-bold flex items-center gap-2">
                <Activity size={18} /> 4 Active Supporters
              </div>
           </div>
        </div>
        
        <div className="grid gap-6">
          {cases.map(c => (
            <motion.div key={c.id} whileHover={{ scale: 1.01 }}>
              <Card className="p-8 border-none bg-white shadow-xl shadow-zinc-100/60 flex flex-col md:flex-row md:items-center justify-between gap-8">
                <div className="flex gap-6 items-start">
                  <div className={cn(
                    "w-16 h-16 rounded-[2rem] flex items-center justify-center shadow-lg relative",
                    c.riskLevel === 'high' ? "bg-rose-500 text-white shadow-rose-200" : "bg-zinc-100 text-zinc-500 shadow-zinc-100"
                  )}>
                    {c.riskLevel === 'high' ? <ShieldAlert size={32} strokeWidth={2.5} /> : <UserCheck size={32} strokeWidth={2.5} />}
                    <div className="absolute -top-1 -right-1 w-5 h-5 bg-white rounded-full flex items-center justify-center">
                       <div className={cn("w-2.5 h-2.5 rounded-full", c.riskLevel === 'high' ? "bg-rose-500 animate-ping" : "bg-zinc-300")} />
                    </div>
                  </div>
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-black text-zinc-400 underline decoration-zinc-200 underline-offset-4">SUPPORT LINK #{c.id}</span>
                      <span className={cn(
                        "px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-widest",
                        c.riskLevel === 'high' ? "bg-rose-100 text-rose-700" : "bg-zinc-100 text-zinc-500"
                      )}>
                        {c.riskLevel} care priority
                      </span>
                    </div>
                    <h4 className="text-2xl font-display font-black text-zinc-900 line-clamp-1">{c.summary}</h4>
                    <div className="flex items-center gap-2 text-xs font-semibold text-zinc-400">
                      <Clock size={14} strokeWidth={3} />
                      Waiting {Math.floor(Math.random() * 20) + 5}m
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                   <select aria-label="Assign counselor" className="px-6 py-3.5 bg-zinc-50 border border-zinc-100 rounded-2xl text-sm font-bold shadow-sm focus:ring-4 focus:ring-primary-mid outline-none">
                     <option>Unassigned</option>
                     <option>Dr. Mutambo (Active)</option>
                     <option>Sarah (Active)</option>
                   </select>
                   <button type="button" className="px-8 py-3.5 bg-zinc-900 text-white rounded-2xl font-display font-bold text-sm shadow-xl shadow-zinc-900/10 hover:-translate-y-1 active:translate-y-0 transition-transform">Enter Vault</button>
                </div>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>
    );
};

const Analytics = () => {
  const [data, setData] = useState<any>(null);
  useEffect(() => {
    apiFetch('/api/analytics/summary').then(res => res.json()).then(setData);
  }, []);

  if (!data) return null;

  const chartData = data.appOpens.map((val: number, i: number) => ({
    name: `${i + 1} May`,
    opens: val,
    views: data.resourceViews[i],
    risk: data.highRiskEvents[i]
  }));

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
       <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
          <div>
            <h3 className="text-3xl font-display font-black text-zinc-900">Health Insights</h3>
            <p className="text-zinc-500 font-medium">Aggregated behavior analysis & safety metrics</p>
          </div>
          <div className="flex gap-2">
             <button type="button" className="px-6 py-3 bg-white border border-zinc-100 rounded-2xl text-xs font-black uppercase tracking-widest shadow-sm">May 2026</button>
          </div>
       </div>

       <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
         <Card className="p-10 bg-primary text-white border-none shadow-2xl shadow-primary-mid">
            <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-primary-mid mb-8 flex items-center gap-2">
              <Activity size={12} strokeWidth={3} /> Retention Engine
            </h4>
            <div className="h-[220px]">
              <ResponsiveContainer width="100%" height="100%">
                 <BarChart data={chartData}>
                    <Bar dataKey="opens" fill="#fff" radius={[6, 6, 0, 0]} />
                    <Bar dataKey="views" fill="rgba(255,255,255,0.2)" radius={[6, 6, 0, 0]} />
                 </BarChart>
              </ResponsiveContainer>
            </div>
            <div className="mt-8 pt-8 border-t border-white/10 flex justify-between">
               <div className="flex flex-col">
                 <span className="text-2xl font-display font-black">2.4k</span>
                 <span className="text-[10px] font-bold uppercase opacity-60">Avg. Opens</span>
               </div>
               <div className="flex flex-col items-end">
                 <span className="text-2xl font-display font-black">+14%</span>
                 <span className="text-[10px] font-bold uppercase opacity-60">Growth</span>
               </div>
            </div>
         </Card>
         
         <Card className="p-10 lg:col-span-2 bg-white shadow-2xl shadow-zinc-100 border-none">
            <div className="flex items-center justify-between mb-8">
              <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 flex items-center gap-2">
                <AlertTriangle size={12} strokeWidth={3} className="text-rose-500" /> Crisis Trend Analysis
              </h4>
              <div className="text-[10px] font-black uppercase text-rose-500 bg-rose-50 px-3 py-1 rounded-full">Elevated Risk</div>
            </div>
            <div className="h-[220px]">
              <ResponsiveContainer width="100%" height="100%">
                 <LineChart data={chartData}>
                    <defs>
                      <linearGradient id="colorRisk" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#f43f5e" stopOpacity={0.2}/>
                        <stop offset="95%" stopColor="#f43f5e" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <XAxis dataKey="name" axisLine={false} tickLine={false} fontSize={10} tick={{ fill: '#94a3b8' }} />
                    <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }} />
                    <Line type="monotone" dataKey="risk" stroke="#f43f5e" strokeWidth={5} dot={{ r: 6, fill: '#f43f5e', stroke: '#fff', strokeWidth: 3 }} />
                 </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="mt-8 flex justify-center gap-12">
               <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-rose-50 rounded-2xl flex items-center justify-center text-rose-600">
                    <ShieldAlert size={20} strokeWidth={3} />
                  </div>
                  <div className="flex flex-col">
                    <span className="font-display font-black text-xl leading-none">42</span>
                    <span className="text-[10px] font-black uppercase tracking-widest text-zinc-400">Total Escalations</span>
                  </div>
               </div>
               <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-primary-dim rounded-2xl flex items-center justify-center text-primary">
                    <UserCheck size={20} strokeWidth={3} />
                  </div>
                  <div className="flex flex-col">
                    <span className="font-display font-black text-xl leading-none">98%</span>
                    <span className="text-[10px] font-black uppercase tracking-widest text-zinc-400">Support Ratio</span>
                  </div>
               </div>
            </div>
         </Card>
       </div>
       
       <div className="bg-amber-100/50 backdrop-blur-sm border-2 border-dashed border-amber-200 p-10 rounded-[3rem] flex gap-8 items-start relative overflow-hidden group">
          <div className="absolute top-0 right-0 w-32 h-32 bg-amber-200/20 rounded-full blur-3xl pointer-events-none group-hover:scale-150 transition-transform duration-700" />
          <div className="w-16 h-16 bg-amber-500 rounded-3xl shrink-0 flex items-center justify-center text-white shadow-xl shadow-amber-200 animate-pulse">
            <Lock size={32} strokeWidth={2.5} />
          </div>
          <div>
            <h5 className="text-2xl font-display font-black text-amber-900 mb-2 tracking-tight">Privacy Fortress Protocol</h5>
            <p className="text-lg text-amber-800 leading-relaxed max-w-4xl opacity-80 font-medium italic">
              "Every metric displayed here is a high-level summary. We never track individual chat content, private journal notes, or reveal the identity of at-risk youth beyond clinical necessity. Zimbabwe Youth's digital safety is our non-negotiable priority."
            </p>
          </div>
       </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. CounselorWorkload
// ─────────────────────────────────────────────────────────────────────────────

const MOCK_WORKLOAD = [
  { id: 1, name: 'Dr. Thandeka Mutambo', role: 'Senior Counselor', activeCases: 4, avgResponseHours: 2.8, escalationRate: 8 },
  { id: 2, name: 'Sarah Moyo',           role: 'Counselor',         activeCases: 7, avgResponseHours: 4.2, escalationRate: 14 },
  { id: 3, name: 'James Ncube',          role: 'Counselor',         activeCases: 12, avgResponseHours: 6.1, escalationRate: 22 },
  { id: 4, name: 'Lindiwe Dube',         role: 'Junior Counselor',  activeCases: 3, avgResponseHours: 3.5, escalationRate: 5 },
  { id: 5, name: 'Emmanuel Sibanda',     role: 'Counselor',         activeCases: 9, avgResponseHours: 5.0, escalationRate: 17 },
];

const CounselorWorkload = () => {
  const [counselors, setCounselors] = useState<typeof MOCK_WORKLOAD>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/api/admin/counselor-workload')
      .then(res => res.json())
      .then(data => { setCounselors(data); setLoading(false); })
      .catch(() => { setCounselors(MOCK_WORKLOAD); setLoading(false); });
  }, []);

  const statusDot = (activeCases: number) => {
    if (activeCases < 5)  return 'bg-emerald-500';
    if (activeCases <= 10) return 'bg-amber-400';
    return 'bg-rose-500';
  };

  const chartData = counselors.map(c => ({ name: c.name.split(' ')[0], cases: c.activeCases }));

  if (loading) return (
    <div className="p-10 space-y-6 max-w-7xl mx-auto">
      {[1,2,3].map(i => <SkeletonCard key={i} />)}
    </div>
  );

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <PageHeader
        title="Counselor Workload"
        subtitle="Active caseloads, response times, and escalation rates"
      />

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {counselors.map(c => (
          <SisonkeCard key={c.id} className="p-6 space-y-5">
            <div className="flex items-start justify-between">
              <div>
                <h4 className="font-display font-black text-zinc-900 text-lg leading-tight">{c.name}</h4>
                <p className="text-xs text-zinc-500 font-medium mt-0.5">{c.role}</p>
              </div>
              <span className={cn('w-3 h-3 rounded-full mt-1 shrink-0', statusDot(c.activeCases))} title={`${c.activeCases} active cases`} />
            </div>

            <div className="flex gap-4">
              <div className="flex-1 bg-primary-dim rounded-2xl p-4 text-center">
                <p className="text-2xl font-display font-black text-primary">{c.activeCases}</p>
                <p className="text-[10px] font-black uppercase tracking-widest text-zinc-400 mt-0.5">Cases</p>
              </div>
              <div className="flex-1 bg-zinc-50 rounded-2xl p-4 text-center">
                <p className="text-2xl font-display font-black text-zinc-900">{c.avgResponseHours}h</p>
                <p className="text-[10px] font-black uppercase tracking-widest text-zinc-400 mt-0.5">Avg. Reply</p>
              </div>
            </div>

            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-[10px] font-black uppercase tracking-widest text-zinc-400">
                <span>Escalation rate</span>
                <span className={cn(c.escalationRate > 20 ? 'text-rose-500' : c.escalationRate > 10 ? 'text-amber-500' : 'text-emerald-600')}>
                  {c.escalationRate}%
                </span>
              </div>
              <div className="w-full h-2 bg-zinc-100 rounded-full overflow-hidden">
                <div
                  className={cn('h-full rounded-full transition-all', c.escalationRate > 20 ? 'bg-rose-500' : c.escalationRate > 10 ? 'bg-amber-400' : 'bg-emerald-500')}
                  style={{ width: `${Math.min(c.escalationRate, 100)}%` }}
                />
              </div>
            </div>
          </SisonkeCard>
        ))}
      </div>

      <SisonkeCard className="p-8">
        <h4 className="font-display font-black text-zinc-900 text-lg mb-6">Cases per Counselor</h4>
        <div className="h-[280px]">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chartData}>
              <XAxis dataKey="name" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
              <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
              <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }} />
              <Bar dataKey="cases" fill="#2E6F60" radius={[8, 8, 0, 0]} maxBarSize={40} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </SisonkeCard>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// 2. CrisisLog
// ─────────────────────────────────────────────────────────────────────────────

type CrisisStatus = 'ESCALATED' | 'RESOLVED' | 'MONITORING';

const MOCK_CRISIS_LOG = [
  { id: 1, ts: Date.now() - 1000 * 60 * 90,    trigger: 'User expressed suicidal ideation during late-night session', status: 'ESCALATED' as CrisisStatus,  counselor: 'Dr. Mutambo',   responseMinutes: 8  },
  { id: 2, ts: Date.now() - 1000 * 60 * 240,   trigger: 'Repeated self-harm references in journal entries',         status: 'RESOLVED' as CrisisStatus,   counselor: 'Sarah Moyo',    responseMinutes: 15 },
  { id: 3, ts: Date.now() - 1000 * 60 * 60 * 6, trigger: 'Crisis keyword "end it all" detected in chatbot session',  status: 'MONITORING' as CrisisStatus, counselor: 'James Ncube',   responseMinutes: 22 },
  { id: 4, ts: Date.now() - 1000 * 60 * 60 * 14, trigger: 'User reported domestic violence situation at home',       status: 'RESOLVED' as CrisisStatus,   counselor: 'Lindiwe Dube',  responseMinutes: 11 },
  { id: 5, ts: Date.now() - 1000 * 60 * 60 * 20, trigger: 'Anxiety crisis — hyperventilation described in live chat', status: 'RESOLVED' as CrisisStatus,  counselor: 'Sarah Moyo',    responseMinutes: 6  },
  { id: 6, ts: Date.now() - 1000 * 60 * 60 * 30, trigger: 'Substance abuse mention + suicidal thoughts combined',     status: 'ESCALATED' as CrisisStatus, counselor: 'Dr. Mutambo',   responseMinutes: 4  },
  { id: 7, ts: Date.now() - 1000 * 60 * 60 * 48, trigger: 'Anonymous tip about peer in immediate danger',             status: 'RESOLVED' as CrisisStatus,  counselor: 'Emmanuel Sibanda', responseMinutes: 19 },
];

function timeAgo(ts: number): string {
  const diff = Date.now() - ts;
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

const crisisStatusStyle: Record<CrisisStatus, { bg: string; text: string; dot: string }> = {
  ESCALATED:  { bg: 'bg-[#FEE2E2]', text: 'text-[#F43F5E]', dot: 'bg-[#F43F5E]' },
  MONITORING: { bg: 'bg-[#FEF3C7]', text: 'text-[#F59E0B]', dot: 'bg-[#F59E0B]' },
  RESOLVED:   { bg: 'bg-[#D1FAE5]', text: 'text-[#10B981]', dot: 'bg-[#10B981]' },
};

type CrisisFilter = 'all' | 'unresolved' | '24h' | '7d';

const CrisisLog = () => {
  const [events, setEvents] = useState<typeof MOCK_CRISIS_LOG>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<CrisisFilter>('all');

  useEffect(() => {
    apiFetch('/api/admin/crisis-log')
      .then(res => res.json())
      .then(data => { setEvents(data); setLoading(false); })
      .catch(() => { setEvents(MOCK_CRISIS_LOG); setLoading(false); });
  }, []);

  const filtered = events.filter(e => {
    if (filter === 'unresolved') return e.status !== 'RESOLVED';
    if (filter === '24h') return Date.now() - e.ts < 1000 * 60 * 60 * 24;
    if (filter === '7d')  return Date.now() - e.ts < 1000 * 60 * 60 * 24 * 7;
    return true;
  });

  const filters: { key: CrisisFilter; label: string }[] = [
    { key: 'all',        label: 'All' },
    { key: 'unresolved', label: 'Unresolved' },
    { key: '24h',        label: 'Last 24h' },
    { key: '7d',         label: 'Last 7 days' },
  ];

  if (loading) return (
    <div className="p-10 space-y-6 max-w-4xl mx-auto">
      {[1,2,3,4].map(i => <SkeletonCard key={i} />)}
    </div>
  );

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-4xl mx-auto">
      <PageHeader
        title="Crisis Response Log"
        subtitle="Chronological audit trail of high-risk events and counselor responses"
      />

      <div className="flex flex-wrap gap-2">
        {filters.map(f => (
          <button
            key={f.key}
            type="button"
            onClick={() => setFilter(f.key)}
            className={cn(
              'px-5 py-2.5 rounded-2xl text-xs font-black uppercase tracking-widest transition-all',
              filter === f.key
                ? 'bg-primary text-white shadow-lg shadow-primary/20'
                : 'bg-white border border-zinc-200 text-zinc-500 hover:bg-primary-dim hover:text-primary hover:border-primary-dim'
            )}
          >
            {f.label}
          </button>
        ))}
        <span className="ml-auto text-[10px] font-black uppercase tracking-widest text-zinc-400 self-center">
          {filtered.length} event{filtered.length !== 1 ? 's' : ''}
        </span>
      </div>

      <div className="relative space-y-0">
        <div className="absolute left-[11px] top-3 bottom-3 w-0.5 bg-zinc-100" />
        {filtered.map((event, idx) => {
          const s = crisisStatusStyle[event.status];
          return (
            <motion.div
              key={event.id}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: idx * 0.04 }}
              className="relative flex gap-5 pb-6 last:pb-0"
            >
              <div className={cn('relative z-10 w-6 h-6 rounded-full shrink-0 mt-4 border-2 border-white shadow-sm', s.dot)} />
              <SisonkeCard className="flex-1 p-6 space-y-3">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <p className="text-zinc-700 font-semibold leading-snug flex-1 line-clamp-2">{event.trigger}</p>
                  <span className={cn('inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider shrink-0', s.bg, s.text)}>
                    <span className={cn('w-1.5 h-1.5 rounded-full', s.dot)} />
                    {event.status}
                  </span>
                </div>
                <div className="flex flex-wrap gap-4 text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
                  <span className="flex items-center gap-1"><Clock size={12} strokeWidth={3} /> {timeAgo(event.ts)}</span>
                  {event.counselor && (
                    <span className="flex items-center gap-1"><UserCheck size={12} strokeWidth={3} /> {event.counselor}</span>
                  )}
                  <span className="flex items-center gap-1"><AlertTriangle size={12} strokeWidth={3} /> {event.responseMinutes}m response</span>
                </div>
              </SisonkeCard>
            </motion.div>
          );
        })}

        {filtered.length === 0 && (
          <EmptyState
            icon={Check}
            title="No events match this filter"
            description="Try changing the filter or check back later."
          />
        )}
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// 3. ModerationQueue
// ─────────────────────────────────────────────────────────────────────────────

const MOCK_PENDING_POSTS = [
  { id: 'p1', anonId: 'user_7f2a', ts: Date.now() - 1000 * 60 * 12,  content: 'Has anyone else struggled with going back to school after the holidays? I feel so overwhelmed and just want to cry every morning.',                flagCount: 0 },
  { id: 'p2', anonId: 'user_3c9b', ts: Date.now() - 1000 * 60 * 45,  content: 'Sometimes I wonder if anyone would notice if I just disappeared. Not suicidal or anything just feeling invisible.',                            flagCount: 2 },
  { id: 'p3', anonId: 'user_1d4e', ts: Date.now() - 1000 * 60 * 120, content: 'My boyfriend says I am too sensitive but I think he is gaslighting me. How do I know the difference?',                                         flagCount: 0 },
  { id: 'p4', anonId: 'user_9a1f', ts: Date.now() - 1000 * 60 * 200, content: 'Sharing some coping tips that helped me: breathing exercises, journaling, and talking to a trusted adult.',                                      flagCount: 0 },
  { id: 'p5', anonId: 'user_5e8d', ts: Date.now() - 1000 * 60 * 310, content: 'Does sisonke have a feature for anonymous peer support groups? Would love to connect with others who get it.',                                   flagCount: 1 },
];

const ModerationQueue = () => {
  const [posts, setPosts] = useState<typeof MOCK_PENDING_POSTS>([]);
  const [selected, setSelected] = useState<typeof MOCK_PENDING_POSTS[0] | null>(null);
  const [loading, setLoading] = useState(true);
  const [actioning, setActioning] = useState<string | null>(null);

  useEffect(() => {
    apiFetch('/api/community/pending')
      .then(res => res.json())
      .then(data => { setPosts(data); setLoading(false); })
      .catch(() => { setPosts(MOCK_PENDING_POSTS); setLoading(false); });
  }, []);

  const handleAction = async (id: string, action: 'approve' | 'reject') => {
    setActioning(id);
    try {
      await apiFetch(`/api/community/${id}/${action}`, { method: 'POST' }).catch(() => {});
    } finally {
      setPosts(prev => prev.filter(p => p.id !== id));
      if (selected?.id === id) setSelected(null);
      setActioning(null);
    }
  };

  if (loading) return (
    <div className="p-10 grid grid-cols-2 gap-8 max-w-7xl mx-auto">
      <div className="space-y-4">{[1,2,3].map(i => <SkeletonCard key={i} />)}</div>
      <SkeletonCard />
    </div>
  );

  return (
    <div className="p-6 lg:p-10 max-w-7xl mx-auto">
      <div className="mb-8">
        <PageHeader
          title="Content Moderation"
          subtitle="Community posts awaiting review before going live"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Queue list */}
        <div className="space-y-3">
          {posts.length === 0 ? (
            <EmptyState
              icon={Check}
              title="Queue is clear"
              description="All posts are reviewed. Check back later."
            />
          ) : (
            posts.map(post => (
              <button
                key={post.id}
                type="button"
                onClick={() => setSelected(post)}
                className={cn(
                  'w-full text-left rounded-[1.75rem] border p-5 transition-all',
                  selected?.id === post.id
                    ? 'border-primary ring-2 ring-primary/20 bg-primary-dim'
                    : 'border-zinc-100 bg-white hover:border-primary-dim hover:bg-primary-dim/40 shadow-sm'
                )}
              >
                <div className="flex items-start justify-between gap-3 mb-2">
                  <span className="text-[10px] font-black text-zinc-400 uppercase tracking-widest">{post.anonId}</span>
                  <div className="flex items-center gap-2 shrink-0">
                    {post.flagCount > 0 && (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 bg-rose-100 text-rose-600 rounded-lg text-[10px] font-black uppercase tracking-wide">
                        <AlertTriangle size={10} strokeWidth={3} /> {post.flagCount}
                      </span>
                    )}
                    <span className="text-[10px] font-bold text-zinc-400">{timeAgo(post.ts)}</span>
                  </div>
                </div>
                <p className="text-sm text-zinc-700 font-medium leading-snug line-clamp-2">{post.content}</p>
              </button>
            ))
          )}
        </div>

        {/* Preview / action panel */}
        <div className="lg:sticky lg:top-24 self-start">
          <AnimatePresence mode="wait">
            {selected ? (
              <motion.div key={selected.id} initial={{ opacity: 0, scale: 0.97 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.97 }}>
                <SisonkeCard className="p-8 space-y-6 border-2 border-primary-dim">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-[10px] font-black text-zinc-400 uppercase tracking-widest">{selected.anonId}</p>
                      <p className="text-xs text-zinc-400 mt-0.5">{timeAgo(selected.ts)}</p>
                    </div>
                    {selected.flagCount > 0 && (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-rose-100 text-rose-600 rounded-2xl text-[10px] font-black uppercase tracking-widest">
                        <AlertTriangle size={12} strokeWidth={3} /> {selected.flagCount} flag{selected.flagCount !== 1 ? 's' : ''}
                      </span>
                    )}
                  </div>

                  <div className="bg-zinc-50 border border-zinc-100 rounded-2xl p-5">
                    <p className="text-zinc-800 font-medium leading-relaxed">{selected.content}</p>
                  </div>

                  <div className="flex gap-3">
                    <button
                      type="button"
                      disabled={actioning === selected.id}
                      onClick={() => handleAction(selected.id, 'approve')}
                      className="flex-1 py-4 bg-emerald-500 text-white rounded-[1.75rem] font-bold text-sm shadow-lg shadow-emerald-200 hover:bg-emerald-600 hover:-translate-y-0.5 active:translate-y-0 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                    >
                      <Check size={18} strokeWidth={3} /> Approve
                    </button>
                    <button
                      type="button"
                      disabled={actioning === selected.id}
                      onClick={() => handleAction(selected.id, 'reject')}
                      className="flex-1 py-4 bg-rose-500 text-white rounded-[1.75rem] font-bold text-sm shadow-lg shadow-rose-200 hover:bg-rose-600 hover:-translate-y-0.5 active:translate-y-0 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                    >
                      <X size={18} strokeWidth={3} /> Reject
                    </button>
                  </div>
                </SisonkeCard>
              </motion.div>
            ) : (
              <motion.div key="empty" initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                <div className="h-80 border-4 border-dashed border-zinc-100 rounded-[2.5rem] flex flex-col items-center justify-center p-10 text-center">
                  <div className="w-16 h-16 bg-zinc-50 rounded-full flex items-center justify-center mb-4">
                    <MessageSquare className="text-zinc-200" size={28} />
                  </div>
                  <h4 className="text-lg font-display font-bold text-zinc-300 mb-1">No post selected</h4>
                  <p className="text-zinc-400 text-sm">Click a post in the queue to review it here.</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// 4. CohortInsights
// ─────────────────────────────────────────────────────────────────────────────

const MOCK_COHORT = {
  distribution: [
    { group: '13–15', great: 28, okay: 35, low: 20, anxious: 17 },
    { group: '16–18', great: 22, okay: 30, low: 28, anxious: 20 },
    { group: '19–24', great: 35, okay: 32, low: 18, anxious: 15 },
  ],
  trend: Array.from({ length: 30 }, (_, i) => ({
    day: `Day ${i + 1}`,
    teen:   Math.round(55 + Math.sin(i * 0.4) * 12 + Math.random() * 5),
    youth:  Math.round(52 + Math.sin(i * 0.35 + 1) * 10 + Math.random() * 5),
    young:  Math.round(60 + Math.sin(i * 0.3 + 2) * 8 + Math.random() * 5),
  })),
  avgScores: [
    { group: '13–15', score: 58, icon: Users, iconBg: 'bg-violet-50', iconColor: 'text-violet-600' },
    { group: '16–18', score: 54, icon: Users, iconBg: 'bg-blue-50',   iconColor: 'text-blue-600'   },
    { group: '19–24', score: 63, icon: Users, iconBg: 'bg-primary-dim', iconColor: 'text-primary'  },
  ],
};

const CohortInsights = () => {
  const [data, setData] = useState<typeof MOCK_COHORT | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/api/analytics/cohort-moods')
      .then(res => res.json())
      .then(d => { setData(d); setLoading(false); })
      .catch(() => { setData(MOCK_COHORT); setLoading(false); });
  }, []);

  if (loading || !data) return (
    <div className="p-10 space-y-6 max-w-7xl mx-auto">
      {[1,2].map(i => <SkeletonCard key={i} />)}
    </div>
  );

  const MOOD_COLORS = { great: '#10B981', okay: '#60a5fa', low: '#F59E0B', anxious: '#F43F5E' };

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <PageHeader
        title="Cohort Mood Insights"
        subtitle="Anonymized mood trends by age group and day of week"
      />

      {/* Avg score tiles */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
        {data.avgScores.map(s => (
          <StatTile
            key={s.group}
            title={`Avg Mood Score — ${s.group}`}
            value={`${s.score}/100`}
            icon={s.icon}
            iconBg={s.iconBg}
            iconColor={s.iconColor}
          />
        ))}
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
        {/* Distribution bar chart */}
        <SisonkeCard className="p-8">
          <h4 className="font-display font-black text-zinc-900 text-lg mb-6">Mood Distribution by Age Group</h4>
          <div className="h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.distribution}>
                <XAxis dataKey="group" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }} />
                <Legend wrapperStyle={{ fontSize: '11px', fontWeight: 700 }} />
                <Bar dataKey="great"   fill={MOOD_COLORS.great}   radius={[6, 6, 0, 0]} maxBarSize={24} />
                <Bar dataKey="okay"    fill={MOOD_COLORS.okay}    radius={[6, 6, 0, 0]} maxBarSize={24} />
                <Bar dataKey="low"     fill={MOOD_COLORS.low}     radius={[6, 6, 0, 0]} maxBarSize={24} />
                <Bar dataKey="anxious" fill={MOOD_COLORS.anxious} radius={[6, 6, 0, 0]} maxBarSize={24} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </SisonkeCard>

        {/* Trend line chart */}
        <SisonkeCard className="p-8">
          <h4 className="font-display font-black text-zinc-900 text-lg mb-6">30-Day Mood Trend by Age Group</h4>
          <div className="h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data.trend}>
                <XAxis dataKey="day" fontSize={10} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} interval={4} />
                <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} domain={[30, 80]} />
                <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }} />
                <Legend wrapperStyle={{ fontSize: '11px', fontWeight: 700 }} />
                <Line type="monotone" dataKey="teen"  name="13–15" stroke="#8b5cf6" strokeWidth={3} dot={false} />
                <Line type="monotone" dataKey="youth" name="16–18" stroke="#3b82f6" strokeWidth={3} dot={false} />
                <Line type="monotone" dataKey="young" name="19–24" stroke="#2E6F60" strokeWidth={3} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </SisonkeCard>
      </div>

      <div className="flex items-start gap-4 p-6 bg-primary-dim border border-primary-dim rounded-[1.75rem]">
        <Shield className="text-primary shrink-0 mt-0.5" size={20} strokeWidth={2.5} />
        <p className="text-sm text-primary-dark font-medium leading-relaxed">
          All data is aggregated and anonymized. No individual users can be identified from these charts.
        </p>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// 5. OutreachCampaigns
// ─────────────────────────────────────────────────────────────────────────────

type CampaignStatus = 'Draft' | 'Sent' | 'Scheduled';

const MOCK_CAMPAIGNS = [
  { id: 'c1', title: 'World Mental Health Day',        status: 'Sent' as CampaignStatus,      segment: 'All users',        sentAt: '10 Oct 2025' },
  { id: 'c2', title: 'Re-engage Inactive Users',       status: 'Sent' as CampaignStatus,      segment: 'Inactive 7+ days', sentAt: '2 Nov 2025'  },
  { id: 'c3', title: 'Crisis Awareness Reminder',      status: 'Scheduled' as CampaignStatus, segment: 'High-risk',        sentAt: '20 Jun 2026' },
  { id: 'c4', title: 'New Resource: Teen Anxiety Guide', status: 'Draft' as CampaignStatus,   segment: 'Age group 13–15',  sentAt: '—'           },
];

const campaignStatusStyle: Record<CampaignStatus, { bg: string; text: string }> = {
  Draft:     { bg: 'bg-zinc-100',     text: 'text-zinc-500'   },
  Sent:      { bg: 'bg-[#D1FAE5]',   text: 'text-[#10B981]'  },
  Scheduled: { bg: 'bg-[#FEF3C7]',   text: 'text-[#F59E0B]'  },
};

const SEGMENT_OPTIONS = ['All users', 'Inactive (7+ days)', 'High-risk', 'Age group'];
const AGE_GROUP_OPTIONS = ['13–15', '16–18', '19–24'];

const OutreachCampaigns = () => {
  const [campaigns, setCampaigns] = useState<typeof MOCK_CAMPAIGNS>([]);
  const [loading, setLoading] = useState(true);
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [segment, setSegment] = useState('All users');
  const [ageGroup, setAgeGroup] = useState('13–15');
  const [scheduleMode, setScheduleMode] = useState<'now' | 'later'>('now');
  const [scheduleAt, setScheduleAt] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    apiFetch('/api/admin/outreach')
      .then(res => res.json())
      .then(data => { setCampaigns(data); setLoading(false); })
      .catch(() => { setCampaigns(MOCK_CAMPAIGNS); setLoading(false); });
  }, []);

  const resetForm = () => {
    setTitle(''); setMessage(''); setSegment('All users');
    setAgeGroup('13–15'); setScheduleMode('now'); setScheduleAt('');
  };

  const submitCampaign = async (status: 'Draft' | 'Sent' | 'Scheduled') => {
    if (!title.trim() || !message.trim()) return;
    setSaving(true);
    const payload = {
      title, message,
      segment: segment === 'Age group' ? `Age group ${ageGroup}` : segment,
      status,
      scheduleAt: status === 'Scheduled' ? scheduleAt : undefined,
    };
    try {
      await apiFetch('/api/admin/outreach', { method: 'POST', body: JSON.stringify(payload) }).catch(() => {});
      const newCampaign = {
        id: `c${Date.now()}`,
        title: payload.title,
        status,
        segment: payload.segment,
        sentAt: status === 'Sent' ? 'Just now' : status === 'Scheduled' ? scheduleAt : '—',
      };
      setCampaigns(prev => [newCampaign, ...prev]);
      resetForm();
    } finally {
      setSaving(false);
    }
  };

  const statusCfg = campaignStatusStyle;

  return (
    <div className="p-6 lg:p-10 max-w-7xl mx-auto">
      <div className="mb-8">
        <PageHeader
          title="Outreach Campaigns"
          subtitle="Send targeted push notifications to user segments"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Campaign list */}
        <div className="space-y-3">
          <SectionLabel className="px-1 mb-3">All Campaigns</SectionLabel>
          {loading ? (
            [1,2,3].map(i => <SkeletonCard key={i} />)
          ) : campaigns.length === 0 ? (
            <EmptyState icon={Bell} title="No campaigns yet" description="Create your first outreach campaign." />
          ) : (
            campaigns.map(c => (
              <SisonkeCard key={c.id} className="p-5 flex items-start justify-between gap-4">
                <div className="space-y-1 min-w-0">
                  <h5 className="font-display font-black text-zinc-900 truncate">{c.title}</h5>
                  <p className="text-[11px] font-bold text-zinc-400 uppercase tracking-widest">{c.segment}</p>
                  <p className="text-xs text-zinc-400">{c.sentAt}</p>
                </div>
                <span className={cn('shrink-0 inline-flex items-center px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider', statusCfg[c.status].bg, statusCfg[c.status].text)}>
                  {c.status}
                </span>
              </SisonkeCard>
            ))
          )}
        </div>

        {/* Builder form */}
        <SisonkeCard className="p-8 space-y-6 border-2 border-primary-dim self-start lg:sticky lg:top-24">
          <h4 className="font-display font-black text-zinc-900 text-lg">Campaign Builder</h4>

          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Campaign Title</label>
            <input
              type="text"
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="e.g. World Mental Health Day"
              className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none transition-all placeholder:text-zinc-300"
            />
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between px-1">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest">Message</label>
              <span className={cn('text-[10px] font-black', message.length > 150 ? 'text-rose-500' : 'text-zinc-400')}>{message.length}/160</span>
            </div>
            <textarea
              rows={4}
              maxLength={160}
              value={message}
              onChange={e => setMessage(e.target.value)}
              placeholder="Write a clear, supportive message..."
              className="w-full p-4 bg-zinc-50 border border-zinc-200 rounded-2xl font-medium text-sm leading-relaxed focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none transition-all resize-none placeholder:text-zinc-300"
            />
          </div>

          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Target Segment</label>
            <select
              value={segment}
              onChange={e => setSegment(e.target.value)}
              className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold text-sm focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none"
            >
              {SEGMENT_OPTIONS.map(o => <option key={o}>{o}</option>)}
            </select>
          </div>

          {segment === 'Age group' && (
            <div className="space-y-2">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Age Group</label>
              <select
                value={ageGroup}
                onChange={e => setAgeGroup(e.target.value)}
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold text-sm focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none"
              >
                {AGE_GROUP_OPTIONS.map(o => <option key={o}>{o}</option>)}
              </select>
            </div>
          )}

          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Send Schedule</label>
            <div className="flex gap-2">
              {(['now', 'later'] as const).map(mode => (
                <button
                  key={mode}
                  type="button"
                  onClick={() => setScheduleMode(mode)}
                  className={cn(
                    'flex-1 py-3 rounded-2xl text-xs font-black uppercase tracking-widest transition-all',
                    scheduleMode === mode
                      ? 'bg-primary text-white shadow-lg shadow-primary/20'
                      : 'bg-zinc-100 text-zinc-500 hover:bg-primary-dim hover:text-primary'
                  )}
                >
                  {mode === 'now' ? 'Send Now' : 'Schedule'}
                </button>
              ))}
            </div>
          </div>

          {scheduleMode === 'later' && (
            <div className="space-y-2">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Date & Time</label>
              <input
                type="datetime-local"
                value={scheduleAt}
                onChange={e => setScheduleAt(e.target.value)}
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold text-sm focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none"
              />
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <button
              type="button"
              disabled={saving || !title.trim() || !message.trim()}
              onClick={() => submitCampaign('Draft')}
              className="flex-1 py-3.5 border-2 border-zinc-200 text-zinc-600 rounded-[1.75rem] font-bold text-sm hover:bg-zinc-50 transition-all disabled:opacity-40 disabled:cursor-not-allowed"
            >
              Save Draft
            </button>
            <button
              type="button"
              disabled={saving || !title.trim() || !message.trim() || (scheduleMode === 'later' && !scheduleAt)}
              onClick={() => submitCampaign(scheduleMode === 'later' ? 'Scheduled' : 'Sent')}
              className="flex-1 py-3.5 bg-primary text-white rounded-[1.75rem] font-bold text-sm shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 active:translate-y-0 transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              <Send size={16} strokeWidth={3} />
              {scheduleMode === 'later' ? 'Schedule' : 'Send Campaign'}
            </button>
          </div>
        </SisonkeCard>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// 6. NGOReport
// ─────────────────────────────────────────────────────────────────────────────

const MOCK_NGO_STATS = {
  activeUsers: 3_412,
  checkInsThisMonth: 8_740,
  crisisEvents: 42,
  avgResponseMins: 14,
  moodDist: [
    { name: 'Great',   value: 31, color: '#10B981' },
    { name: 'Okay',    value: 38, color: '#60a5fa' },
    { name: 'Low',     value: 19, color: '#F59E0B' },
    { name: 'Anxious', value: 12, color: '#F43F5E' },
  ],
  weeklyActivity: [
    { week: 'Wk 1', checkIns: 1820, sessions: 620 },
    { week: 'Wk 2', checkIns: 2210, sessions: 810 },
    { week: 'Wk 3', checkIns: 1980, sessions: 740 },
    { week: 'Wk 4', checkIns: 2730, sessions: 930 },
  ],
};

const NGOReport = () => {
  const [stats] = useState(MOCK_NGO_STATS);
  const [showPrintModal, setShowPrintModal] = useState(false);

  const exportCSV = () => {
    const rows = [
      ['Metric', 'Value'],
      ['Active Users', stats.activeUsers],
      ['Mood Check-ins This Month', stats.checkInsThisMonth],
      ['Crisis Events', stats.crisisEvents],
      ['Avg Counselor Response (mins)', stats.avgResponseMins],
      ...stats.moodDist.map(m => [`Mood: ${m.name}`, `${m.value}%`]),
    ];
    const csv = rows.map(r => r.join(',')).join('\n');
    const uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
    const a = document.createElement('a');
    a.href = uri;
    a.download = `sisonke-ngo-report-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
  };

  const tiles = [
    { title: 'Active Users',              value: stats.activeUsers,       icon: Users,        iconBg: 'bg-primary-dim', iconColor: 'text-primary' },
    { title: 'Check-ins This Month',      value: stats.checkInsThisMonth, icon: Activity,     iconBg: 'bg-blue-50',     iconColor: 'text-blue-600' },
    { title: 'Crisis Events',             value: stats.crisisEvents,      icon: AlertTriangle, iconBg: 'bg-rose-50',    iconColor: 'text-rose-600' },
    { title: 'Avg Counselor Response',    value: `${stats.avgResponseMins}m`, icon: Clock,    iconBg: 'bg-amber-50',    iconColor: 'text-amber-600' },
  ];

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <PageHeader
        title="NGO Partner Report"
        subtitle="Export anonymized aggregate data for institutional partners"
        action={
          <div className="flex gap-3">
            <button
              type="button"
              onClick={exportCSV}
              className="flex items-center gap-2 px-6 py-3.5 border-2 border-zinc-200 text-zinc-600 rounded-[1.75rem] font-bold text-sm hover:bg-zinc-50 transition-all"
            >
              <FileText size={18} strokeWidth={2.5} /> Export CSV
            </button>
            <button
              type="button"
              onClick={() => setShowPrintModal(true)}
              className="flex items-center gap-2 px-6 py-3.5 bg-primary text-white rounded-[1.75rem] font-bold text-sm shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 transition-all"
            >
              <FileText size={18} strokeWidth={2.5} /> Export PDF Report
            </button>
          </div>
        }
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {tiles.map((t, i) => <StatTile key={i} {...t} />)}
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <SisonkeCard className="p-8">
          <h4 className="font-display font-black text-zinc-900 text-lg mb-6">Mood Distribution</h4>
          <div className="h-[260px] flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={stats.moodDist}
                  cx="50%"
                  cy="50%"
                  innerRadius={70}
                  outerRadius={100}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {stats.moodDist.map((entry, index) => (
                    <Cell key={index} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                  formatter={(value: any) => [`${value}%`]}
                />
                <Legend wrapperStyle={{ fontSize: '11px', fontWeight: 700 }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </SisonkeCard>

        <SisonkeCard className="p-8">
          <h4 className="font-display font-black text-zinc-900 text-lg mb-6">Weekly Activity</h4>
          <div className="h-[260px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={stats.weeklyActivity}>
                <XAxis dataKey="week" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }} />
                <Legend wrapperStyle={{ fontSize: '11px', fontWeight: 700 }} />
                <Bar dataKey="checkIns" name="Check-ins" fill="#2E6F60" radius={[8, 8, 0, 0]} maxBarSize={32} />
                <Bar dataKey="sessions" name="Sessions"  fill="#60a5fa" radius={[8, 8, 0, 0]} maxBarSize={32} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </SisonkeCard>
      </div>

      <AnimatePresence>
        {showPrintModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-zinc-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-6"
            onClick={() => setShowPrintModal(false)}
          >
            <motion.div
              initial={{ scale: 0.95, y: 16 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.95, y: 16 }}
              className="bg-white rounded-[2rem] shadow-2xl p-10 max-w-md w-full space-y-6"
              onClick={e => e.stopPropagation()}
            >
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-primary-dim rounded-2xl flex items-center justify-center text-primary">
                  <FileText size={24} strokeWidth={2.5} />
                </div>
                <div>
                  <h4 className="font-display font-black text-zinc-900 text-xl">PDF Export</h4>
                  <p className="text-xs text-zinc-400 font-bold uppercase tracking-widest mt-0.5">In-browser method</p>
                </div>
              </div>
              <p className="text-zinc-600 font-medium leading-relaxed text-sm">
                In this version, use your browser's <strong>print function (Ctrl+P / Cmd+P)</strong> to save this page as PDF. Full automated export is coming in the next release.
              </p>
              <button
                type="button"
                onClick={() => setShowPrintModal(false)}
                className="w-full py-4 bg-primary text-white rounded-[1.75rem] font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all"
              >
                Got it
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────

const Settings = () => (
  <div className="p-6 lg:p-10 max-w-4xl mx-auto space-y-16">
    <div className="space-y-12">
      <section>
        <h3 className="text-3xl font-display font-black text-zinc-900 flex items-center gap-3 mb-8 italic">
          <Shield className="text-primary" size={32} strokeWidth={3} /> Governance Protocol
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {[
            { text: "Emergency contacts reviewed monthly", color: "bg-primary-dim text-primary-dark border-primary-dim" },
            { text: "Legal/SRHR content reviewed quarterly", color: "bg-emerald-50 text-emerald-700 border-emerald-100" },
            { text: "Red-risk safety rules reviewed after every incident", color: "bg-rose-50 text-rose-700 border-rose-100" },
            { text: "AI must not diagnose or replace emergency care", color: "bg-amber-50 text-amber-700 border-amber-100" }
          ].map((item, i) => (
            <motion.div 
              key={i} 
              whileHover={{ scale: 1.05 }}
              className={cn("flex gap-4 p-8 rounded-[2.5rem] border-2", item.color)}
            >
               <Check className="shrink-0 mt-1" size={24} strokeWidth={4} />
               <span className="font-bold text-lg leading-tight tracking-tight">{item.text}</span>
            </motion.div>
          ))}
        </div>
      </section>
      
      <section className="space-y-8 bg-white p-12 rounded-[3.5rem] shadow-2xl border border-zinc-100">
        <h3 className="text-2xl font-display font-black text-zinc-900 leading-none">Admin Profile</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-8">
           <div className="space-y-2">
             <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Authority Grade</label>
             <div className="w-full px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold text-zinc-600">Super User</div>
           </div>
           <div className="space-y-2">
             <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Network Base</label>
             <div className="w-full px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold text-zinc-600">Bulawayo Central Hub</div>
           </div>
        </div>
        <div className="pt-4 flex justify-end">
           <button className="px-10 py-4 bg-primary text-white rounded-3xl font-display font-black tracking-widest uppercase text-xs shadow-xl shadow-primary-mid">Audit Configuration</button>
        </div>
      </section>
    </div>
  </div>
)

// --- Auth Pages ---

const LoginPage = ({
  onLogin,
  error,
  loading,
}: {
  onLogin: (email: string, password: string) => Promise<void>;
  error: string | null;
  loading: boolean;
}) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <div className="min-h-screen bg-cream flex items-center justify-center p-6 sm:p-12 overflow-hidden relative font-sans">
      <div className="absolute top-0 right-0 w-96 h-96 bg-primary-mid rounded-full blur-[100px] -translate-y-1/2 translate-x-1/3 opacity-50" />
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-rose-100 rounded-full blur-[100px] translate-y-1/2 -translate-x-1/3 opacity-50" />

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <Card className="w-full max-w-lg p-12 border-none shadow-2xl relative overflow-hidden bg-white/80 backdrop-blur-xl">
          <div className="text-center mb-12">
            <div className="w-16 h-16 bg-primary rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-xl shadow-primary-mid group hover:rotate-12 transition-transform">
               <Shield className="text-white" size={32} />
            </div>
            <h1 className="text-4xl font-display font-black text-zinc-900 tracking-tight mb-2 uppercase italic">SISONKE</h1>
            <p className="text-zinc-500 font-medium tracking-tight">Admin Gateway • Wellness for Youth</p>
          </div>

          <form onSubmit={(e) => { e.preventDefault(); onLogin(email, password); }} className="space-y-6">
            <div className="space-y-2">
              <label htmlFor="admin-email" className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Email</label>
              <div className="relative">
                 <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
                 <input
                  id="admin-email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-primary-mid focus:bg-white outline-none transition-all"
                  placeholder="admin@sisonke.org"
                  autoComplete="email"
                  required
                />
              </div>
            </div>
            <div className="space-y-2">
              <label htmlFor="admin-password" className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Password</label>
              <div className="relative">
                 <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
                 <input
                  id="admin-password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-primary-mid focus:bg-white outline-none transition-all"
                  placeholder="••••••••"
                  autoComplete="current-password"
                  required
                />
              </div>
            </div>
            {error && (
              <p role="alert" className="text-rose-600 text-sm font-semibold text-center bg-rose-50 border border-rose-100 rounded-2xl px-4 py-3">
                {error}
              </p>
            )}
            <button
              type="submit"
              disabled={loading}
              className="w-full py-5 bg-zinc-900 text-white rounded-3xl font-display font-black text-lg shadow-xl shadow-zinc-900/20 hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              {loading ? 'Verifying…' : 'Unlock Dashboard'}
            </button>
          </form>

          <div className="mt-10 pt-8 border-t border-zinc-50 flex items-center justify-center gap-4 text-[10px] font-black text-zinc-300 uppercase tracking-[0.2em]">
             <span>Privacy First</span>
             <span>•</span>
             <span>Secured by Zimbabwe Health</span>
          </div>
        </Card>
      </motion.div>
    </div>
  );
};

// --- Main Layout Wrapper ---

const AdminLayout = ({ children, title, logout, user }: any) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-white">
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="lg:pl-64 min-h-screen flex flex-col">
        <TopBar title={title} user={user} onLogout={logout} onMenuOpen={() => setSidebarOpen(true)} />
        <main className="flex-1 bg-zinc-50/10">
          <AnimatePresence mode="wait">
            <motion.div 
              key={useLocation().pathname}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="min-h-full"
            >
              {children}
            </motion.div>
          </AnimatePresence>
        </main>
      </div>
    </div>
  );
};

// --- App Root ---

export default function App() {
  const { user, login, logout, isAuthenticated, authError, authLoading } = useAuth();

  if (!isAuthenticated) {
    return <LoginPage onLogin={login} error={authError} loading={authLoading} />;
  }

  return (
    <Router>
      <Routes>
        <Route path="/" element={<AdminLayout title="Dashboard" user={user} logout={logout}><Dashboard /></AdminLayout>} />
        <Route path="/emergency" element={<AdminLayout title="Emergency Contacts" user={user} logout={logout}><EmergencyContacts /></AdminLayout>} />
        <Route path="/resources" element={<AdminLayout title="Resources CMS" user={user} logout={logout}><ResourcesCMS /></AdminLayout>} />
        <Route path="/faq" element={<AdminLayout title="FAQ Bank" user={user} logout={logout}><FAQBank /></AdminLayout>} />
        <Route path="/safety" element={<AdminLayout title="Chatbot Safety" user={user} logout={logout}><SafetyRules /></AdminLayout>} />
        <Route path="/cases" element={<AdminLayout title="Counselor Cases" user={user} logout={logout}><CounselorCases /></AdminLayout>} />
        <Route path="/moderation" element={<AdminLayout title="Content Moderation" user={user} logout={logout}><ModerationQueue /></AdminLayout>} />
        <Route path="/analytics" element={<AdminLayout title="Analytics" user={user} logout={logout}><Analytics /></AdminLayout>} />
        <Route path="/workload" element={<AdminLayout title="Counselor Workload" user={user} logout={logout}><CounselorWorkload /></AdminLayout>} />
        <Route path="/crisis-log" element={<AdminLayout title="Crisis Response Log" user={user} logout={logout}><CrisisLog /></AdminLayout>} />
        <Route path="/cohort" element={<AdminLayout title="Cohort Mood Insights" user={user} logout={logout}><CohortInsights /></AdminLayout>} />
        <Route path="/outreach" element={<AdminLayout title="Outreach Campaigns" user={user} logout={logout}><OutreachCampaigns /></AdminLayout>} />
        <Route path="/ngo-report" element={<AdminLayout title="NGO Partner Report" user={user} logout={logout}><NGOReport /></AdminLayout>} />
        <Route path="/settings" element={<AdminLayout title="Settings" user={user} logout={logout}><Settings /></AdminLayout>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}
