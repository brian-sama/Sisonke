import React, { useState } from 'react';
import {
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  BarChart,
  Bar,
  XAxis,
  YAxis,
} from 'recharts';
import { Users, Activity, AlertTriangle, Clock, FileText } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { SisonkeCard, PageHeader, StatTile } from '../components';

const MOCK_NGO_STATS = {
  activeUsers: 3412,
  checkInsThisMonth: 8740,
  crisisEvents: 42,
  avgResponseMins: 14,
  moodDist: [
    { name: 'Great', value: 31, color: '#10B981' },
    { name: 'Okay', value: 38, color: '#60a5fa' },
    { name: 'Low', value: 19, color: '#F59E0B' },
    { name: 'Anxious', value: 12, color: '#F43F5E' },
  ],
  weeklyActivity: [
    { week: 'Wk 1', checkIns: 1820, sessions: 620 },
    { week: 'Wk 2', checkIns: 2210, sessions: 810 },
    { week: 'Wk 3', checkIns: 1980, sessions: 740 },
    { week: 'Wk 4', checkIns: 2730, sessions: 930 },
  ],
};

export const NGOReport: React.FC = () => {
  const [stats] = useState(MOCK_NGO_STATS);
  const [showPrintModal, setShowPrintModal] = useState(false);

  const exportCSV = () => {
    const rows = [
      ['Metric', 'Value'],
      ['Active Users', stats.activeUsers],
      ['Mood Check-ins This Month', stats.checkInsThisMonth],
      ['Crisis Events', stats.crisisEvents],
      ['Avg Counselor Response (mins)', stats.avgResponseMins],
      ...stats.moodDist.map((m) => [`Mood: ${m.name}`, `${m.value}%`]),
    ];
    const csv = rows.map((r) => r.join(',')).join('\n');
    const uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
    const a = document.createElement('a');
    a.href = uri;
    a.download = `sisonke-ngo-report-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
  };

  const tiles = [
    { title: 'Active Users', value: stats.activeUsers, icon: Users, iconBg: 'bg-primary-dim', iconColor: 'text-primary' },
    { title: 'Check-ins This Month', value: stats.checkInsThisMonth, icon: Activity, iconBg: 'bg-blue-50', iconColor: 'text-blue-600' },
    { title: 'Crisis Events', value: stats.crisisEvents, icon: AlertTriangle, iconBg: 'bg-rose-50', iconColor: 'text-rose-600' },
    { title: 'Avg Counselor Response', value: `${stats.avgResponseMins}m`, icon: Clock, iconBg: 'bg-amber-50', iconColor: 'text-amber-600' },
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
        {tiles.map((t, i) => (
          <StatTile key={i} {...t} />
        ))}
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
                  contentStyle={{
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                  }}
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
                <Tooltip
                  contentStyle={{
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                  }}
                />
                <Legend wrapperStyle={{ fontSize: '11px', fontWeight: 700 }} />
                <Bar dataKey="checkIns" name="Check-ins" fill="#2E6F60" radius={[8, 8, 0, 0]} maxBarSize={32} />
                <Bar dataKey="sessions" name="Sessions" fill="#60a5fa" radius={[8, 8, 0, 0]} maxBarSize={32} />
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
              onClick={(e) => e.stopPropagation()}
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
                In this version, use your browser's <strong>print function (Ctrl+P / Cmd+P)</strong> to save this page as PDF.
                Full automated export is enabled for reporting partners.
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
