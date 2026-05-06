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

// --- Auth Context Mock ---
const useAuth = () => {
  const [user, setUser] = useState<{ email: string } | null>(() => {
    const saved = localStorage.getItem('sisonke_admin_user');
    return saved ? JSON.parse(saved) : null;
  });

  const login = (email: string) => {
    const u = { email };
    setUser(u);
    localStorage.setItem('sisonke_admin_user', JSON.stringify(u));
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('sisonke_admin_user');
  };

  return { user, login, logout, isAuthenticated: !!user };
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
          "fixed inset-0 bg-indigo-900/10 backdrop-blur-sm z-40 lg:hidden transition-opacity",
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
            <div className="w-10 h-10 bg-indigo-600 rounded-2xl flex items-center justify-center shadow-lg shadow-indigo-600/20">
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
                          ? "bg-indigo-600 text-white shadow-lg shadow-indigo-600/20" 
                          : "text-zinc-500 hover:bg-indigo-50 hover:text-indigo-600"
                      )}
                    >
                      {isActive && (
                        <motion.div 
                          layoutId="sidebar-active"
                          className="absolute inset-0 bg-indigo-600 -z-10"
                        />
                      )}
                      <Icon size={20} strokeWidth={isActive ? 3 : 2.5} className={cn(
                        "transition-transform group-hover:scale-110",
                        isActive ? "text-white" : "text-zinc-400 group-hover:text-indigo-500"
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
      <div className="hidden sm:flex items-center gap-3 px-4 py-2 bg-indigo-50 border border-indigo-100 rounded-2xl">
        <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-xs font-bold ring-4 ring-white shadow-sm">
          {user?.email?.[0].toUpperCase()}
        </div>
        <div className="flex flex-col text-sm">
          <span className="font-semibold text-indigo-900 leading-none mb-0.5">{user?.email?.split('@')[0]}</span>
          <span className="text-[10px] text-indigo-500 font-bold uppercase tracking-wider">Super Admin</span>
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

// --- Pages ---

const Dashboard = () => {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/admin/stats').then(res => res.json()).then(data => {
      setStats(data);
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
    { title: 'People Registered', value: stats.totalUsers, icon: Users, color: 'text-indigo-600', bg: 'bg-indigo-50' },
    { title: 'Guest Conversations', value: stats.guestSessions, icon: Clock, color: 'text-emerald-600', bg: 'bg-emerald-50' },
    { title: 'E-Friend Conversations', value: stats.chatbotSessions, icon: MessageSquare, color: 'text-blue-600', bg: 'bg-blue-50' },
    { title: 'People Needing Urgent Care', value: stats.highRiskEscalations, icon: AlertTriangle, color: 'text-rose-600', bg: 'bg-rose-50' },
    { title: 'People Needing Support', value: stats.counselorCasesWaiting, icon: UserCheck, color: 'text-amber-600', bg: 'bg-amber-50' },
    { title: 'Whispers to Moderate', value: stats.communityPostsPending, icon: MessageSquare, color: 'text-violet-600', bg: 'bg-violet-50' },
  ];

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
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
              <h3 className="text-4xl font-display font-black text-zinc-900 tracking-tight">{card.value.toLocaleString()}</h3>
              <span className="text-xs font-bold text-emerald-500">+12%</span>
            </div>
          </Card>
        ))}
      </motion.div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <Card className="p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-display font-bold">Activity Pulse</h3>
            <div className="flex gap-2">
               <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-500">
                 <div className="w-3 h-3 rounded-full bg-indigo-500" />
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
                  <Bar dataKey="apps" fill="#6366f1" radius={[8, 8, 0, 0]} maxBarSize={32} />
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
    fetch('/api/emergency/contacts').then(res => res.json()).then(data => {
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
            className="w-full pl-12 pr-6 py-4 bg-white border border-zinc-200 rounded-2xl shadow-sm focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 focus:outline-none transition-all placeholder:text-zinc-400"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <button className="flex items-center justify-center gap-2 px-6 py-4 bg-indigo-600 text-white rounded-2xl font-bold shadow-lg shadow-indigo-600/20 hover:bg-indigo-700 hover:-translate-y-0.5 active:translate-y-0 transition-all">
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
                      {contact.isActive ? 'Active' : 'Offline'}
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button className="p-2.5 text-zinc-400 hover:text-indigo-600 hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-100 transition-all">
                        <Edit2 size={18} />
                      </button>
                      <button className="p-2.5 text-zinc-400 hover:text-rose-600 hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-100 transition-all">
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
    fetch('/api/resources').then(res => res.json()).then(setResources);
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
             <Plus size={20} strokeWidth={3} /> Create Resource
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
                  <h3 className="font-display font-black text-2xl tracking-tight">{editing.id ? 'Refine' : 'Compose'}</h3>
                  <button onClick={() => setEditing(null)} className="w-8 h-8 rounded-full bg-zinc-100 flex items-center justify-center text-zinc-400 hover:text-rose-600 transition-colors"><X size={18} strokeWidth={3} /></button>
                </div>
                
                <div className="space-y-8">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Resource Title</label>
                    <input autoFocus value={editing.title} onChange={e => setEditing({...editing, title: e.target.value})} className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl font-display font-bold text-lg focus:ring-4 focus:ring-indigo-100 outline-none transition-all" placeholder="Enter a catchy title..." />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Markdown Fabric</label>
                    <textarea 
                      rows={12} 
                      value={editing.content} 
                      onChange={e => setEditing({...editing, content: e.target.value})}
                      className="w-full p-4 bg-zinc-50 border border-zinc-200 rounded-xl font-mono text-xs leading-relaxed focus:ring-4 focus:ring-indigo-100 outline-none transition-all resize-none"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Pillar</label>
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
    fetch('/api/admin/faqs').then(res => res.json()).then(setFaqs);
  }, []);

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 bg-indigo-600 p-8 lg:p-12 rounded-[3.5rem] shadow-2xl relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full -translate-y-1/2 translate-x-1/2 blur-3xl pointer-events-none" />
        <div className="relative z-10">
          <h3 className="text-4xl font-display font-black text-white leading-tight">Gold FAQ Bank</h3>
          <p className="text-indigo-100 font-medium mt-1">High-quality, vetted answers for AI & Youth</p>
        </div>
        <button className="relative z-10 px-8 py-4 bg-white text-indigo-600 rounded-3xl font-black text-sm uppercase tracking-widest shadow-xl hover:scale-105 transition-transform active:scale-95">Add FAQ</button>
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
    fetch('/api/admin/safety-rules').then(res => res.json()).then(setRules);
  }, []);

  const handleTest = async () => {
    const res = await fetch('/api/admin/safety-rules/test', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: testMsg })
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
      fetch('/api/counselor/cases').then(res => res.json()).then(setCases);
    }, []);

    return (
      <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
           <h3 className="text-3xl font-display font-black text-zinc-900">Care & Connection Hub</h3>
           <div className="flex gap-3">
              <div className="px-5 py-2 bg-indigo-50 text-indigo-600 rounded-2xl text-sm font-bold flex items-center gap-2">
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
                   <select className="px-6 py-3.5 bg-zinc-50 border border-zinc-100 rounded-2xl text-sm font-bold shadow-sm focus:ring-4 focus:ring-indigo-100 outline-none">
                     <option>Unassigned</option>
                     <option>Dr. Mutambo (Active)</option>
                     <option>Sarah (Active)</option>
                   </select>
                   <button className="px-8 py-3.5 bg-zinc-900 text-white rounded-2xl font-display font-bold text-sm shadow-xl shadow-zinc-900/10 hover:-translate-y-1 active:translate-y-0 transition-transform">Enter Vault</button>
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
    fetch('/api/analytics/summary').then(res => res.json()).then(setData);
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
             <button className="px-6 py-3 bg-white border border-zinc-100 rounded-2xl text-xs font-black uppercase tracking-widest shadow-sm">May 2026</button>
          </div>
       </div>

       <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
         <Card className="p-10 bg-indigo-600 text-white border-none shadow-2xl shadow-indigo-100">
            <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-indigo-200 mb-8 flex items-center gap-2">
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
                  <div className="w-12 h-12 bg-indigo-50 rounded-2xl flex items-center justify-center text-indigo-600">
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

const Settings = () => (
  <div className="p-6 lg:p-10 max-w-4xl mx-auto space-y-16">
    <div className="space-y-12">
      <section>
        <h3 className="text-3xl font-display font-black text-zinc-900 flex items-center gap-3 mb-8 italic">
          <Shield className="text-indigo-600" size={32} strokeWidth={3} /> Governance Protocol
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
           <button className="px-10 py-4 bg-indigo-600 text-white rounded-3xl font-display font-black tracking-widest uppercase text-xs shadow-xl shadow-indigo-200">Audit Configuration</button>
        </div>
      </section>
    </div>
  </div>
)

// --- Auth Pages ---

const LoginPage = ({ onLogin }: { onLogin: (email: string) => void }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <div className="min-h-screen bg-[#FAFAFF] flex items-center justify-center p-6 sm:p-12 overflow-hidden relative font-sans">
      <div className="absolute top-0 right-0 w-96 h-96 bg-indigo-100 rounded-full blur-[100px] -translate-y-1/2 translate-x-1/3 opacity-50" />
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-rose-100 rounded-full blur-[100px] translate-y-1/2 -translate-x-1/3 opacity-50" />
      
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <Card className="w-full max-w-lg p-12 border-none shadow-2xl relative overflow-hidden bg-white/80 backdrop-blur-xl">
          <div className="text-center mb-12">
            <div className="w-16 h-16 bg-indigo-600 rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-xl shadow-indigo-200 group hover:rotate-12 transition-transform">
               <Shield className="text-white" size={32} />
            </div>
            <h1 className="text-4xl font-display font-black text-zinc-900 tracking-tight mb-2 uppercase italic">SISONKE</h1>
            <p className="text-zinc-500 font-medium tracking-tight">Admin Gateway • Wellness for Youth</p>
          </div>
          
          <form onSubmit={(e) => { e.preventDefault(); onLogin(email); }} className="space-y-6">
            <div className="space-y-2">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Email Command Center</label>
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
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Security Key</label>
              <div className="relative">
                 <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
                 <input 
                  type="password" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-indigo-100 focus:bg-white outline-none transition-all"
                  placeholder="••••••••"
                  required
                />
              </div>
            </div>
            <button 
              type="submit"
              className="w-full py-5 bg-zinc-900 text-white rounded-3xl font-display font-black text-lg shadow-xl shadow-zinc-900/20 hover:scale-[1.02] active:scale-95 transition-all"
            >
              Unlock Dashboard
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
  const { user, login, logout, isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <LoginPage onLogin={login} />;
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
        <Route path="/moderation" element={<AdminLayout title="Community Moderation" user={user} logout={logout}><div className="p-8 text-zinc-500">Moderation interface implementation...</div></AdminLayout>} />
        <Route path="/analytics" element={<AdminLayout title="Analytics" user={user} logout={logout}><Analytics /></AdminLayout>} />
        <Route path="/settings" element={<AdminLayout title="Settings" user={user} logout={logout}><Settings /></AdminLayout>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}
