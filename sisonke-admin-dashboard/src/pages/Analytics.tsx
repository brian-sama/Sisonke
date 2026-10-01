import React, { useState, useEffect } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';
import { AlertTriangle, Activity, ShieldAlert, UserCheck, Lock } from 'lucide-react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, SkeletonCard } from '../components';

export const Analytics: React.FC = () => {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/api/analytics/summary')
      .then(async (res) => {
        const payload = await res.json();
        setData(payload.data || payload);
      })
      .catch(() => {
        setData({
          appOpens: [400, 520, 600, 750, 900, 1100, 1250],
          resourceViews: [200, 310, 420, 500, 610, 800, 920],
          highRiskEvents: [2, 4, 1, 6, 3, 5, 2],
        });
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading || !data)
    return (
      <div className="p-10 space-y-6 max-w-7xl mx-auto">
        <SkeletonCard />
        <SkeletonCard />
      </div>
    );

  const chartData = (data.appOpens || []).map((val: number, i: number) => ({
    name: `${i + 1} May`,
    opens: val,
    views: (data.resourceViews || [])[i] ?? 0,
    risk: (data.highRiskEvents || [])[i] ?? 0,
  }));

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div>
          <h3 className="text-3xl font-display font-black text-zinc-900">Health & Platform Insights</h3>
          <p className="text-zinc-600 font-medium">Aggregated behavior analysis, traffic trends & crisis metrics</p>
        </div>
        <div className="flex items-center gap-2 p-1.5 bg-zinc-100 rounded-2xl">
          <a
            href="/analytics"
            className="px-4 py-2 bg-white text-primary rounded-xl text-xs font-black uppercase tracking-wider shadow-sm"
          >
            Traffic & Activity
          </a>
          <a
            href="/cohort"
            className="px-4 py-2 text-zinc-600 hover:text-zinc-900 rounded-xl text-xs font-black uppercase tracking-wider transition-colors"
          >
            Cohort Moods
          </a>
          <a
            href="/ngo-report"
            className="px-4 py-2 text-zinc-600 hover:text-zinc-900 rounded-xl text-xs font-black uppercase tracking-wider transition-colors"
          >
            NGO Reports
          </a>
        </div>
      </div>


      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <SisonkeCard className="p-10 bg-primary text-white border-none shadow-2xl shadow-primary-mid">
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
        </SisonkeCard>

        <SisonkeCard className="p-10 lg:col-span-2 bg-white shadow-2xl shadow-zinc-100 border-none">
          <div className="flex items-center justify-between mb-8">
            <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 flex items-center gap-2">
              <AlertTriangle size={12} strokeWidth={3} className="text-rose-500" /> Crisis Trend Analysis
            </h4>
            <div className="text-[10px] font-black uppercase text-rose-500 bg-rose-50 px-3 py-1 rounded-full">
              Elevated Risk
            </div>
          </div>
          <div className="h-[220px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <XAxis dataKey="name" axisLine={false} tickLine={false} fontSize={10} tick={{ fill: '#94a3b8' }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="risk"
                  stroke="#f43f5e"
                  strokeWidth={5}
                  dot={{ r: 6, fill: '#f43f5e', stroke: '#fff', strokeWidth: 3 }}
                />
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
        </SisonkeCard>
      </div>

      <div className="bg-amber-100/50 backdrop-blur-sm border-2 border-dashed border-amber-200 p-10 rounded-[3rem] flex gap-8 items-start relative overflow-hidden group">
        <div className="absolute top-0 right-0 w-32 h-32 bg-amber-200/20 rounded-full blur-3xl pointer-events-none group-hover:scale-150 transition-transform duration-700" />
        <div className="w-16 h-16 bg-amber-500 rounded-3xl shrink-0 flex items-center justify-center text-white shadow-xl shadow-amber-200 animate-pulse">
          <Lock size={32} strokeWidth={2.5} />
        </div>
        <div>
          <h5 className="text-2xl font-display font-black text-amber-900 mb-2 tracking-tight">Privacy Fortress Protocol</h5>
          <p className="text-lg text-amber-800 leading-relaxed max-w-4xl opacity-80 font-medium italic">
            "Every metric displayed here is a high-level aggregate summary. We never track individual private journal
            entries, confidential chat transcripts, or reveal youth identities beyond clinical necessity. Zimbabwe Youth's
            digital safety and dignity remain paramount."
          </p>
        </div>
      </div>
    </div>
  );
};
