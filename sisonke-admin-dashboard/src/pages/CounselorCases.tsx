import React, { useState, useEffect } from 'react';
import { ShieldAlert, UserCheck, Clock, Activity, AlertTriangle } from 'lucide-react';
import { motion } from 'motion/react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, EmptyState, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

function timeAgo(ts: number): string {
  const diff = Date.now() - ts;
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

export const CounselorCases: React.FC = () => {
  const [cases, setCases] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiFetch('/api/counselor/cases')
      .then(async (res) => {
        const payload = await res.json();
        if (!res.ok || !payload.success) throw new Error(payload.error || 'Cases could not be loaded.');
        setCases(payload.data ?? []);
      })
      .catch(() => setError('Care cases are currently unavailable.'))
      .finally(() => setLoading(false));
  }, []);

  if (loading)
    return (
      <div className="p-10 space-y-6 max-w-7xl mx-auto">
        {[1, 2, 3].map((i) => (
          <SkeletonCard key={i} />
        ))}
      </div>
    );

  if (error) return <EmptyState icon={AlertTriangle} title="Care cases unavailable" description={error} />;

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <h3 className="text-3xl font-display font-black text-zinc-900">Care & Connection Hub</h3>
        <div className="flex gap-3">
          <div className="px-5 py-2 bg-primary-dim text-primary rounded-2xl text-sm font-bold flex items-center gap-2">
            <Activity size={18} /> {cases.length} Active Cases
          </div>
        </div>
      </div>

      {cases.length === 0 ? (
        <EmptyState
          icon={UserCheck}
          title="No active cases"
          description="All incoming user support requests have been addressed."
        />
      ) : (
        <div className="grid gap-6">
          {cases.map((c) => (
            <motion.div key={c.id} whileHover={{ scale: 1.01 }}>
              <SisonkeCard className="p-8 border-none bg-white shadow-xl shadow-zinc-100/60 flex flex-col md:flex-row md:items-center justify-between gap-8">
                <div className="flex gap-6 items-start">
                  <div
                    className={cn(
                      'w-16 h-16 rounded-[2rem] flex items-center justify-center shadow-lg relative',
                      c.riskLevel === 'high'
                        ? 'bg-rose-500 text-white shadow-rose-200'
                        : 'bg-zinc-100 text-zinc-500 shadow-zinc-100'
                    )}
                  >
                    {c.riskLevel === 'high' ? <ShieldAlert size={32} strokeWidth={2.5} /> : <UserCheck size={32} strokeWidth={2.5} />}
                    <div className="absolute -top-1 -right-1 w-5 h-5 bg-white rounded-full flex items-center justify-center">
                      <div
                        className={cn(
                          'w-2.5 h-2.5 rounded-full',
                          c.riskLevel === 'high' ? 'bg-rose-500 animate-ping' : 'bg-zinc-300'
                        )}
                      />
                    </div>
                  </div>
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-black text-zinc-400 underline decoration-zinc-200 underline-offset-4">
                        SUPPORT LINK #{c.id?.slice(0, 8) || c.id}
                      </span>
                      <span
                        className={cn(
                          'px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-widest',
                          c.riskLevel === 'high' ? 'bg-rose-100 text-rose-700' : 'bg-zinc-100 text-zinc-500'
                        )}
                      >
                        {c.riskLevel} care priority
                      </span>
                    </div>
                    <h4 className="text-2xl font-display font-black text-zinc-900 line-clamp-1">{c.summary || c.notes || 'User requesting guidance'}</h4>
                    <div className="flex items-center gap-2 text-xs font-semibold text-zinc-400">
                      <Clock size={14} strokeWidth={3} />
                      {c.createdAt ? `Opened ${timeAgo(new Date(c.createdAt).getTime())}` : 'Opening time unavailable'}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <span className="px-5 py-3.5 bg-zinc-50 border border-zinc-100 rounded-2xl text-sm font-bold text-zinc-500">
                    {c.counselorId ? 'Assigned counselor' : 'Unassigned'}
                  </span>
                  <button
                    type="button"
                    className="px-6 py-3.5 bg-primary text-white rounded-2xl font-display font-bold text-sm hover:bg-primary-dark shadow-sm transition-all"
                  >
                    Open Case Flow
                  </button>
                </div>
              </SisonkeCard>
            </motion.div>
          ))}
        </div>
      )}
    </div>
  );
};
