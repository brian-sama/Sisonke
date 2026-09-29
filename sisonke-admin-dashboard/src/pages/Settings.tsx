import React from 'react';
import { Shield, Check } from 'lucide-react';
import { motion } from 'motion/react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const Settings: React.FC = () => (
  <div className="p-6 lg:p-10 max-w-4xl mx-auto space-y-16">
    <div className="space-y-12">
      <section>
        <h3 className="text-3xl font-display font-black text-zinc-900 flex items-center gap-3 mb-8 italic">
          <Shield className="text-primary" size={32} strokeWidth={3} /> Governance Protocol
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {[
            { text: 'Emergency contacts reviewed monthly', color: 'bg-primary-dim text-primary-dark border-primary-dim' },
            { text: 'Legal/SRHR content reviewed quarterly', color: 'bg-emerald-50 text-emerald-700 border-emerald-100' },
            { text: 'Red-risk safety rules reviewed after every incident', color: 'bg-rose-50 text-rose-700 border-rose-100' },
            { text: 'AI must not diagnose or replace emergency care', color: 'bg-amber-50 text-amber-700 border-amber-100' },
          ].map((item, i) => (
            <motion.div
              key={i}
              whileHover={{ scale: 1.05 }}
              className={cn('flex gap-4 p-8 rounded-[2.5rem] border-2', item.color)}
            >
              <Check className="shrink-0 mt-1" size={24} strokeWidth={4} />
              <span className="font-bold text-lg leading-tight tracking-tight">{item.text}</span>
            </motion.div>
          ))}
        </div>
      </section>

      <section className="space-y-8 bg-white p-12 rounded-[3.5rem] shadow-2xl border border-zinc-100">
        <h3 className="text-2xl font-display font-black text-zinc-900 leading-none">Admin Profile</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-8">
          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">
              Authority Grade
            </label>
            <div className="w-full px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold text-zinc-600">
              Super User
            </div>
          </div>
          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Network Base</label>
            <div className="w-full px-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold text-zinc-600">
              Bulawayo Central Hub
            </div>
          </div>
        </div>
        <div className="pt-4 flex justify-end">
          <button className="px-10 py-4 bg-primary text-white rounded-3xl font-display font-black tracking-widest uppercase text-xs shadow-xl shadow-primary-mid">
            Audit Configuration
          </button>
        </div>
      </section>
    </div>
  </div>
);
