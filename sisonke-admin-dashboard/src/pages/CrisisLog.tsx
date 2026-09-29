import React, { useState, useEffect } from 'react';
import { Clock, UserCheck, AlertTriangle, Check } from 'lucide-react';
import { motion } from 'motion/react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, PageHeader, EmptyState, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

type CrisisStatus = 'ESCALATED' | 'RESOLVED' | 'MONITORING';
type CrisisEvent = {
  id: string | number;
  ts: number;
  trigger: string;
  status: CrisisStatus;
  counselor?: string;
  responseMinutes: number;
};

function timeAgo(ts: number): string {
  const diff = Date.now() - ts;
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

const crisisStatusStyle: Record<CrisisStatus, { bg: string; text: string; dot: string }> = {
  ESCALATED: { bg: 'bg-[#FEE2E2]', text: 'text-[#F43F5E]', dot: 'bg-[#F43F5E]' },
  MONITORING: { bg: 'bg-[#FEF3C7]', text: 'text-[#F59E0B]', dot: 'bg-[#F59E0B]' },
  RESOLVED: { bg: 'bg-[#D1FAE5]', text: 'text-[#10B981]', dot: 'bg-[#10B981]' },
};

type CrisisFilter = 'all' | 'unresolved' | '24h' | '7d';

export const CrisisLog: React.FC = () => {
  const [events, setEvents] = useState<CrisisEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<CrisisFilter>('all');

  useEffect(() => {
    apiFetch('/api/admin/crisis-log')
      .then(async (res) => {
        const payload = await res.json();
        setEvents(Array.isArray(payload) ? payload : payload.data ?? []);
      })
      .catch(() => setError('The crisis response log is currently unavailable.'))
      .finally(() => setLoading(false));
  }, []);

  const filtered = events.filter((e) => {
    if (filter === 'unresolved') return e.status !== 'RESOLVED';
    if (filter === '24h') return Date.now() - e.ts < 1000 * 60 * 60 * 24;
    if (filter === '7d') return Date.now() - e.ts < 1000 * 60 * 60 * 24 * 7;
    return true;
  });

  const filters: { key: CrisisFilter; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'unresolved', label: 'Unresolved' },
    { key: '24h', label: 'Last 24h' },
    { key: '7d', label: 'Last 7 days' },
  ];

  if (loading)
    return (
      <div className="p-10 space-y-6 max-w-4xl mx-auto">
        {[1, 2, 3, 4].map((i) => (
          <SkeletonCard key={i} />
        ))}
      </div>
    );

  if (error) return <EmptyState icon={AlertTriangle} title="Crisis log unavailable" description={error} />;

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-4xl mx-auto">
      <PageHeader
        title="Crisis Response Log"
        subtitle="Chronological audit trail of high-risk events and counselor responses"
      />

      <div className="flex flex-wrap gap-2">
        {filters.map((f) => (
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
          const s = crisisStatusStyle[event.status] || crisisStatusStyle.MONITORING;
          return (
            <motion.div
              key={event.id}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: idx * 0.04 }}
              className="relative flex gap-5 pb-6 last:pb-0"
            >
              <div
                className={cn(
                  'relative z-10 w-6 h-6 rounded-full shrink-0 mt-4 border-2 border-white shadow-sm',
                  s.dot
                )}
              />
              <SisonkeCard className="flex-1 p-6 space-y-3">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <p className="text-zinc-700 font-semibold leading-snug flex-1 line-clamp-2">{event.trigger}</p>
                  <span
                    className={cn(
                      'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider shrink-0',
                      s.bg,
                      s.text
                    )}
                  >
                    <span className={cn('w-1.5 h-1.5 rounded-full', s.dot)} />
                    {event.status}
                  </span>
                </div>
                <div className="flex flex-wrap gap-4 text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
                  <span className="flex items-center gap-1">
                    <Clock size={12} strokeWidth={3} /> {timeAgo(event.ts)}
                  </span>
                  {event.counselor && (
                    <span className="flex items-center gap-1">
                      <UserCheck size={12} strokeWidth={3} /> {event.counselor}
                    </span>
                  )}
                  <span className="flex items-center gap-1">
                    <AlertTriangle size={12} strokeWidth={3} /> {event.responseMinutes}m response
                  </span>
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
