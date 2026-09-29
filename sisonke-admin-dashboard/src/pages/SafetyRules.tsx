import React, { useState, useEffect } from 'react';
import { Search, ShieldAlert, AlertTriangle, Check } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const SafetyRules: React.FC = () => {
  const [rules, setRules] = useState<any[]>([]);
  const [testMsg, setTestMsg] = useState('');
  const [testResult, setTestResult] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/api/admin/safety-rules')
      .then(async (res) => {
        const payload = await res.json();
        setRules(Array.isArray(payload) ? payload : payload.data ?? []);
      })
      .catch(() => setRules([]))
      .finally(() => setLoading(false));
  }, []);

  const handleTest = async () => {
    if (!testMsg.trim()) return;
    try {
      const res = await apiFetch('/api/admin/safety-rules/test', {
        method: 'POST',
        body: JSON.stringify({ message: testMsg }),
      });
      const data = await res.json();
      setTestResult(data.data || data);
    } catch {
      // Local fallback test
      const matched = rules.find((r) =>
        r.terms?.some((t: string) => testMsg.toLowerCase().includes(t.toLowerCase()))
      );
      setTestResult(matched ? { detected: true, rule: matched } : { detected: false });
    }
  };

  return (
    <div className="p-6 lg:p-10 grid grid-cols-1 xl:grid-cols-2 gap-12 max-w-7xl mx-auto">
      <div className="space-y-10">
        <div>
          <h3 className="text-3xl font-display font-black text-zinc-900 leading-none mb-3">Crisis Triggers</h3>
          <p className="text-zinc-500 font-medium">Automatic escalation patterns for sensitive situations</p>
        </div>

        {loading ? (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        ) : (
          <div className="space-y-6">
            {rules.map((rule) => (
              <SisonkeCard
                key={rule.id}
                className={cn(
                  'p-10 border-none transition-all',
                  rule.risk === 'red'
                    ? 'bg-rose-600 text-white shadow-2xl shadow-rose-200'
                    : 'bg-white shadow-xl shadow-zinc-100'
                )}
              >
                <div className="flex items-center justify-between mb-8">
                  <div
                    className={cn(
                      'px-4 py-1.5 rounded-2xl text-[10px] font-black uppercase tracking-widest',
                      rule.risk === 'red' ? 'bg-white/20 text-white' : 'bg-zinc-100 text-zinc-500'
                    )}
                  >
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
                    {(rule.terms || []).map((t: string) => (
                      <span
                        key={t}
                        className={cn(
                          'px-3 py-1.5 rounded-xl text-xs font-black tracking-wide border',
                          rule.risk === 'red'
                            ? 'bg-white/10 border-white/20 text-white'
                            : 'bg-zinc-50 border-zinc-100 text-zinc-900'
                        )}
                      >
                        {t}
                      </span>
                    ))}
                  </div>
                  <div
                    className={cn(
                      'p-6 rounded-3xl font-medium leading-relaxed italic border-l-4 shadow-inner',
                      rule.risk === 'red'
                        ? 'bg-rose-700/50 border-white text-rose-50'
                        : 'bg-zinc-50 border-primary text-zinc-600'
                    )}
                  >
                    "{rule.responseTemplate}"
                  </div>
                </div>
              </SisonkeCard>
            ))}
          </div>
        )}
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
              <label className="text-[10px] font-black uppercase tracking-widest text-zinc-400 px-1">
                Simulate User Input
              </label>
              <textarea
                placeholder="e.g., 'I want to end my life, tell me how...'"
                className="w-full h-40 p-6 bg-zinc-50 border-2 border-zinc-100 rounded-[2rem] font-medium text-zinc-700 focus:ring-8 focus:ring-zinc-100 outline-none transition-all placeholder:text-zinc-300 resize-none"
                value={testMsg}
                onChange={(e) => setTestMsg(e.target.value)}
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
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className={cn(
                    'p-10 rounded-[2.5rem] shadow-xl',
                    testResult.detected
                      ? 'bg-rose-50 text-rose-700 border border-rose-100'
                      : 'bg-emerald-50 text-emerald-700 border border-emerald-100'
                  )}
                >
                  <div className="flex items-center gap-4 mb-4">
                    <div
                      className={cn(
                        'w-12 h-12 rounded-2xl flex items-center justify-center shadow-lg',
                        testResult.detected ? 'bg-rose-500 text-white' : 'bg-emerald-500 text-white'
                      )}
                    >
                      {testResult.detected ? <AlertTriangle size={24} strokeWidth={3} /> : <Check size={24} strokeWidth={3} />}
                    </div>
                    <div className="flex flex-col">
                      <span className="text-xs font-black uppercase tracking-widest opacity-60">Test Conclusion</span>
                      <span className="font-display font-black text-xl">
                        {testResult.detected ? 'CRITICAL TRIGGER' : 'CLEAN INPUT'}
                      </span>
                    </div>
                  </div>
                  {testResult.detected && (
                    <p className="text-sm font-medium leading-relaxed mt-4 opacity-80 italic">
                      Matched pattern: '{testResult.rule?.route || 'Emergency'}'. The user will be instantly escalated to
                      human counselor support with the defined emergency prompt.
                    </p>
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
