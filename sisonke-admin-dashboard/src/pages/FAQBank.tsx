import React, { useState, useEffect } from 'react';
import { Tag, Globe } from 'lucide-react';
import { motion } from 'motion/react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const FAQBank: React.FC = () => {
  const [faqs, setFaqs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/api/admin/faqs')
      .then(async (res) => {
        const payload = await res.json();
        setFaqs(Array.isArray(payload) ? payload : payload.data ?? []);
      })
      .catch(() => setFaqs([]))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 bg-primary p-8 lg:p-12 rounded-[3.5rem] shadow-2xl relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full -translate-y-1/2 translate-x-1/2 blur-3xl pointer-events-none" />
        <div className="relative z-10">
          <h3 className="text-4xl font-display font-black text-white leading-tight">Gold FAQ Bank</h3>
          <p className="text-white/80 font-medium mt-1">High-quality, vetted answers for AI & Youth</p>
        </div>
        <button className="relative z-10 px-8 py-4 bg-white text-primary rounded-3xl font-black text-sm uppercase tracking-widest shadow-xl hover:scale-105 transition-transform active:scale-95">
          Add FAQ
        </button>
      </div>

      {loading ? (
        <div className="space-y-4">
          {[1, 2, 3].map((i) => (
            <SkeletonCard key={i} />
          ))}
        </div>
      ) : (
        <div className="space-y-6">
          {faqs.map((faq) => (
            <motion.div key={faq.id} whileHover={{ y: -4 }}>
              <SisonkeCard className="p-10 border-none bg-white shadow-xl shadow-zinc-100/60 flex flex-col md:flex-row items-start gap-8">
                <div
                  className={cn(
                    'shrink-0 w-16 h-16 rounded-3xl flex items-center justify-center font-display font-black text-2xl shadow-lg',
                    faq.riskLevel === 'red'
                      ? 'bg-rose-500 text-white shadow-rose-200'
                      : faq.riskLevel === 'amber'
                      ? 'bg-amber-500 text-white shadow-amber-200'
                      : 'bg-emerald-500 text-white shadow-emerald-200'
                  )}
                >
                  {faq.riskLevel === 'red' ? '!' : '?'}
                </div>
                <div className="flex-1 space-y-5">
                  <div className="flex flex-wrap items-center gap-3">
                    <h4 className="text-2xl font-display font-black text-zinc-900 leading-tight">{faq.question}</h4>
                    <span
                      className={cn(
                        'px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest',
                        faq.riskLevel === 'red'
                          ? 'bg-rose-100 text-rose-700'
                          : faq.riskLevel === 'amber'
                          ? 'bg-amber-100 text-amber-700'
                          : 'bg-emerald-100 text-emerald-700'
                      )}
                    >
                      {faq.riskLevel || 'general'} risk tier
                    </span>
                  </div>
                  <div className="p-6 bg-zinc-50 rounded-3xl border border-zinc-100 italic text-zinc-600 leading-relaxed text-lg">
                    "{faq.goldAnswer || faq.answer}"
                  </div>
                  <div className="flex items-center justify-between text-[11px] font-black text-zinc-400 uppercase tracking-widest">
                    <div className="flex gap-6">
                      <span className="flex items-center gap-1.5">
                        <Tag size={12} strokeWidth={3} className="text-zinc-300" /> {faq.topic || 'health'}
                      </span>
                      <span className="flex items-center gap-1.5">
                        <Globe size={12} strokeWidth={3} className="text-zinc-300" /> {faq.language || 'English'}
                      </span>
                    </div>
                    <div className="flex gap-2">
                      <button className="px-4 py-2 bg-zinc-100 rounded-xl hover:bg-primary hover:text-white transition-all font-bold">
                        Edit
                      </button>
                    </div>
                  </div>
                </div>
              </SisonkeCard>
            </motion.div>
          ))}
        </div>
      )}
    </div>
  );
};
