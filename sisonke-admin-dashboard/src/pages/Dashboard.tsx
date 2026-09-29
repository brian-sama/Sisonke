import React, { useState, useEffect } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';
import {
  Users,
  MessageSquare,
  AlertTriangle,
  BookOpen,
  UserCheck,
  Activity,
} from 'lucide-react';
import { motion } from 'motion/react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, StatTile, EmptyState, SkeletonCard, SkeletonBlock } from '../components';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiFetch('/api/admin/overview')
      .then(async (res) => {
        const payload = await res.json();
        if (!res.ok || !payload.success) {
          throw new Error(payload.error || 'Dashboard data could not be loaded.');
        }
        return payload.data;
      })
      .then((data) => setStats(data))
      .catch((requestError: unknown) => {
        setError(requestError instanceof Error ? requestError.message : 'Dashboard data could not be loaded.');
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading)
    return (
      <div className="p-10 space-y-8 max-w-7xl mx-auto">
        <SkeletonBlock className="h-8 w-48" />
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <SkeletonCard key={i} />
          ))}
        </div>
      </div>
    );

  if (error)
    return (
      <div className="p-10 max-w-2xl mx-auto">
        <EmptyState
          icon={AlertTriangle}
          title="Dashboard unavailable"
          description={error}
          action={
            <button
              type="button"
              onClick={() => window.location.reload()}
              className="px-5 py-3 rounded-xl bg-primary text-white font-bold"
            >
              Retry
            </button>
          }
        />
      </div>
    );

  if (!stats)
    return (
      <div className="p-10 max-w-2xl mx-auto">
        <EmptyState
          icon={Activity}
          title="No dashboard data"
          description="There is no operational data to display yet."
        />
      </div>
    );

  const tiles = [
    { title: 'People Registered', value: stats.users?.total ?? 0, icon: Users, iconColor: 'text-primary', iconBg: 'bg-primary-dim' },
    { title: 'E-Friend Conversations', value: stats.chatbotSessions?.total ?? 0, icon: MessageSquare, iconColor: 'text-blue-600', iconBg: 'bg-blue-50' },
    { title: 'People Needing Urgent Care', value: stats.counselorCases?.highRisk ?? 0, icon: AlertTriangle, iconColor: 'text-rose-600', iconBg: 'bg-rose-50' },
    { title: 'People Needing Support', value: stats.counselorCases?.total ?? 0, icon: UserCheck, iconColor: 'text-amber-600', iconBg: 'bg-amber-50' },
    { title: 'Resources Published', value: stats.resources?.total ?? 0, icon: BookOpen, iconColor: 'text-emerald-600', iconBg: 'bg-emerald-50' },
    { title: 'Whispers to Moderate', value: stats.communityPosts?.pending ?? 0, icon: MessageSquare, iconColor: 'text-violet-600', iconBg: 'bg-violet-50' },
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
        <SisonkeCard className="p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-display font-bold">Activity Pulse</h3>
            <div className="flex gap-2">
              <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-500">
                <div className="w-3 h-3 rounded-full bg-primary" />
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
              <BarChart
                data={[
                  { name: 'Mon', apps: 400, chatbot: 240 },
                  { name: 'Tue', apps: 300, chatbot: 139 },
                  { name: 'Wed', apps: 200, chatbot: 980 },
                  { name: 'Thu', apps: 278, chatbot: 390 },
                  { name: 'Fri', apps: 189, chatbot: 480 },
                  { name: 'Sat', apps: 239, chatbot: 380 },
                  { name: 'Sun', apps: 349, chatbot: 430 },
                ]}
              >
                <XAxis dataKey="name" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                  }}
                />
                <Bar dataKey="apps" fill="#2E6F60" radius={[8, 8, 0, 0]} maxBarSize={32} />
                <Bar dataKey="chatbot" fill="#60a5fa" radius={[8, 8, 0, 0]} maxBarSize={32} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </SisonkeCard>

        <SisonkeCard className="p-8">
          <h3 className="text-xl font-display font-bold mb-8">Alert Escalations</h3>
          <div className="h-[320px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart
                data={[
                  { name: 'Week 1', alerts: 4 },
                  { name: 'Week 2', alerts: 7 },
                  { name: 'Week 3', alerts: 2 },
                  { name: 'Week 4', alerts: 12 },
                ]}
              >
                <XAxis dataKey="name" fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <YAxis fontSize={11} tickLine={false} axisLine={false} tick={{ fill: '#94a3b8' }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                  }}
                />
                <defs>
                  <linearGradient id="lineGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#f43f5e" stopOpacity={0.8} />
                    <stop offset="95%" stopColor="#f43f5e" stopOpacity={0} />
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
        </SisonkeCard>
      </div>
    </div>
  );
};
