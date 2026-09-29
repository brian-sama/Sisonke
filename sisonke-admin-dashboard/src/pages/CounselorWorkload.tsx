import React, { useState, useEffect } from 'react';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip } from 'recharts';
import { Users } from 'lucide-react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, PageHeader, EmptyState, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

type WorkloadRow = {
  id: string | number;
  name: string;
  role: string;
  activeCases: number;
  avgResponseHours: number;
  escalationRate: number;
};

export const CounselorWorkload: React.FC = () => {
  const [counselors, setCounselors] = useState<WorkloadRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiFetch('/api/admin/counselor-workload')
      .then(async (res) => {
        const payload = await res.json();
        setCounselors(Array.isArray(payload) ? payload : payload.data ?? []);
      })
      .catch(() => setError('Counselor workload is currently unavailable.'))
      .finally(() => setLoading(false));
  }, []);

  const statusDot = (activeCases: number) => {
    if (activeCases < 5) return 'bg-emerald-500';
    if (activeCases <= 10) return 'bg-amber-400';
    return 'bg-rose-500';
  };

  const chartData = counselors.map((c) => ({ name: c.name.split(' ')[0], cases: c.activeCases }));

  if (loading)
    return (
      <div className="p-10 space-y-6 max-w-7xl mx-auto">
        {[1, 2, 3].map((i) => (
          <SkeletonCard key={i} />
        ))}
      </div>
    );

  if (error) return <EmptyState icon={Users} title="Workload unavailable" description={error} />;

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <PageHeader title="Counselor Workload" subtitle="Active caseloads, response times, and escalation rates" />

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {counselors.map((c) => (
          <SisonkeCard key={c.id} className="p-6 space-y-5">
            <div className="flex items-start justify-between">
              <div>
                <h4 className="font-display font-black text-zinc-900 text-lg leading-tight">{c.name}</h4>
                <p className="text-xs text-zinc-500 font-medium mt-0.5">{c.role}</p>
              </div>
              <span
                className={cn('w-3 h-3 rounded-full mt-1 shrink-0', statusDot(c.activeCases))}
                title={`${c.activeCases} active cases`}
              />
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
                <span
                  className={cn(
                    c.escalationRate > 20
                      ? 'text-rose-500'
                      : c.escalationRate > 10
                      ? 'text-amber-500'
                      : 'text-emerald-600'
                  )}
                >
                  {c.escalationRate}%
                </span>
              </div>
              <div className="w-full h-2 bg-zinc-100 rounded-full overflow-hidden">
                <div
                  className={cn(
                    'h-full rounded-full transition-all',
                    c.escalationRate > 20
                      ? 'bg-rose-500'
                      : c.escalationRate > 10
                      ? 'bg-amber-400'
                      : 'bg-emerald-500'
                  )}
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
              <Tooltip
                contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
              />
              <Bar dataKey="cases" fill="#2E6F60" radius={[8, 8, 0, 0]} maxBarSize={40} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </SisonkeCard>
    </div>
  );
};
