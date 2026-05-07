import React, { useState, useEffect } from 'react';
import { 
  Users, 
  MessageSquare, 
  ShieldAlert, 
  BookOpen, 
  AlertTriangle, 
  Activity, 
  Search, 
  Check, 
  X, 
  Plus, 
  ChevronRight, 
  LayoutDashboard, 
  Shield, 
  Settings as SettingsIcon,
  LogOut,
  Mail,
  Lock,
  PieChart,
  Tag,
  Globe,
  Clock,
  UserCheck,
  ChevronDown,
  Menu,
  MoreVertical,
  ArrowRight
} from 'lucide-react';
import { 
  BrowserRouter as Router, 
  Routes, 
  Route, 
  Navigate, 
  Link, 
  useLocation,
  useNavigate
} from 'react-router-dom';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  LineChart,
  Line
} from 'recharts';
import { motion, AnimatePresence } from 'framer-motion';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

// --- Utilities ---
function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const timeAgo = (date: string) => {
  const seconds = Math.floor((new Date().getTime() - new Date(date).getTime()) / 1000);
  let interval = seconds / 31536000;
  if (interval > 1) return Math.floor(interval) + "y ago";
  interval = seconds / 2592000;
  if (interval > 1) return Math.floor(interval) + "mo ago";
  interval = seconds / 86400;
  if (interval > 1) return Math.floor(interval) + "d ago";
  interval = seconds / 3600;
  if (interval > 1) return Math.floor(interval) + "h ago";
  interval = seconds / 60;
  if (interval > 1) return Math.floor(interval) + "m ago";
  return Math.floor(seconds) + "s ago";
};

const dayLabel = (dateStr: string) => {
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-US', { day: 'numeric', month: 'short' });
};

const emptyChart = (days: number) => Array.from({ length: days }).map((_, i) => ({
  name: '',
  appUse: 0,
  urgent: 0,
}));

const LIVE_POLL_MS = 2000;

// --- API Service ---
const apiFetch = async (endpoint: string, options: any = {}) => {
  const token = localStorage.getItem('auth_token');
  const response = await fetch(endpoint, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      ...options.headers,
    },
  });
  if (response.status === 401) {
    localStorage.removeItem('auth_token');
    window.location.href = '/';
  }
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || 'Something went wrong');
  return data.data;
};

// --- Auth Hook ---
const useAuth = () => {
  const [user, setUser] = useState<any>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(Boolean(localStorage.getItem('auth_token')));

  useEffect(() => {
    if (isAuthenticated) {
      apiFetch('/api/auth/me')
        .then(data => setUser(data))
        .catch(() => setIsAuthenticated(false));
    }
  }, [isAuthenticated]);

  const login = async (email: string, password: string) => {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.error || 'Login failed');
    
    // Check for staff permissions
    const staffRoles = [
      'admin', 
      'super-admin', 
      'system-admin', 
      'counselor', 
      'counsellor', 
      'moderator', 
      'content-manager', 
      'content-admin', 
      'safety-reviewer', 
      'analyst',
      'user'
    ];
    const roles = data.data.user.roles || [];
    const isStaff = roles.some((r: string) => staffRoles.includes(r));
    
    if (!isStaff) throw new Error('Access denied. This portal is for support staff only.');
    
    localStorage.setItem('auth_token', data.data.token);
    setUser(data.data.user);
    setIsAuthenticated(true);
  };

  const logout = () => {
    localStorage.removeItem('auth_token');
    setUser(null);
    setIsAuthenticated(false);
  };

  const finishPasswordChange = () => {
    if (user) setUser({ ...user, mustChangePassword: false });
  };

  return { user, login, logout, isAuthenticated, finishPasswordChange };
};

const hasAny = (user: any, roles: string[]) => {
  if (!user || !user.roles) return false;
  return user.roles.some((r: string) => roles.includes(r));
};

// --- Base Components ---
const Card = ({ children, className }: any) => (
  <div className={cn("bg-white border border-zinc-100 rounded-[2rem] transition-all", className)}>
    {children}
  </div>
);

const Sidebar = ({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) => {
  const location = useLocation();
  const { user } = useAuth();
  
  const navItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Reports', path: '/analytics', icon: PieChart, roles: ['admin', 'super-admin', 'system-admin', 'analyst'] },
    { name: 'Support', path: '/cases', icon: MessageSquare, roles: ['admin', 'super-admin', 'system-admin', 'counselor', 'counsellor'] },
    { name: 'Resources', path: '/resources', icon: BookOpen, roles: ['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin'] },
    { name: 'Questions', path: '/faq', icon: Globe, roles: ['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin', 'counselor', 'counsellor'] },
    { name: 'Community', path: '/moderation', icon: Users, roles: ['admin', 'super-admin', 'system-admin', 'moderator'] },
    { name: 'Safety', path: '/safety', icon: ShieldAlert, roles: ['admin', 'super-admin', 'system-admin', 'safety-reviewer'] },
    { name: 'People', path: '/users', icon: Users, roles: ['admin', 'super-admin', 'system-admin'] },
    { name: 'Settings', path: '/settings', icon: SettingsIcon },
  ];

  const visibleItems = navItems.filter(item => !item.roles || hasAny(user, item.roles));

  return (
    <>
      <AnimatePresence>
        {isOpen && (
          <motion.div 
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-zinc-900/40 backdrop-blur-sm z-[40] lg:hidden" 
          />
        )}
      </AnimatePresence>
      
      <div className={cn(
        "fixed top-0 left-0 bottom-0 w-72 bg-white border-r border-zinc-100 z-[50] flex flex-col transition-transform lg:translate-x-0",
        isOpen ? "translate-x-0" : "-translate-x-full"
      )}>
        <div className="p-8 flex items-center gap-4">
          <div className="w-10 h-10 overflow-hidden rounded-xl bg-white shadow-sm border border-zinc-50">
             <img src="/sisonke-logo.png" alt="Sisonke" className="w-full h-full object-contain" />
          </div>
          <h1 className="text-xl font-display font-black text-zinc-900 tracking-tight italic uppercase">Sisonke</h1>
        </div>
        
        <nav className="flex-1 px-4 py-6 space-y-1">
          {visibleItems.map(item => {
            const active = location.pathname === item.path;
            return (
              <Link key={item.path} to={item.path} onClick={() => onClose()}>
                <motion.div 
                  whileHover={{ x: 4 }}
                  className={cn(
                    "flex items-center gap-4 px-5 py-4 rounded-2xl font-bold text-sm transition-all",
                    active ? "bg-indigo-600 text-white shadow-xl shadow-indigo-100" : "text-zinc-500 hover:bg-zinc-50"
                  )}
                >
                  <item.icon size={20} strokeWidth={active ? 3 : 2} />
                  {item.name}
                </motion.div>
              </Link>
            );
          })}
        </nav>

        <div className="p-8 bg-zinc-50/50">
           <div className="p-5 bg-white rounded-3xl border border-zinc-100 shadow-sm flex items-center gap-3">
              <div className="w-10 h-10 bg-emerald-100 text-emerald-700 rounded-2xl flex items-center justify-center font-black">
                {(user as any)?.email?.[0].toUpperCase() || 'A'}
              </div>
              <div className="flex flex-col min-w-0">
                 <span className="text-xs font-black text-zinc-900 truncate">{(user as any)?.email}</span>
                 <span className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest">Active</span>
              </div>
           </div>
        </div>
      </div>
    </>
  );
};

const TopBar = ({ title, user, onLogout, onMenuOpen }: any) => (
  <header className="h-20 bg-white/80 backdrop-blur-md border-b border-zinc-100 px-8 flex items-center justify-between sticky top-0 z-[30]">
    <div className="flex items-center gap-4">
      <button onClick={onMenuOpen} className="p-2 lg:hidden text-zinc-400"><Menu /></button>
      <h2 className="text-xl font-display font-black text-zinc-900">{title}</h2>
    </div>
    <div className="flex items-center gap-6">
       <button onClick={onLogout} className="flex items-center gap-2 px-5 py-2.5 bg-zinc-900 text-white rounded-2xl text-xs font-black hover:scale-105 active:scale-95 transition-all">
         <LogOut size={14} strokeWidth={3} /> Sign out
       </button>
    </div>
  </header>
);

const SisonkeLogo = ({ className }: { className?: string }) => (
  <div className={cn("bg-white overflow-hidden flex items-center justify-center", className)}>
    <img src="/sisonke-logo.png" alt="Sisonke Logo" className="w-full h-full object-contain" />
  </div>
);

// --- Page Components ---

const Home = () => {
  const [stats, setStats] = useState<any>(null);
  useEffect(() => {
    apiFetch('/api/admin/overview').then(data => setStats(data));
  }, []);

  if (!stats) return null;

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <div className="bg-indigo-600 p-10 lg:p-16 rounded-[4rem] shadow-2xl relative overflow-hidden group">
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-white/5 rounded-full -translate-y-1/2 translate-x-1/4 blur-3xl pointer-events-none" />
        <div className="relative z-10 space-y-4">
          <h1 className="text-4xl lg:text-6xl font-display font-black text-white leading-tight">Welcome to the<br />Sisonke Command Center.</h1>
          <p className="text-indigo-100 text-lg lg:text-xl font-medium max-w-xl">Real-time youth safety monitoring and resource management for Zimbabwe.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
        {[
          { label: 'Total Users', value: stats.users.total, color: 'bg-emerald-50 text-emerald-700' },
          { label: 'High Risk Alerts', value: stats.counselorCases.highRisk, color: 'bg-rose-50 text-rose-700' },
          { label: 'Support Requests', value: stats.counselorCases.total, color: 'bg-indigo-50 text-indigo-700' },
          { label: 'Pending Posts', value: stats.communityPosts.pending, color: 'bg-amber-50 text-amber-700' },
        ].map((item, i) => (
          <motion.div key={i} whileHover={{ y: -5 }}>
            <Card className="p-8 h-full flex flex-col justify-between">
              <span className="text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 mb-8">{item.label}</span>
              <div className="flex items-end justify-between">
                <span className="text-4xl font-display font-black text-zinc-900">{item.value}</span>
                <div className={cn("px-4 py-2 rounded-2xl text-[10px] font-black uppercase tracking-widest", item.color)}>
                  Active
                </div>
              </div>
            </Card>
          </motion.div>
        ))}
      </div>

      {stats.latestEvents && stats.latestEvents.length > 0 && (
        <Card className="p-10">
          <h3 className="text-2xl font-display font-black text-zinc-900 mb-8">Latest activity</h3>
          <div className="space-y-6">
            {stats.latestEvents.map((ev: any, i: number) => (
              <div key={i} className="flex items-center justify-between py-4 border-b border-zinc-50 last:border-0">
                <div className="flex items-center gap-5">
                   <div className="w-12 h-12 bg-zinc-50 rounded-2xl flex items-center justify-center text-zinc-400">
                     <Activity size={20} strokeWidth={3} />
                   </div>
                   <div className="flex flex-col">
                     <span className="font-bold text-zinc-800">{ev.eventType}</span>
                     <span className="text-xs text-zinc-400">{timeAgo(ev.occurredAt)}</span>
                   </div>
                </div>
                <div className="px-4 py-1.5 bg-zinc-50 rounded-xl text-[10px] font-black text-zinc-400 uppercase tracking-widest">Logged</div>
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
};

const EmergencyContacts = () => {
  const [contacts, setContacts] = useState<any[]>([]);
  useEffect(() => {
    apiFetch('/api/admin/emergency-contacts').then(data => setContacts(Array.isArray(data) ? data : []));
  }, []);

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div>
          <h3 className="text-3xl font-display font-black text-zinc-900">Help Hotlines</h3>
          <p className="text-zinc-500 font-medium">Zimbabwe's critical support network for youth.</p>
        </div>
        <button className="flex items-center gap-2 px-6 py-3.5 bg-zinc-900 text-white rounded-2xl text-sm font-black shadow-xl shadow-zinc-900/20 active:scale-95 transition-all">
          <Plus size={18} strokeWidth={3} /> Add contact
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
        {contacts.map(contact => (
          <motion.div key={contact.id} whileHover={{ y: -5 }}>
            <Card className="p-8 h-full flex flex-col">
              <div className="flex items-start justify-between mb-8">
                <div className="w-14 h-14 bg-rose-50 text-rose-600 rounded-2xl flex items-center justify-center shadow-inner">
                  <ShieldAlert size={28} strokeWidth={2.5} />
                </div>
                <span className="px-3 py-1 bg-zinc-100 rounded-full text-[9px] font-black text-zinc-500 uppercase tracking-widest">{contact.category}</span>
              </div>
              <h4 className="text-xl font-display font-black text-zinc-900 mb-2">{contact.name}</h4>
              <p className="text-sm text-zinc-500 font-medium flex-1 mb-8 leading-relaxed">{contact.description}</p>
              <div className="p-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-black text-indigo-600 text-center text-lg shadow-sm">
                {contact.phoneNumber}
              </div>
            </Card>
          </motion.div>
        ))}
      </div>
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
    <div className="p-6 lg:p-10 grid grid-cols-1 xl:grid-cols-[1fr_450px] gap-10 max-w-7xl mx-auto">
      <div className="space-y-10">
        <div className="flex items-center justify-between">
          <h3 className="text-3xl font-display font-black text-zinc-900">Resource Library</h3>
          <button 
            onClick={() => setEditing({ title: '', category: 'mental-health', isPublished: true, content: '' })}
            className="w-12 h-12 bg-zinc-900 text-white rounded-2xl flex items-center justify-center shadow-xl shadow-zinc-900/20 active:scale-90 transition-all"
          >
            <Plus size={24} strokeWidth={3} />
          </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {resources.map(res => (
            <motion.div key={res.id} whileHover={{ y: -4 }}>
              <Card 
                onClick={() => setEditing(res)}
                className={cn(
                  "p-8 cursor-pointer group hover:border-indigo-200 hover:shadow-2xl hover:shadow-indigo-100/50",
                  editing?.id === res.id && "border-indigo-600 bg-indigo-50/20"
                )}
              >
                <div className="flex items-start justify-between mb-6">
                  <div className="w-12 h-12 bg-zinc-50 group-hover:bg-indigo-600 transition-colors rounded-2xl flex items-center justify-center text-zinc-400 group-hover:text-white">
                    <BookOpen size={24} strokeWidth={3} />
                  </div>
                  <span className={cn(
                    "px-3 py-1 rounded-full text-[9px] font-black uppercase tracking-widest shadow-sm",
                    res.status === 'published' ? "bg-emerald-500 text-white" : "bg-zinc-100 text-zinc-400"
                  )}>
                    {res.status}
                  </span>
                </div>
                <h4 className="text-xl font-display font-black text-zinc-900 leading-tight mb-2 group-hover:text-indigo-600 transition-colors">{res.title}</h4>
                <p className="text-xs text-zinc-400 font-bold uppercase tracking-widest">{res.category}</p>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>

      <div className="space-y-10">
        <AnimatePresence mode="wait">
          {editing ? (
            <motion.div key="editor" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 20 }}>
              <Card className="p-10 bg-white shadow-2xl border-none space-y-10 sticky top-24">
                <div className="flex items-center justify-between">
                  <h4 className="text-2xl font-display font-black text-zinc-900">Resource Editor</h4>
                  <button onClick={() => setEditing(null)} className="p-2 text-zinc-300 hover:text-zinc-900"><X /></button>
                </div>
                <div className="space-y-8">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Resource Title</label>
                    <input 
                      value={editing.title} 
                      onChange={e => setEditing({...editing, title: e.target.value})} 
                      className="w-full px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold text-lg focus:ring-4 focus:ring-indigo-100 outline-none transition-all"
                      placeholder="e.g. Managing Stress"
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
                 </div>
               </div>
            </Card>
          </motion.div>
        ))}
      </div>
    </div>
  );
};

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
        <div className="bg-white p-12 rounded-[3.5rem] shadow-2xl border-2 border-dashed border-zinc-100 space-y-10">
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
    const { user } = useAuth();
    const [cases, setCases] = useState<any[]>([]);
    const [activeChat, setActiveChat] = useState<any>(null);
    const [counselors, setCounselors] = useState<any[]>([]);
    const [syncError, setSyncError] = useState('');
    const loadCases = () => apiFetch('/api/admin/counselor-cases').then(data => setCases(Array.isArray(data) ? data : []));

    // Messaging Integration State & Handlers
    const [messages, setMessages] = useState<any[]>([]);
    const [inputText, setInputText] = useState('');
    const chatEndRef = React.useRef<HTMLDivElement>(null);

    const loadMessages = (caseId: string) => {
      return apiFetch(`/api/admin/counselor-cases/${caseId}/messages`)
        .then(data => {
          if (Array.isArray(data)) {
            setMessages(data);
          }
        })
        .catch(() => {});
    };

    useEffect(() => {
      if (!activeChat) {
        setMessages([]);
        return;
      }
      
      loadMessages(activeChat.id);
      
      const interval = window.setInterval(() => {
        if (document.visibilityState === 'visible') {
          loadMessages(activeChat.id);
        }
      }, 2000);

      return () => {
        window.clearInterval(interval);
      };
    }, [activeChat]);

    useEffect(() => {
      if (chatEndRef.current) {
        chatEndRef.current.scrollTop = chatEndRef.current.scrollHeight;
      }
    }, [messages]);

    const handleSendMessage = async () => {
      if (!inputText.trim() || !activeChat) return;
      const text = inputText;
      setInputText('');
      try {
        const response = await apiFetch(`/api/admin/counselor-cases/${activeChat.id}/messages`, {
          method: 'POST',
          body: JSON.stringify({ content: text, messageType: 'text' })
        });
        if (response && response.success && response.data) {
          setMessages(prev => [...prev, response.data]);
        }
      } catch (err) {
        console.error('Failed to send message:', err);
      }
    };
    
    const isAdmin = hasAny(user, ['admin', 'super-admin', 'system-admin']);

    useEffect(() => {
      let mounted = true;
      const refresh = () => loadCases()
        .then(() => {
          if (mounted) setSyncError('');
        })
        .catch((error) => {
          if (mounted) setSyncError(error.message || 'Could not refresh support requests.');
        });

      refresh();
      const interval = window.setInterval(() => {
        if (document.visibilityState === 'visible') refresh();
      }, LIVE_POLL_MS);

      if (isAdmin) {
        apiFetch('/api/admin/users')
          .then(data => {
            if (Array.isArray(data)) {
              const filtered = data.filter((u: any) => {
                const rNames = (u.roles || []).map((r: string) => r.toLowerCase().replace(/_/g, '-'));
                return rNames.some((role: string) => ['counselor', 'counsellor', 'admin', 'super-admin', 'system-admin'].includes(role));
              });
              setCounselors(filtered);
            }
          })
          .catch(() => {});
      }

      return () => {
        mounted = false;
        window.clearInterval(interval);
      };
    }, [user, isAdmin]);

    const isAssignedToMe = (c: any) => c.counselorId === (user as any)?.id;

    return (
      <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
           <h3 className="text-3xl font-display font-black text-zinc-900">Open support requests</h3>
           <div className="flex gap-3">
               <div className="px-5 py-2 bg-emerald-50 text-emerald-700 rounded-2xl text-sm font-bold flex items-center gap-2">
                <Activity size={18} /> Live every 2s
              </div>
               <div className="px-5 py-2 bg-indigo-50 text-indigo-600 rounded-2xl text-sm font-bold flex items-center gap-2">
                <Activity size={18} /> {cases.length} open
              </div>
           </div>
        </div>
        {syncError && (
          <div className="p-4 bg-rose-50 text-rose-700 rounded-2xl font-bold">
            {syncError}
          </div>
        )}
        
        <div className="grid gap-6">
          {cases.map(c => (
            <motion.div key={c.id} whileHover={{ scale: 1.01 }}>
              <Card className={cn(
                "p-8 border-none shadow-xl flex flex-col md:flex-row md:items-center justify-between gap-8",
                isAssignedToMe(c) ? "bg-indigo-50/30 ring-2 ring-indigo-500/10 shadow-indigo-100" : "bg-white shadow-zinc-100/60"
              )}>
                <div className="flex gap-6 items-start">
                  <div className={cn(
                    "w-16 h-16 rounded-[2rem] flex items-center justify-center shadow-lg relative",
                    c.riskLevel === 'high' ? "bg-rose-500 text-white shadow-rose-200" : 
                    isAssignedToMe(c) ? "bg-indigo-600 text-white shadow-indigo-200" : "bg-zinc-100 text-zinc-500 shadow-zinc-100"
                  )}>
                    {c.riskLevel === 'high' ? <ShieldAlert size={32} strokeWidth={2.5} /> : <UserCheck size={32} strokeWidth={2.5} />}
                    <div className="absolute -top-1 -right-1 w-5 h-5 bg-white rounded-full flex items-center justify-center">
                       <div className={cn("w-2.5 h-2.5 rounded-full", c.riskLevel === 'high' ? "bg-rose-500 animate-ping" : isAssignedToMe(c) ? "bg-indigo-500" : "bg-zinc-300")} />
                    </div>
                  </div>
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-black text-zinc-400 underline decoration-zinc-200 underline-offset-4 uppercase">
                        {isAssignedToMe(c) ? 'Your Case' : `Case #${c.id.substring(0,8)}`}
                      </span>
                      <span className={cn(
                        "px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-widest",
                        c.riskLevel === 'high' ? "bg-rose-100 text-rose-700" : "bg-zinc-100 text-zinc-500"
                      )}>
                        {c.riskLevel} level
                      </span>
                      {c.counselorId && (
                        <span className="px-2.5 py-0.5 rounded-lg bg-indigo-50 text-indigo-700 text-[9px] font-black uppercase tracking-widest">
                          Assigned to: {counselors.find(cn => cn.id === c.counselorId)?.email || `ID: ${c.counselorId.substring(0,8)}`}
                        </span>
                      )}
                    </div>
                    <h4 className="text-2xl font-display font-black text-zinc-900 line-clamp-1">{c.summary || c.issueCategory}</h4>
                    <div className="flex items-center gap-4 text-xs font-semibold text-zinc-400">
                      <div className="flex items-center gap-1">
                        <Clock size={14} strokeWidth={3} />
                        Opened {timeAgo(c.createdAt)}
                      </div>
                      <div className="flex items-center gap-1">
                        <Tag size={14} strokeWidth={3} />
                        {c.issueCategory}
                      </div>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                   {isAssignedToMe(c) && (
                     <button 
                       onClick={() => setActiveChat(c)}
                       className="px-6 py-3.5 bg-indigo-600 text-white rounded-2xl text-sm font-black shadow-lg shadow-indigo-600/20 hover:bg-indigo-700 transition-all flex items-center gap-2"
                     >
                       <MessageSquare size={18} strokeWidth={3} /> Live Chat
                     </button>
                   )}
                   {isAdmin && (
                     <select
                       value={c.counselorId || ''}
                       onChange={async (event) => {
                         await apiFetch(`/api/admin/counselor-cases/${c.id}/assign`, {
                           method: 'POST',
                           body: JSON.stringify({ counselorId: event.target.value }),
                         });
                         await loadCases();
                       }}
                       className="px-6 py-3.5 bg-zinc-50 border border-zinc-100 rounded-2xl text-sm font-bold shadow-sm focus:ring-4 focus:ring-indigo-100 outline-none"
                     >
                       <option value="">-- Assign Counselor --</option>
                       {counselors.map((cn) => (
                         <option key={cn.id} value={cn.id}>
                           {cn.email}
                         </option>
                       ))}
                     </select>
                   )}
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
                     <option value="requested">New Request</option>
                     <option value="assigned">Assigned</option>
                     <option value="live">In Chat</option>
                     <option value="resolved">Resolved</option>
                     <option value="closed">Closed</option>
                   </select>
                </div>
              </Card>
            </motion.div>
          ))}
        </div>

        {activeChat && (
          <div className="fixed inset-0 bg-zinc-900/40 backdrop-blur-md z-[100] flex items-center justify-center p-6">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="bg-white w-full max-w-2xl h-[600px] rounded-[3rem] shadow-2xl flex flex-col overflow-hidden"
            >
              <div className="p-8 border-b border-zinc-100 flex items-center justify-between bg-zinc-50/50">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-indigo-600 rounded-2xl flex items-center justify-center text-white">
                    <MessageSquare size={24} strokeWidth={3} />
                  </div>
                  <div>
                    <h3 className="font-display font-black text-xl text-zinc-900 leading-tight">Live Support</h3>
                    <p className="text-xs font-bold text-zinc-400 uppercase tracking-widest">Case #{activeChat.id.substring(0,8)}</p>
                  </div>
                </div>
                <button 
                  onClick={() => setActiveChat(null)}
                  className="w-10 h-10 bg-white border border-zinc-100 rounded-xl flex items-center justify-center text-zinc-400 hover:text-rose-600 transition-colors"
                >
                  <X size={20} strokeWidth={3} />
                </button>
              </div>
              <div ref={chatEndRef} className="flex-1 p-8 overflow-y-auto bg-zinc-50/30 space-y-4 flex flex-col">
                {messages.length === 0 ? (
                  <div className="flex-1 flex flex-col items-center justify-center text-center space-y-4">
                    <div className="w-16 h-16 bg-zinc-100 rounded-full flex items-center justify-center text-zinc-300">
                      <MessageSquare size={32} />
                    </div>
                    <h4 className="text-xl font-display font-bold text-zinc-400">No messages yet</h4>
                    <p className="text-sm text-zinc-400 max-w-xs">You can start the conversation by sending a message below.</p>
                  </div>
                ) : (
                  messages.map((msg: any) => {
                    const isMe = msg.senderUserId === user?.id || ['counselor', 'admin', 'system-admin', 'super-admin'].includes(String(msg.senderRole).toLowerCase());
                    return (
                      <div key={msg.id} className={cn("max-w-[75%] p-4 rounded-2xl text-sm font-semibold shadow-sm flex flex-col space-y-1", 
                        isMe ? "bg-indigo-600 text-white self-end rounded-tr-none" : "bg-white text-zinc-800 self-start rounded-tl-none border border-zinc-100"
                      )}>
                        <span>{msg.content}</span>
                        {msg.messageType === 'voice_note' && (
                          <div className={cn("mt-3 p-4 rounded-3xl flex flex-col gap-3 min-w-[260px] border", 
                            isMe ? "bg-white/10 border-white/20 text-white" : "bg-zinc-50 border-zinc-100 text-zinc-800"
                          )}>
                            <div className="flex items-center gap-3">
                              <div className={cn("w-10 h-10 rounded-full flex items-center justify-center shrink-0 shadow-sm",
                                isMe ? "bg-white/20 text-white" : "bg-indigo-50 text-indigo-600"
                              )}>
                                <Activity size={18} strokeWidth={2.5} className="animate-pulse" />
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="text-xs font-black uppercase tracking-wider opacity-80">Voice Note Message</p>
                                <p className="text-[10px] opacity-60">Play/pause to listen</p>
                              </div>
                            </div>
                            <audio 
                              controls 
                              src={msg.mediaUrl && msg.mediaUrl.startsWith('http') ? msg.mediaUrl : "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"} 
                              className={cn("w-full h-8 outline-none mt-1", isMe ? "brightness-95 contrast-125" : "")} 
                            />
                          </div>
                        )}
                        <span className={cn("text-[10px] self-end font-bold", isMe ? "text-indigo-200" : "text-zinc-400")}>
                          {new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </span>
                      </div>
                    );
                  })
                )}
              </div>
              <div className="p-8 bg-white border-t border-zinc-100">
                 <form onSubmit={(e) => { e.preventDefault(); handleSendMessage(); }} className="flex gap-4">
                    <input 
                      type="text" 
                      placeholder="Type your message..." 
                      className="flex-1 px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold outline-none focus:ring-4 focus:ring-indigo-100 transition-all"
                      value={inputText}
                      onChange={e => setInputText(e.target.value)}
                    />
                    <button type="submit" className="px-8 py-4 bg-zinc-900 text-white rounded-2xl font-black shadow-lg shadow-zinc-900/20">Send</button>
                 </form>
              </div>
            </motion.div>
          </div>
        )}
      </div>
    );
};

const CommunityPosts = () => {
  const [posts, setPosts] = useState<any[]>([]);
  const [message, setMessage] = useState('');
  const [syncError, setSyncError] = useState('');

  const loadPosts = () => apiFetch('/api/admin/community-posts').then(data => setPosts(Array.isArray(data) ? data : []));

  useEffect(() => {
    let mounted = true;
    const refresh = () => loadPosts()
      .then(() => {
        if (mounted) setSyncError('');
      })
      .catch((error) => {
        if (mounted) setSyncError(error.message || 'Could not refresh community posts.');
      });

    refresh();
    const interval = window.setInterval(() => {
      if (document.visibilityState === 'visible') refresh();
    }, LIVE_POLL_MS);

    return () => {
      mounted = false;
      window.clearInterval(interval);
    };
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
          {pending.length} waiting · live every 2s
        </div>
      </div>

      {message && <div className="p-4 bg-emerald-50 text-emerald-700 rounded-2xl font-bold">{message}</div>}
      {syncError && <div className="p-4 bg-rose-50 text-rose-700 rounded-2xl font-bold">{syncError}</div>}

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
  const blankForm = { id: '', email: '', name: '', avatarUrl: '', password: '', roles: ['user'], mustChangePassword: true, isSuspended: false };
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
      name: person.name || '',
      avatarUrl: person.avatarUrl || '',
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

    try {
      if (form.id) {
        await apiFetch(`/api/admin/users/${form.id}`, {
          method: 'PUT',
          body: JSON.stringify({
            email: form.email,
            name: form.name || null,
            avatarUrl: form.avatarUrl || null,
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
            name: form.name || undefined,
            avatarUrl: form.avatarUrl || undefined,
            roles: form.roles,
            mustChangePassword: form.mustChangePassword,
          }),
        });
        setMessage('Person added.');
      }
      setForm(blankForm);
      await loadPeople();
    } catch (err: any) {
      setMessage(err?.message || 'Failed to save person.');
    }
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
              <label className="text-xs font-bold text-zinc-500">Full Name</label>
              <input className="w-full px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl outline-none focus:ring-4 focus:ring-indigo-100" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} placeholder="e.g. Brian Magagula" type="text" />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-zinc-500">Profile Picture URL</label>
              <input className="w-full px-4 py-3 bg-zinc-50 border border-zinc-100 rounded-2xl outline-none focus:ring-4 focus:ring-indigo-100" value={form.avatarUrl} onChange={e => setForm({ ...form, avatarUrl: e.target.value })} placeholder="e.g. https://domain.com/pic.jpg" type="url" />
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
                    <div className="flex items-center gap-3">
                      {person.avatarUrl ? (
                        <img src={person.avatarUrl} alt={person.name || person.email} className="w-10 h-10 rounded-full object-cover shrink-0 border border-zinc-100" />
                      ) : (
                        <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-indigo-500 to-purple-500 text-white flex items-center justify-center font-bold text-sm shrink-0 shadow-sm">
                          {(person.name || person.email || '?').charAt(0).toUpperCase()}
                        </div>
                      )}
                      <div>
                        <div className="font-bold text-zinc-900 flex items-center gap-2">
                          {person.name && <span>{person.name}</span>}
                          {person.name && <span className="text-zinc-400 font-normal text-xs">({person.email})</span>}
                          {!person.name && <span>{person.email || 'Guest user'}</span>}
                        </div>
                        <div className="text-xs text-zinc-400 font-medium">
                          {person.isSuspended ? (
                            <span className="text-rose-500 font-bold">Paused</span>
                          ) : (
                            <span className="text-emerald-600 font-bold">Active</span>
                          )}
                        </div>
                      </div>
                    </div>
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
            <div className="w-24 h-24 mx-auto mb-6 rounded-3xl overflow-hidden shadow-xl border border-zinc-50">
               <img src="/sisonke-logo.png" alt="Sisonke" className="w-full h-full object-cover" />
            </div>
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

// --- Frontend Router Role Guard ---

const ProtectedRoute = ({ children, roles, title, user, logout }: any) => {
  const hasAccess = !roles || hasAny(user, roles);
  if (!hasAccess) {
    return <Navigate to="/" replace />;
  }
  return (
    <AdminLayout title={title} user={user} logout={logout}>
      {children}
    </AdminLayout>
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
        <Route path="/" element={<ProtectedRoute title="Home" user={user} logout={logout}><Home /></ProtectedRoute>} />
        <Route path="/emergency" element={<ProtectedRoute title="Help Contacts" roles={['admin', 'super-admin', 'system-admin']} user={user} logout={logout}><EmergencyContacts /></ProtectedRoute>} />
        <Route path="/resources" element={<ProtectedRoute title="Resources" roles={['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']} user={user} logout={logout}><ResourcesCMS /></ProtectedRoute>} />
        <Route path="/faq" element={<ProtectedRoute title="Questions" roles={['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin', 'counselor', 'counsellor']} user={user} logout={logout}><FAQBank /></ProtectedRoute>} />
        <Route path="/safety" element={<ProtectedRoute title="Safety Rules" roles={['admin', 'super-admin', 'system-admin', 'safety-reviewer']} user={user} logout={logout}><SafetyRules /></ProtectedRoute>} />
        <Route path="/cases" element={<ProtectedRoute title="Support Requests" roles={['admin', 'super-admin', 'system-admin', 'counselor', 'counsellor']} user={user} logout={logout}><CounselorCases /></ProtectedRoute>} />
        <Route path="/users" element={<ProtectedRoute title="People" roles={['admin', 'super-admin', 'system-admin']} user={user} logout={logout}><People /></ProtectedRoute>} />
        <Route path="/moderation" element={<ProtectedRoute title="Community Posts" roles={['admin', 'super-admin', 'system-admin', 'moderator']} user={user} logout={logout}><CommunityPosts /></ProtectedRoute>} />
        <Route path="/analytics" element={<ProtectedRoute title="Reports" roles={['admin', 'super-admin', 'system-admin', 'analyst']} user={user} logout={logout}><Reports /></ProtectedRoute>} />
        <Route path="/settings" element={<ProtectedRoute title="Settings" user={user} logout={logout}><Settings /></ProtectedRoute>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}
