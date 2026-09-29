import React, { useState, useEffect } from 'react';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  LineChart,
  Line,
} from 'recharts';
import { Users, TrendingUp, Shield } from 'lucide-react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, PageHeader, StatTile, EmptyState, SkeletonCard } from '../components';

type CohortData = {
  distribution: Array<Record<string, string | number>>;
  trend: Array<Record<string, string | number>>;
  avgScores: Array<{ group: string; score: number; icon?: any; iconBg?: string; iconColor?: string }>;
};

export const CohortInsights: React.FC = () => {
  const [data, setData] = useState<CohortData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiFetch('/api/analytics/cohort-moods')
      .then(async (res) => {
        const payload = await res.json();
        setData(payload.data || payload);
      })
      .catch(() => {
        // Fallback demo data
        setData({
          distribution: [
            { group: '13-15', great: 40, okay: 35, low: 15, anxious: 10 },
            { group: '16-18', great: 30, okay: 40, low: 20, anxious: 10 },
            { group: '19-24', great: 25, okay: 45, low: 18, anxious: 12 },
          ],
          trend: Array.from({ length: 15 }, (_, i) => ({
            day: `Day ${i + 1}`,
            teen: 55 + Math.sin(i) * 10,
            youth: 50 + Math.cos(i) * 8,
            young: 60 + Math.sin(i / 2) * 6,
          })),
          avgScores: [
            { group: '13-15', score: 68, iconBg: 'bg-emerald-50', iconColor: 'text-emerald-600' },
            { group: '16-18', score: 62, iconBg: 'bg-blue-50', iconColor: 'text-blue-600' },
            { group: '19-24', score: 65, iconBg: 'bg-purple-50', iconColor: 'text-purple-600' },
          ],
        });
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading)
    return (
      <div className="p-10 space-y-6 max-w-7xl mx-auto">
        {[1, 2].map((i) => (
          <SkeletonCard key={i} />
        ))}
      </div>
    );

  if (error) return <EmptyState icon={TrendingUp} title="Cohort insights unavailable" description={error} />;
  if (!data)
    return (
      <EmptyState
        icon={TrendingUp}
        title="No cohort data"
        description="There is no aggregated mood data to display yet."
      />
    );

  const MOOD_COLORS = { great: '#10B981', okay: '#60a5fa', low: '#F59E0B', anxious: '#F43F5E' };

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <PageHeader
        title="Cohort Mood Insights"
        subtitle="Anonymized mood trends by age group and day of week"
      />

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
        {data.avgScores.map((s) => (
          <StatTile
            key={s.group}
            title={`Avg Mood Score — ${s.group}`}
            value={`${s.score}/100`}
            icon={Users}
            iconBg={s.iconBg || 'bg-primary-dim'}
            iconColor={s.iconColor || 'text-primary'}
          />
        ))}
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <SisonkeCard className="p-8">
          <h4 className="font-display font-black text-zinc-900 text-lg mb-6">Mood Distribution by Age Group</h4>
          <div className="h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.distribution}>
                <XAxis dataKey="group" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                  }}
                />
                <Legend wrapperStyle={{ fontSize: '11px', fontWeight: 700 }} />
                <Bar dataKey="great" fill={MOOD_COLORS.great} radius={[6, 6, 0, 0]} maxBarSize={24} />
                <Bar dataKey="okay" fill={MOOD_COLORS.okay} radius={[6, 6, 0, 0]} maxBarSize={24} />
                <Bar dataKey="low" fill={MOOD_COLORS.low} radius={[6, 6, 0, 0]} maxBarSize={24} />
                <Bar dataKey="anxious" fill={MOOD_COLORS.anxious} radius={[6, 6, 0, 0]} maxBarSize={24} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </SisonkeCard>

        <SisonkeCard className="p-8">
          <h4 className="font-display font-black text-zinc-900 text-lg mb-6">30-Day Mood Trend by Age Group</h4>
          <div className="h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data.trend}>
                <XAxis
                  dataKey="day"
                  fontSize={10}
                  tickLine={false}
                  axisLine={false}
                  tick={{ fill: '#94a3b8' }}
                  interval={4}
                />
                <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} domain={[30, 80]} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                  }}
                />
                <Legend wrapperStyle={{ fontSize: '11px', fontWeight: 700 }} />
                <Line type="monotone" dataKey="teen" name="13–15" stroke="#8b5cf6" strokeWidth={3} dot={false} />
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
