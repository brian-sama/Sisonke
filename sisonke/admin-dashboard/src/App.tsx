import React, { useState, useEffect } from 'react';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  LineChart, Line, PieChart, Pie, Cell
} from 'recharts';
import { 
  Users, MessageSquare, AlertTriangle, Clock, BookOpen, 
  ShieldAlert, Phone, HelpCircle, UserCheck, Shield,
  Settings as SettingsIcon, LogOut, Menu, X, Search,
  Plus, Edit2, Trash2, Check, ExternalLink, Filter, ChevronRight,
  Tag, Globe, PieChart as PieChartIcon, Activity, Lock, Mail
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

// --- Utils ---
function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// --- API/Auth helpers ---
const tokenKey = 'sisonke_admin_token';
const userKey = 'sisonke_admin_user';

async function apiFetch(path: string, options: RequestInit = {}) {
  const token = localStorage.getItem(tokenKey);
  const response = await fetch(path, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {}),
    },
  });
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(payload.error || `Request failed: ${response.status}`);
  }
  return payload.data ?? payload;
}

// --- Auth Context ---
const useAuth = () => {
  const [user, setUser] = useState<{ email: string; mustChangePassword?: boolean } | null>(() => {
    const saved = localStorage.getItem(userKey);
    return saved ? JSON.parse(saved) : null;
  });

  const login = async (email: string, password: string) => {
    const data = await apiFetch('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email: email.trim().toLowerCase(), password }),
    });
    const roles = (data.user?.roles?.length ? data.user.roles : [data.user?.role])
      .map((r: any) => String(r || '').toLowerCase().replace(/_/g, '-'));
    const allowedRoles = ['admin', 'super-admin', 'system-admin', 'counselor', 'moderator', 'content-admin'];
    if (!roles.some((r: string) => allowedRoles.includes(r))) {
      throw new Error('This account does not have dashboard access.');
    }

    const u = { email: data.user.email || email, mustChangePassword: Boolean(data.user.mustChangePassword) };
    setUser(u);
    localStorage.setItem(userKey, JSON.stringify(u));
    localStorage.setItem(tokenKey, data.token);
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem(userKey);
    localStorage.removeItem(tokenKey);
  };

  const finishPasswordChange = () => {
    if (!user) return;
    const updated = { ...user, mustChangePassword: false };
    setUser(updated);
    localStorage.setItem(userKey, JSON.stringify(updated));
  };

  return { user, login, logout, finishPasswordChange, isAuthenticated: !!user };
};

// --- Components ---

const Sidebar = ({ isOpen, onClose }: { isOpen: boolean, onClose: () => void }) => {
  const location = useLocation();
  
  const navGroups = [
    {
      label: 'Main',
      items: [
        { name: 'Home', path: '/', icon: BarChart },
        { name: 'Reports', path: '/analytics', icon: Activity },
      ]
    },
    {
      label: 'Safety',
      items: [
        { name: 'Help Contacts', path: '/emergency', icon: Phone },
        { name: 'Safety Rules', path: '/safety', icon: ShieldAlert },
        { name: 'Community Posts', path: '/moderation', icon: MessageSquare },
      ]
    },
    {
      label: 'Learning',
      items: [
        { name: 'Resources', path: '/resources', icon: BookOpen },
        { name: 'Questions', path: '/faq', icon: HelpCircle },
      ]
    },
    {
      label: 'Support',
      items: [
        { name: 'Support Requests', path: '/cases', icon: UserCheck },
      ]
    },
    {
      label: 'Team',
      items: [
        { name: 'People', path: '/users', icon: Users },
        { name: 'Settings', path: '/settings', icon: SettingsIcon },
      ]
    }
  ];

  return (
    <>
      <div 
        className={cn(
          "fixed inset-0 bg-indigo-900/10 backdrop-blur-sm z-40 lg:hidden transition-opacity",
          isOpen ? "opacity-100" : "opacity-0 pointer-events-none"
        )} 
        onClick={onClose}
      />
      <motion.aside
        initial={false}
        className={cn(
          "fixed top-0 left-0 bottom-0 w-72 bg-white border-r border-zinc-100 z-50 lg:translate-x-0 transition-transform shadow-2xl lg:shadow-none",
          isOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
        )}
      >
        <div className="p-8 pb-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <SisonkeLogo />
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
                  const isOn = location.pathname === item.path;
                  const Icon = item.icon;
                  return (
                    <Link
                      key={item.path}
                      to={item.path}
                      onClick={() => onClose()}
                      className={cn(
                        "flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-bold transition-all group relative overflow-hidden",
                        isOn 
                          ? "bg-indigo-600 text-white shadow-lg shadow-indigo-600/20" 
                          : "text-zinc-500 hover:bg-indigo-50 hover:text-indigo-600"
                      )}
                    >
                      {isOn && (
                        <motion.div 
                          layoutId="sidebar-active"
                          className="absolute inset-0 bg-indigo-600 -z-10"
                        />
                      )}
                      <Icon size={20} strokeWidth={isOn ? 3 : 2.5} className={cn(
                        "transition-transform group-hover:scale-110",
                        isOn ? "text-white" : "text-zinc-400 group-hover:text-indigo-500"
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
                <p className="text-[10px] font-black text-zinc-400 uppercase tracking-widest leading-none mb-1">Place</p>
                <p className="text-sm font-display font-bold text-zinc-900">Bulawayo</p>
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
      <div className="hidden sm:flex items-center gap-3 px-4 py-2 bg-indigo-50 border border-indigo-100 rounded-2xl">
        <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-xs font-bold ring-4 ring-white shadow-sm">
          {user?.email?.[0].toUpperCase()}
        </div>
        <div className="flex flex-col text-sm">
          <span className="font-semibold text-indigo-900 leading-none mb-0.5">{user?.email?.split('@')[0]}</span>
          <span className="text-[10px] text-indigo-500 font-bold uppercase tracking-wider">Team Lead</span>
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

const Card = ({ children, className }: { children: React.ReactNode, className?: string }) => (
  <div className={cn("bg-white border border-zinc-100 rounded-[2rem] shadow-sm hover:shadow-md transition-shadow", className)}>
    {children}
  </div>
);

const SisonkeLogo = ({ className = "w-10 h-10" }: { className?: string }) => (
  <img src="/sisonke-logo.png" alt="Sisonke" className={cn("rounded-2xl object-cover shadow-lg", className)} />
);

const dayLabel = (value: string) => {
  const date = new Date(value);
  return Number.isNaN(date.getTime())
    ? value
    : date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
};

const timeAgo = (value?: string) => {
  if (!value) return 'recently';
  const minutes = Math.max(0, Math.floor((Date.now() - new Date(value).getTime()) / 60000));
  if (minutes < 1) return 'just now';
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
};

const emptyChart = (days = 7) => Array.from({ length: days }, (_, index) => {
  const date = new Date(Date.now() - (days - index - 1) * 24 * 60 * 60 * 1000);
  const iso = date.toISOString().split('T')[0];
  return { date: iso, name: dayLabel(iso), appUse: 0, urgent: 0 };
});

// --- Pages ---

const Home = () => {
  const emptyStats = {
    totalUsers: 0,
    guestSessions: 0,
    chatbotSessions: 0,
    highRiskEscalations: 0,
    counselorCasesWaiting: 0,
    communityPostsPending: 0,
  };
  const [stats, setStats] = useState<any>(emptyStats);
  const [activity, setActivity] = useState<any[]>(emptyChart(7));
  const [loadError, setLoadError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      apiFetch('/api/admin/overview'),
      apiFetch('/api/admin/analytics?days=7').catch(() => null),
    ]).then(([data, analytics]) => {
      setStats({
        totalUsers: data.users?.total ?? 0,
        guestSessions: data.users?.guests ?? 0,
        chatbotSessions: data.chatbotSessions?.total ?? 0,
        highRiskEscalations: data.counselorCases?.highRisk ?? 0,
        counselorCasesWaiting: data.counselorCases?.waiting ?? data.counselorCases?.total ?? 0,
        communityPostsPending: data.communityPosts?.pending ?? 0,
      });
      const series = Array.isArray(analytics?.timeSeries) ? analytics.timeSeries : [];
      setActivity(series.length ? series.map((item: any) => ({
        ...item,
        name: dayLabel(item.date),
        appUse: Number(item.appUse || 0),
        urgent: Number(item.urgent || 0),
      })) : emptyChart(7));
      setLoadError('');
      setLoading(false);
    }).catch((error) => {
      setStats(emptyStats);
      setLoadError(error instanceof Error ? error.message : 'Could not load the latest numbers.');
      setLoading(false);
    });
  }, []);

  if (loading) return (
    <div className="p-10 space-y-8 animate-pulse max-w-7xl mx-auto">
      <div className="h-10 w-48 bg-zinc-200 rounded-xl" />
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {[1,2,3,4,5,6].map(i => <div key={i} className="h-32 bg-zinc-100 rounded-3xl" />)}
      </div>
    </div>
  );

  const cards = [
    { title: 'Total Users', value: stats.totalUsers, icon: Users, color: 'text-indigo-600', bg: 'bg-indigo-50' },
    { title: 'Guest visits', value: stats.guestSessions, icon: Clock, color: 'text-emerald-600', bg: 'bg-emerald-50' },
    { title: 'AI chats', value: stats.chatbotSessions, icon: MessageSquare, color: 'text-blue-600', bg: 'bg-blue-50' },
    { title: 'Urgent alerts', value: stats.highRiskEscalations, icon: AlertTriangle, color: 'text-rose-600', bg: 'bg-rose-50' },
    { title: 'Open cases', value: stats.counselorCasesWaiting, icon: UserCheck, color: 'text-amber-600', bg: 'bg-amber-50' },
    { title: 'Posts waiting', value: stats.communityPostsPending, icon: MessageSquare, color: 'text-violet-600', bg: 'bg-violet-50' },
  ];

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      {loadError && (
        <div className="p-4 bg-amber-50 border border-amber-100 text-amber-800 rounded-2xl font-bold">
          We could not load the latest numbers yet. The page is still usable.
        </div>
      )}
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        {cards.map((card, i) => (
          <Card key={i} className="p-8 group">
            <div className="flex items-center gap-4 mb-4">
              <div className={cn("p-3 rounded-2xl transition-transform group-hover:scale-110 group-hover:rotate-6", card.bg, card.color)}>
                <card.icon size={28} strokeWidth={2.5} />
              </div>
              <p className="text-zinc-500 text-xs font-bold uppercase tracking-[0.1em]">{card.title}</p>
            </div>
            <div className="flex items-baseline gap-2">
              <h3 className="text-4xl font-display font-black text-zinc-900 tracking-tight">{Number(card.value || 0).toLocaleString()}</h3>
            </div>
          </Card>
        ))}
      </motion.div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <Card className="p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-display font-bold">Recent activity</h3>
            <div className="flex gap-2">
               <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-500">
                 <div className="w-3 h-3 rounded-full bg-indigo-500" />
                 App visits
               </div>
               <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-500">
                 <div className="w-3 h-3 rounded-full bg-blue-400" />
                 App use
               </div>
            </div>
          </div>
          <div className="h-[320px]">
             <ResponsiveContainer width="100%" height="100%">
                <BarChart data={activity}>
                  <XAxis dataKey="name" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                  <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                  <Tooltip 
                    contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                  />
                  <Bar dataKey="appUse" fill="#6366f1" radius={[8, 8, 0, 0]} maxBarSize={32} />
                </BarChart>
             </ResponsiveContainer>
          </div>
        </Card>

        <Card className="p-8">
          <h3 className="text-xl font-display font-bold mb-8">Urgent help requests</h3>
          <div className="h-[320px]">
             <ResponsiveContainer width="100%" height="100%">
                <LineChart data={activity}>
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
                    dataKey="urgent" 
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
  const [editingContact, setEditingContact] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  const loadContacts = () => apiFetch('/api/admin/emergency-contacts').then(data => {
    setContacts(Array.isArray(data) ? data : []);
    setLoading(false);
  });

  useEffect(() => {
    loadContacts().catch(() => setLoading(false));
  }, []);

  const filtered = contacts.filter(c => c.name.toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div className="relative flex-1 max-w-lg">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
          <input 
            type="text" 
            placeholder="Find help contacts..." 
            className="w-full pl-12 pr-6 py-4 bg-white border border-zinc-200 rounded-2xl shadow-sm focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 focus:outline-none transition-all placeholder:text-zinc-400"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <button
          onClick={() => setEditingContact({ name: '', phoneNumber: '', category: 'crisis', description: '', isActive: true, status: 'published', country: 'ZW' })}
          className="flex items-center justify-center gap-2 px-6 py-4 bg-indigo-600 text-white rounded-2xl font-bold shadow-lg shadow-indigo-600/20 hover:bg-indigo-700 hover:-translate-y-0.5 active:translate-y-0 transition-all"
        >
          <Plus size={20} strokeWidth={3} /> Add contact
        </button>
      </div>

      {editingContact && (
        <Card className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input className="px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold outline-none" placeholder="Name" value={editingContact.name} onChange={e => setEditingContact({ ...editingContact, name: e.target.value })} />
            <input className="px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold outline-none" placeholder="Phone" value={editingContact.phoneNumber} onChange={e => setEditingContact({ ...editingContact, phoneNumber: e.target.value })} />
            <input className="px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold outline-none" placeholder="Type" value={editingContact.category} onChange={e => setEditingContact({ ...editingContact, category: e.target.value })} />
            <label className="flex items-center gap-3 px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold">
              <input type="checkbox" className="accent-indigo-600" checked={editingContact.isActive} onChange={e => setEditingContact({ ...editingContact, isActive: e.target.checked })} />
              Contact is on
            </label>
            <textarea className="md:col-span-2 px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold outline-none" placeholder="What this contact helps with" value={editingContact.description || ''} onChange={e => setEditingContact({ ...editingContact, description: e.target.value })} />
          </div>
          <div className="flex justify-end gap-3 mt-5">
            <button onClick={() => setEditingContact(null)} className="px-5 py-3 bg-zinc-100 rounded-2xl font-bold">Cancel</button>
            <button
              onClick={async () => {
                await apiFetch(editingContact.id ? `/api/admin/emergency-contacts/${editingContact.id}` : '/api/admin/emergency-contacts', {
                  method: editingContact.id ? 'PUT' : 'POST',
                  body: JSON.stringify(editingContact),
                });
                setEditingContact(null);
                await loadContacts();
              }}
              className="px-5 py-3 bg-indigo-600 text-white rounded-2xl font-black"
            >
              Save contact
            </button>
          </div>
        </Card>
      )}

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead className="bg-zinc-50/50 border-b border-zinc-100">
              <tr>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Contact</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Type</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Phone</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">Status</th>
                <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 text-right">Edit</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {filtered.map((contact) => (
                <tr key={contact.id} className="hover:bg-indigo-50/30 transition-colors group">
                  <td className="px-8 py-6">
                    <div className="font-display font-bold text-zinc-900 text-base">{contact.name}</div>
                    <div className="text-sm text-zinc-500 mt-0.5 line-clamp-1">{contact.description}</div>
                  </td>
                  <td className="px-8 py-6">
                    <span className="inline-flex items-center px-3 py-1 rounded-xl text-[11px] font-black uppercase tracking-wider bg-white border border-zinc-100 text-zinc-600 shadow-sm">
                      {contact.category.replace('-', ' ')}
                    </span>
                  </td>
                  <td className="px-8 py-6 font-mono text-base font-bold text-indigo-600">{contact.phoneNumber}</td>
                  <td className="px-8 py-6">
                    <div className={cn(
                      "inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter",
                      contact.isActive ? "bg-emerald-100 text-emerald-700" : "bg-zinc-100 text-zinc-500"
                    )}>
                      <div className={cn("w-1.5 h-1.5 rounded-full", contact.isActive ? "bg-emerald-500 animate-pulse" : "bg-zinc-400")} />
                      {contact.isActive ? 'On' : 'Off'}
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button onClick={() => setEditingContact(contact)} className="p-2.5 text-zinc-400 hover:text-indigo-600 hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-100 transition-all">
                        <Edit2 size={18} />
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
    apiFetch('/api/admin/resources').then(data => setResources(Array.isArray(data) ? data : []));
  }, []);

  return (
    <div className="p-6 lg:p-10 grid grid-cols-1 lg:grid-cols-12 gap-10 max-w-screen-2xl mx-auto">
      <div className="lg:col-span-12 xl:col-span-8 space-y-8">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
           <div>
             <h3 className="text-3xl font-display font-black text-zinc-900 leading-tight">Content Library</h3>
             <p className="text-zinc-500 font-medium">Manage wellness guides and resources for Zimbabwe youth</p>
           </div>
           <button onClick={() => setEditing({ title: '', content: '', category: 'wellness', isPublished: false })} className="flex items-center justify-center gap-2 px-8 py-4 bg-indigo-600 text-white rounded-2xl font-bold hover:bg-indigo-700 shadow-xl shadow-indigo-600/20 active:scale-95 transition-all">
              <Plus size={20} strokeWidth={3} /> Add resource
           </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {resources.map(r => (
              <Card key={r.id} className="p-0 border-none bg-white shadow-xl shadow-zinc-200/50 hover:shadow-2xl hover:shadow-indigo-100 transition-all overflow-hidden group">
                <div className={cn(
                  "h-32 p-6 flex items-end relative overflow-hidden",
                  r.category === 'mental-health' ? "bg-indigo-600" : 
                  r.category === 'srhr' ? "bg-rose-500" : "bg-amber-500"
                )}>
                  <div className="absolute top-4 right-4">
                    <span className={cn(
                      "px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider",
                      r.isPublished ? "bg-emerald-400/20 text-white" : "bg-white/20 text-white"
                    )}>
                      {r.isPublished ? 'Open' : 'Draft'}
                    </span>
                  </div>
                  <h4 className="font-display font-black text-white text-xl leading-tight group-hover:translate-x-2 transition-transform">{r.title}</h4>
                </div>
                <div className="p-6 space-y-4">
                  <div className="flex items-center gap-4 text-[10px] font-black uppercase tracking-widest text-zinc-400">
                    <span className="bg-zinc-100 px-2 py-1 rounded-lg">{r.category}</span>
                    <span>|</span>
                    <span>{r.language}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-zinc-500 font-medium italic">Updated {r.updatedAt ? new Date(r.updatedAt).toLocaleDateString() : 'recently'}</span>
                    <button onClick={() => setEditing(r)} className="w-10 h-10 rounded-xl bg-zinc-50 flex items-center justify-center hover:bg-indigo-50 hover:text-indigo-600 transition-colors">
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
              <Card className="p-10 space-y-10 sticky top-24 border-indigo-100 ring-4 ring-indigo-50 shadow-2xl">
                <div className="flex items-center justify-between">
                    <h3 className="font-display font-black text-2xl tracking-tight">{editing.id ? 'Edit resource' : 'Add resource'}</h3>
                  <button onClick={() => setEditing(null)} className="w-8 h-8 rounded-full bg-zinc-100 flex items-center justify-center text-zinc-400 hover:text-rose-600 transition-colors"><X size={18} strokeWidth={3} /></button>
                </div>
                
                <div className="space-y-8">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Title</label>
                    <input autoFocus value={editing.title} onChange={e => setEditing({...editing, title: e.target.value})} className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl font-display font-bold text-lg focus:ring-4 focus:ring-indigo-100 outline-none transition-all" placeholder="Enter a catchy title..." />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Content</label>
                    <textarea 
                      rows={12} 
                      value={editing.content} 
                      onChange={e => setEditing({...editing, content: e.target.value})}
                      className="w-full p-4 bg-zinc-50 border border-zinc-200 rounded-xl font-mono text-xs leading-relaxed focus:ring-4 focus:ring-indigo-100 outline-none transition-all resize-none"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Topic</label>
                      <select value={editing.category} onChange={e => setEditing({...editing, category: e.target.value})} className="w-full p-3 bg-zinc-50 border border-zinc-200 rounded-xl font-bold text-sm focus:ring-4 focus:ring-indigo-100 outline-none">
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
                        {editing.isPublished ? 'Published' : 'Draft'}
                      </button>
                    </div>
                  </div>
                  <button
                    onClick={async () => {
                      await apiFetch(editing.id ? `/api/admin/resources/${editing.id}` : '/api/admin/resources', {
                        method: editing.id ? 'PUT' : 'POST',
                        body: JSON.stringify({
                          title: editing.title,
                          description: editing.description || editing.title || 'Sisonke youth wellness resource',
                          content: editing.content || '',
                          category: editing.category,
                          status: editing.isPublished ? 'published' : 'draft',
                          language: editing.language || 'en',
                          isOfflineAvailable: true,
                        }),
                      });
                      const data = await apiFetch('/api/admin/resources');
                      setResources(Array.isArray(data) ? data : []);
                      setEditing(null);
                    }}
                    className="w-full py-5 bg-zinc-900 text-white rounded-3xl font-display font-bold text-lg shadow-xl shadow-zinc-900/20 active:scale-95 transition-all"
                  >
                    Save resource
                  </button>
                </div>
              </Card>
            </motion.div>
          ) : (
            <div className="h-[600px] border-4 border-dashed border-zinc-100 rounded-[3rem] flex flex-col items-center justify-center p-12 text-center">
              <div className="w-20 h-20 bg-zinc-50 rounded-full flex items-center justify-center mb-6">
                <BookOpen className="text-zinc-200" size={32} />
              </div>
              <h4 className="text-xl font-display font-bold text-zinc-300 mb-2">No resource selected</h4>
              <p className="text-zinc-400 text-sm max-w-[200px]">Choose a resource to edit, or add a new one.</p>
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
    apiFetch('/api/admin/faqs').then(data => setFaqs(Array.isArray(data) ? data : []));
  }, []);

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 bg-indigo-600 p-8 lg:p-12 rounded-[3.5rem] shadow-2xl relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full -translate-y-1/2 translate-x-1/2 blur-3xl pointer-events-none" />
        <div className="relative z-10">
          <h3 className="text-4xl font-display font-black text-white leading-tight">Saved answers</h3>
          <p className="text-indigo-100 font-medium mt-1">High-quality, checked answers for young people</p>
        </div>
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
                      {faq.riskLevel} level
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
                       <button className="px-4 py-2 bg-zinc-100 rounded-xl hover:bg-indigo-600 hover:text-white transition-all">Edit</button>
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
    apiFetch('/api/admin/safety-rules').then(data => setRules(Array.isArray(data) ? data : []));
  }, []);

  const handleTest = async () => {
    const data = await apiFetch('/api/admin/safety-rules/test', {
      method: 'POST',
      body: JSON.stringify({ message: testMsg })
    });
    setTestResult(data);
  };

  return (
    <div className="p-6 lg:p-10 grid grid-cols-1 xl:grid-cols-2 gap-12 max-w-7xl mx-auto">
      <div className="space-y-10">
        <div>
          <h3 className="text-3xl font-display font-black text-zinc-900 leading-none mb-3">Danger words</h3>
          <p className="text-zinc-500 font-medium">Words and phrases that tell Sisonke to get human help quickly</p>
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
                  rule.risk === 'red' ? "bg-rose-700/50 border-white text-rose-50" : "bg-zinc-50 border-indigo-500 text-zinc-600"
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
               Check message
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
                         <span className="text-xs font-black uppercase tracking-widest opacity-60">Result</span>
                         <span className="font-display font-black text-xl">{testResult.detected ? 'Needs urgent help' : 'No urgent danger found'}</span>
                       </div>
                    </div>
                    {testResult.detected && (
                      <p className="text-sm font-medium leading-relaxed mt-4 opacity-80 italic">Matched: '{testResult.rule.route}'. Sisonke will show help contacts and ask the young person to get human support.</p>
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
    const loadCases = () => apiFetch('/api/admin/counselor-cases').then(data => setCases(Array.isArray(data) ? data : []));
    useEffect(() => {
      loadCases();
    }, []);

    return (
      <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
           <h3 className="text-3xl font-display font-black text-zinc-900">Open support requests</h3>
           <div className="flex gap-3">
               <div className="px-5 py-2 bg-indigo-50 text-indigo-600 rounded-2xl text-sm font-bold flex items-center gap-2">
                <Activity size={18} /> {cases.length} open
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
                      <span className="text-[10px] font-black text-zinc-400 underline decoration-zinc-200 underline-offset-4">HELP REQUEST #{c.id}</span>
                      <span className={cn(
                        "px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-widest",
                        c.riskLevel === 'high' ? "bg-rose-100 text-rose-700" : "bg-zinc-100 text-zinc-500"
                      )}>
                        {c.riskLevel} level
                      </span>
                    </div>
                    <h4 className="text-2xl font-display font-black text-zinc-900 line-clamp-1">{c.summary}</h4>
                    <div className="flex items-center gap-2 text-xs font-semibold text-zinc-400">
                      <Clock size={14} strokeWidth={3} />
                      Opened {timeAgo(c.createdAt)}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                   <select
                     value={c.status}
                     onChange={async (event) => {
                       await apiFetch(`/api/admin/counselor-cases/${c.id}/status`, {
                         method: 'POST',
                         body: JSON.stringify({ status: event.target.value }),
                       });
                       await loadCases();
                     }}
                     className="px-6 py-3.5 bg-zinc-50 border border-zinc-100 rounded-2xl text-sm font-bold shadow-sm focus:ring-4 focus:ring-indigo-100 outline-none"
                   >
                     <option value="requested">New</option>
                     <option value="assigned">Assigned</option>
                     <option value="live">In progress</option>
                     <option value="follow-up">Follow up</option>
                     <option value="resolved">Done</option>
                     <option value="emergency">Emergency</option>
                   </select>
                </div>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>
    );
};

const CommunityPosts = () => {
  const [posts, setPosts] = useState<any[]>([]);
  const [message, setMessage] = useState('');

  const loadPosts = () => apiFetch('/api/admin/community-posts').then(data => setPosts(Array.isArray(data) ? data : []));

  useEffect(() => {
    loadPosts();
  }, []);

  const reviewPost = async (id: string, status: 'approved' | 'removed') => {
    setMessage('');
    await apiFetch(`/api/admin/community-posts/${id}/moderate`, {
      method: 'POST',
      body: JSON.stringify({ status, reason: status === 'removed' ? 'Removed by admin review' : undefined }),
    });
    setMessage(status === 'approved' ? 'Post approved.' : 'Post removed.');
    await loadPosts();
  };

  const pending = posts.filter(post => post.status === 'pending');

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-3xl font-display font-black text-zinc-900">Community Posts</h3>
          <p className="text-zinc-500 font-medium">Review posts before they appear to young people.</p>
        </div>
        <div className="px-5 py-3 bg-indigo-50 text-indigo-700 rounded-2xl font-black">
          {pending.length} waiting
        </div>
      </div>

      {message && <div className="p-4 bg-emerald-50 text-emerald-700 rounded-2xl font-bold">{message}</div>}

      <div className="grid gap-5">
        {posts.length === 0 && (
          <Card className="p-10 text-center text-zinc-500 font-bold">
            No community posts yet.
          </Card>
        )}
        {posts.map(post => (
          <Card key={post.id} className="p-6">
            <div className="flex flex-col lg:flex-row lg:items-start justify-between gap-5">
              <div className="space-y-3">
                <div className="flex flex-wrap gap-2">
                  <span className="px-3 py-1 bg-zinc-100 rounded-xl text-xs font-black text-zinc-600">{post.ageGroup || 'Age not set'}</span>
                  <span className={cn(
                    "px-3 py-1 rounded-xl text-xs font-black",
                    post.status === 'pending' ? "bg-amber-100 text-amber-700" :
                    post.status === 'approved' ? "bg-emerald-100 text-emerald-700" :
                    "bg-rose-100 text-rose-700"
                  )}>
                    {post.status}
                  </span>
                  <span className="px-3 py-1 bg-zinc-50 rounded-xl text-xs font-bold text-zinc-400">{timeAgo(post.createdAt)}</span>
                </div>
                <p className="text-lg text-zinc-800 leading-relaxed">{post.content}</p>
                {post.moderationReason && <p className="text-sm text-rose-600 font-bold">{post.moderationReason}</p>}
              </div>
              {post.status === 'pending' && (
                <div className="flex gap-3 shrink-0">
                  <button onClick={() => reviewPost(post.id, 'approved')} className="px-5 py-3 bg-emerald-600 text-white rounded-2xl font-black">Approve</button>
                  <button onClick={() => reviewPost(post.id, 'removed')} className="px-5 py-3 bg-rose-600 text-white rounded-2xl font-black">Remove</button>
                </div>
              )}
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
};

const roleOptions = [
  { value: 'super-admin', label: 'Team lead' },
  { value: 'admin', label: 'Admin' },
  { value: 'counselor', label: 'Counselor' },
  { value: 'moderator', label: 'Community helper' },
  { value: 'content-manager', label: 'Content helper' },
  { value: 'safety-reviewer', label: 'Safety reviewer' },
  { value: 'analyst', label: 'Reports viewer' },
  { value: 'user', label: 'App user' },
];

const People = () => {
  const blankForm = { id: '', email: '', password: '', roles: ['user'], mustChangePassword: true, isSuspended: false };
  const [people, setPeople] = useState<any[]>([]);
  const [form, setForm] = useState<any>(blankForm);
  const [message, setMessage] = useState('');

  const loadPeople = () => apiFetch('/api/admin/users').then(data => setPeople(Array.isArray(data) ? data : []));

  useEffect(() => {
    loadPeople();
  }, []);

  const toggleRole = (role: string) => {
    setForm((current: any) => {
      const roles = current.roles.includes(role)
        ? current.roles.filter((item: string) => item !== role)
        : [...current.roles, role];
      return { ...current, roles: roles.length ? roles : ['user'] };
    });
  };

  const editPerson = (person: any) => {
    setForm({
      id: person.id,
      email: person.email || '',
      password: '',
      roles: person.roles?.length ? person.roles : [person.role || 'user'],
      mustChangePassword: Boolean(person.mustChangePassword),
      isSuspended: Boolean(person.isSuspended),
    });
    setMessage('');
  };

  const savePerson = async (event: React.FormEvent) => {
    event.preventDefault();
    setMessage('');
    if (!form.email.trim()) return setMessage('Please enter an email address.');
    if (!form.id && !form.password) return setMessage('Please enter a starting password.');

    if (form.id) {
      await apiFetch(`/api/admin/users/${form.id}`, {
        method: 'PUT',
        body: JSON.stringify({
          email: form.email,
          roles: form.roles,
          mustChangePassword: form.mustChangePassword,
          isSuspended: form.isSuspended,
        }),
      });
      if (form.password) {
        await apiFetch(`/api/admin/users/${form.id}/password`, {
          method: 'PUT',
          body: JSON.stringify({ password: form.password, mustChangePassword: form.mustChangePassword }),
        });
      }
      setMessage('Person updated.');
    } else {
      await apiFetch('/api/admin/users', {
        method: 'POST',
        body: JSON.stringify({
          email: form.email,
          password: form.password,
          roles: form.roles,
          mustChangePassword: form.mustChangePassword,
        }),
      });
      setMessage('Person added.');
    }
    setForm(blankForm);
    await loadPeople();
  };

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-7xl mx-auto">
      <div>
        <h3 className="text-3xl font-display font-black text-zinc-900">People</h3>
        <p className="text-zinc-500 font-medium">Add team members, choose what they can do, and reset passwords.</p>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-[420px_1fr] gap-8">
        <Card className="p-8">
          <h4 className="text-xl font-display font-black mb-6">{form.id ? 'Edit person' : 'Add person'}</h4>
          <form onSubmit={savePerson} className="space-y-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-zinc-500">Email</label>
              <input className="w-full px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl outline-none focus:ring-4 focus:ring-indigo-100" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} type="email" />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-zinc-500">{form.id ? 'New password, if changing it' : 'Starting password'}</label>
              <input className="w-full px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl outline-none focus:ring-4 focus:ring-indigo-100" value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} type="password" />
            </div>
            <div className="space-y-3">
              <label className="text-xs font-bold text-zinc-500">What this person can do</label>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {roleOptions.map(role => (
                  <label key={role.value} className={cn("flex items-center gap-2 px-3 py-2 rounded-xl border text-sm font-bold cursor-pointer", form.roles.includes(role.value) ? "bg-indigo-50 border-indigo-200 text-indigo-700" : "bg-white border-zinc-100 text-zinc-500")}>
                    <input type="checkbox" className="accent-indigo-600" checked={form.roles.includes(role.value)} onChange={() => toggleRole(role.value)} />
                    {role.label}
                  </label>
                ))}
              </div>
            </div>
            <label className="flex items-center gap-3 p-4 bg-amber-50 text-amber-800 rounded-2xl font-bold">
              <input type="checkbox" className="accent-amber-600" checked={form.mustChangePassword} onChange={e => setForm({ ...form, mustChangePassword: e.target.checked })} />
              Ask them to choose a new password next time
            </label>
            {form.id && (
              <label className="flex items-center gap-3 p-4 bg-rose-50 text-rose-800 rounded-2xl font-bold">
                <input type="checkbox" className="accent-rose-600" checked={form.isSuspended} onChange={e => setForm({ ...form, isSuspended: e.target.checked })} />
                Pause this account
              </label>
            )}
            <div className="flex gap-3">
              <button type="submit" className="flex-1 py-4 bg-indigo-600 text-white rounded-2xl font-black shadow-lg shadow-indigo-100">{form.id ? 'Save changes' : 'Add person'}</button>
              {form.id && <button type="button" onClick={() => setForm(blankForm)} className="px-5 py-4 bg-zinc-100 rounded-2xl font-bold">Cancel</button>}
            </div>
            {message && <p className="text-sm font-bold text-indigo-700">{message}</p>}
          </form>
        </Card>

        <Card className="overflow-hidden">
          <table className="w-full text-left">
            <thead className="bg-zinc-50 border-b border-zinc-100">
              <tr>
                <th className="px-6 py-4 text-xs font-black text-zinc-400">Person</th>
                <th className="px-6 py-4 text-xs font-black text-zinc-400">Can do</th>
                <th className="px-6 py-4 text-xs font-black text-zinc-400">Password</th>
                <th className="px-6 py-4 text-xs font-black text-zinc-400 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {people.map(person => (
                <tr key={person.id} className="hover:bg-indigo-50/30">
                  <td className="px-6 py-5">
                    <div className="font-bold text-zinc-900">{person.email || 'Guest user'}</div>
                    <div className="text-xs text-zinc-400">{person.isSuspended ? 'Paused' : 'On'}</div>
                  </td>
                  <td className="px-6 py-5">
                    <div className="flex flex-wrap gap-2">
                      {(person.roles || []).map((role: string) => (
                        <span key={role} className="px-2 py-1 bg-zinc-100 text-zinc-600 rounded-lg text-xs font-bold">{roleOptions.find(item => item.value === role)?.label || role}</span>
                      ))}
                    </div>
                  </td>
                  <td className="px-6 py-5 text-sm font-bold text-zinc-500">{person.mustChangePassword ? 'Must choose new password' : 'Set'}</td>
                  <td className="px-6 py-5 text-right">
                    <button onClick={() => editPerson(person)} className="px-4 py-2 bg-zinc-900 text-white rounded-xl text-sm font-bold">Edit</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      </div>
    </div>
  );
};

const Reports = () => {
  const [summary, setSummary] = useState<any>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    apiFetch('/api/admin/analytics?days=30')
      .then((data) => {
        const series = Array.isArray(data.timeSeries) ? data.timeSeries : [];
        setSummary({
          ...data,
          timeSeries: series.length ? series.map((item: any) => ({
            ...item,
            name: dayLabel(item.date),
            appUse: Number(item.appUse || 0),
            urgent: Number(item.urgent || 0),
          })) : emptyChart(30),
        });
        setError('');
      })
      .catch((err) => {
        setSummary({ total: 0, counselorEscalations: 0, chatbotSessions: 0, timeSeries: emptyChart(30), issueCategories: {}, moodTrendsByMood: {} });
        setError(err instanceof Error ? err.message : 'Could not load reports.');
      });
  }, []);

  if (!summary) return null;

  const chartData = summary.timeSeries;
  const totalAppUse = Number(summary.total || 0);
  const urgentRequests = Number(summary.counselorEscalations || 0);
  const helpRate = totalAppUse > 0 ? Math.round((urgentRequests / totalAppUse) * 100) : 0;
  const issueEntries = Object.entries(summary.issueCategories || {});
  const moodEntries = Object.entries(summary.moodTrendsByMood || {});

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
       <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
          <div>
            <h3 className="text-3xl font-display font-black text-zinc-900">Reports</h3>
            <p className="text-zinc-500 font-medium">Real totals from the last 30 days.</p>
          </div>
          <div className="px-6 py-3 bg-white border border-zinc-100 rounded-2xl text-xs font-black uppercase tracking-widest shadow-sm">Last 30 days</div>
       </div>

       {error && <div className="p-4 bg-amber-50 border border-amber-100 text-amber-800 rounded-2xl font-bold">{error}</div>}

       <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
         <Card className="p-10 bg-indigo-600 text-white border-none shadow-2xl shadow-indigo-100">
            <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-indigo-200 mb-8 flex items-center gap-2">
              <Activity size={12} strokeWidth={3} /> App use
            </h4>
            <div className="h-[220px]">
              <ResponsiveContainer width="100%" height="100%">
                 <BarChart data={chartData}>
                    <XAxis dataKey="name" hide />
                    <Tooltip contentStyle={{ borderRadius: '16px', border: 'none' }} />
                    <Bar dataKey="appUse" fill="#fff" radius={[6, 6, 0, 0]} />
                 </BarChart>
              </ResponsiveContainer>
            </div>
            <div className="mt-8 pt-8 border-t border-white/10 flex justify-between">
               <div className="flex flex-col">
                 <span className="text-2xl font-display font-black">{totalAppUse.toLocaleString()}</span>
                 <span className="text-[10px] font-bold uppercase opacity-60">Tracked actions</span>
               </div>
               <div className="flex flex-col items-end">
                 <span className="text-2xl font-display font-black">{Number(summary.chatbotSessions || 0).toLocaleString()}</span>
                 <span className="text-[10px] font-bold uppercase opacity-60">AI chats</span>
               </div>
            </div>
         </Card>
         
         <Card className="p-10 lg:col-span-2 bg-white shadow-2xl shadow-zinc-100 border-none">
            <div className="flex items-center justify-between mb-8">
              <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 flex items-center gap-2">
                <AlertTriangle size={12} strokeWidth={3} className="text-rose-500" /> Urgent help over time
              </h4>
              <div className="text-[10px] font-black uppercase text-rose-500 bg-rose-50 px-3 py-1 rounded-full">{urgentRequests} urgent</div>
            </div>
            <div className="h-[220px]">
              <ResponsiveContainer width="100%" height="100%">
                 <LineChart data={chartData}>
                    <XAxis dataKey="name" axisLine={false} tickLine={false} fontSize={10} tick={{ fill: '#94a3b8' }} />
                    <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }} />
                    <Line type="monotone" dataKey="urgent" stroke="#f43f5e" strokeWidth={5} dot={{ r: 5, fill: '#f43f5e', stroke: '#fff', strokeWidth: 2 }} />
                 </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="mt-8 flex flex-wrap justify-center gap-8">
               <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-rose-50 rounded-2xl flex items-center justify-center text-rose-600">
                    <ShieldAlert size={20} strokeWidth={3} />
                  </div>
                  <div className="flex flex-col">
                    <span className="font-display font-black text-xl leading-none">{urgentRequests.toLocaleString()}</span>
                    <span className="text-[10px] font-black uppercase tracking-widest text-zinc-400">Urgent requests</span>
                  </div>
               </div>
               <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-indigo-50 rounded-2xl flex items-center justify-center text-indigo-600">
                    <UserCheck size={20} strokeWidth={3} />
                  </div>
                  <div className="flex flex-col">
                    <span className="font-display font-black text-xl leading-none">{helpRate}%</span>
                    <span className="text-[10px] font-black uppercase tracking-widest text-zinc-400">Urgent share</span>
                  </div>
               </div>
            </div>
         </Card>
       </div>

       <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <Card className="p-8">
          <h4 className="text-xl font-display font-black mb-5">Support topics</h4>
          <div className="space-y-3">
            {issueEntries.length === 0 && <p className="text-zinc-500 font-bold">No support topics recorded yet.</p>}
            {issueEntries.map(([name, value]) => <div key={name} className="flex justify-between border-b border-zinc-100 pb-2"><span className="font-bold text-zinc-700">{name}</span><span className="font-black">{Number(value).toLocaleString()}</span></div>)}
          </div>
        </Card>
        <Card className="p-8">
          <h4 className="text-xl font-display font-black mb-5">Mood check-ins</h4>
          <div className="space-y-3">
            {moodEntries.length === 0 && <p className="text-zinc-500 font-bold">No mood check-ins recorded yet.</p>}
            {moodEntries.map(([name, value]) => <div key={name} className="flex justify-between border-b border-zinc-100 pb-2"><span className="font-bold text-zinc-700">{name}</span><span className="font-black">{Number(value).toLocaleString()}</span></div>)}
          </div>
        </Card>
       </div>
       
       <div className="bg-amber-100/50 border-2 border-dashed border-amber-200 p-10 rounded-[3rem] flex gap-8 items-start">
          <div className="w-16 h-16 bg-amber-500 rounded-3xl shrink-0 flex items-center justify-center text-white shadow-xl shadow-amber-200">
            <Lock size={32} strokeWidth={2.5} />
          </div>
          <div>
            <h5 className="text-2xl font-display font-black text-amber-900 mb-2 tracking-tight">Privacy promise</h5>
            <p className="text-lg text-amber-800 leading-relaxed max-w-4xl opacity-80 font-medium">
              These numbers are summaries only. We do not show private chats or journal notes here. We only share personal details when safety support truly needs it.
            </p>
          </div>
       </div>
    </div>
  );
}

const Settings = () => (
  <div className="p-6 lg:p-10 max-w-4xl mx-auto space-y-16">
    <div className="space-y-12">
      <section>
        <h3 className="text-3xl font-display font-black text-zinc-900 flex items-center gap-3 mb-8 italic">
          <Shield className="text-indigo-600" size={32} strokeWidth={3} /> How we keep Sisonke safe
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {[
            { text: "Emergency contacts reviewed monthly", color: "bg-indigo-50 text-indigo-700 border-indigo-100" },
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
        <h3 className="text-2xl font-display font-black text-zinc-900 leading-none">Your account</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-8">
           <div className="space-y-2">
             <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Access level</label>
             <div className="w-full px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold text-zinc-600">Team lead</div>
           </div>
           <div className="space-y-2">
             <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Location</label>
             <div className="w-full px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold text-zinc-600">Bulawayo</div>
           </div>
        </div>
      </section>
    </div>
  </div>
)

// --- Auth Pages ---

const LoginPage = ({ onLogin }: { onLogin: (email: string, password: string) => Promise<void> }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  return (
    <div className="min-h-screen bg-[#FAFAFF] flex items-center justify-center p-6 sm:p-12 overflow-hidden relative font-sans">
      <div className="absolute top-0 right-0 w-96 h-96 bg-indigo-100 rounded-full blur-[100px] -translate-y-1/2 translate-x-1/3 opacity-50" />
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-rose-100 rounded-full blur-[100px] translate-y-1/2 -translate-x-1/3 opacity-50" />
      
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <Card className="w-full max-w-lg p-12 border-none shadow-2xl relative overflow-hidden bg-white/80 backdrop-blur-xl">
          <div className="text-center mb-12">
            <SisonkeLogo className="w-20 h-20 mx-auto mb-6 rounded-3xl" />
            <h1 className="text-4xl font-display font-black text-zinc-900 tracking-tight mb-2 uppercase italic">SISONKE</h1>
            <p className="text-zinc-500 font-medium tracking-tight">Team sign in for youth support</p>
          </div>
          
          <form onSubmit={async (e) => {
            e.preventDefault();
            setError('');
            setLoading(true);
            try {
              await onLogin(email, password);
            } catch (err) {
              setError(err instanceof Error ? err.message : 'Sign in failed');
            } finally {
              setLoading(false);
            }
          }} className="space-y-6">
            <div className="space-y-2">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Email</label>
              <div className="relative">
                 <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
                 <input 
                  type="email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-indigo-100 focus:bg-white outline-none transition-all"
                  placeholder="admin@sisonke.org"
                  required
                />
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Password</label>
              <div className="relative">
                 <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
                 <input 
                  type="password" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-indigo-100 focus:bg-white outline-none transition-all"
                  placeholder="||||||||"
                  required
                />
              </div>
            </div>
            <button 
              type="submit"
              disabled={loading}
              className="w-full py-5 bg-zinc-900 text-white rounded-3xl font-display font-black text-lg shadow-xl shadow-zinc-900/20 hover:scale-[1.02] active:scale-95 transition-all"
            >
              {loading ? 'Checking...' : 'Sign in'}
            </button>
            {error && <p className="text-sm font-bold text-rose-600 text-center">{error}</p>}
          </form>
          
          <div className="mt-10 pt-8 border-t border-zinc-50 flex items-center justify-center gap-4 text-[10px] font-black text-zinc-300 uppercase tracking-[0.2em]">
             <span>Private</span>
             <span>|</span>
             <span>Made for youth support</span>
          </div>
        </Card>
      </motion.div>
    </div>
  );
};

const ChangePasswordPage = ({ onDone, onLogout }: { onDone: () => void; onLogout: () => void }) => {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  return (
    <div className="min-h-screen bg-[#FAFAFF] flex items-center justify-center p-6">
      <Card className="w-full max-w-lg p-10 border-none shadow-2xl bg-white">
        <div className="text-center mb-8">
          <SisonkeLogo className="w-20 h-20 mx-auto mb-5 rounded-3xl" />
          <h1 className="text-3xl font-display font-black text-zinc-900">Choose a new password</h1>
          <p className="text-zinc-500 mt-2">Your team lead asked you to update your password before you continue.</p>
        </div>
        <form onSubmit={async (event) => {
          event.preventDefault();
          setError('');
          setLoading(true);
          try {
            await apiFetch('/api/auth/change-password', {
              method: 'POST',
              body: JSON.stringify({ newPassword: password }),
            });
            onDone();
          } catch (err) {
            setError(err instanceof Error ? err.message : 'Could not change password.');
          } finally {
            setLoading(false);
          }
        }} className="space-y-5">
          <input
            type="password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            className="w-full px-5 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-indigo-100 outline-none"
            placeholder="New password"
            required
          />
          <button type="submit" disabled={loading} className="w-full py-4 bg-indigo-600 text-white rounded-2xl font-black">
            {loading ? 'Saving...' : 'Save password'}
          </button>
          <button type="button" onClick={onLogout} className="w-full py-3 text-zinc-500 font-bold">Sign out</button>
          {error && <p className="text-sm font-bold text-rose-600 text-center">{error}</p>}
        </form>
      </Card>
    </div>
  );
};

// --- Main Layout Wrapper ---

const AdminLayout = ({ children, title, logout, user }: any) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-white">
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="lg:pl-72 min-h-screen flex flex-col">
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
  const { user, login, logout, finishPasswordChange, isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <LoginPage onLogin={login} />;
  }

  if (user?.mustChangePassword) {
    return <ChangePasswordPage onDone={finishPasswordChange} onLogout={logout} />;
  }

  return (
    <Router>
      <Routes>
        <Route path="/" element={<AdminLayout title="Home" user={user} logout={logout}><Home /></AdminLayout>} />
        <Route path="/emergency" element={<AdminLayout title="Help Contacts" user={user} logout={logout}><EmergencyContacts /></AdminLayout>} />
        <Route path="/resources" element={<AdminLayout title="Resources" user={user} logout={logout}><ResourcesCMS /></AdminLayout>} />
        <Route path="/faq" element={<AdminLayout title="Questions" user={user} logout={logout}><FAQBank /></AdminLayout>} />
        <Route path="/safety" element={<AdminLayout title="Safety Rules" user={user} logout={logout}><SafetyRules /></AdminLayout>} />
        <Route path="/cases" element={<AdminLayout title="Support Requests" user={user} logout={logout}><CounselorCases /></AdminLayout>} />
        <Route path="/users" element={<AdminLayout title="People" user={user} logout={logout}><People /></AdminLayout>} />
        <Route path="/moderation" element={<AdminLayout title="Community Posts" user={user} logout={logout}><CommunityPosts /></AdminLayout>} />
        <Route path="/analytics" element={<AdminLayout title="Reports" user={user} logout={logout}><Reports /></AdminLayout>} />
        <Route path="/settings" element={<AdminLayout title="Settings" user={user} logout={logout}><Settings /></AdminLayout>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}




