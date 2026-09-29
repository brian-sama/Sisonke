import React, { useState } from 'react';
import { Shield, Mail, Lock } from 'lucide-react';
import { motion } from 'motion/react';
import { SisonkeCard } from '../components';

interface LoginPageProps {
  onLogin: (email: string, password: string) => Promise<void>;
  error: string | null;
  loading: boolean;
}

export const LoginPage: React.FC<LoginPageProps> = ({ onLogin, error, loading }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <div className="min-h-screen bg-[#FAF9F5] flex items-center justify-center p-6 sm:p-12 overflow-hidden relative font-sans">
      <div className="absolute top-0 right-0 w-96 h-96 bg-primary-mid rounded-full blur-[100px] -translate-y-1/2 translate-x-1/3 opacity-50" />
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-rose-100 rounded-full blur-[100px] translate-y-1/2 -translate-x-1/3 opacity-50" />

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <SisonkeCard className="w-full max-w-lg p-12 border-none shadow-2xl relative overflow-hidden bg-white/80 backdrop-blur-xl">
          <div className="text-center mb-12">
            <div className="w-16 h-16 bg-primary rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-xl shadow-primary-mid group hover:rotate-12 transition-transform">
              <Shield className="text-white" size={32} />
            </div>
            <h1 className="text-4xl font-display font-black text-zinc-900 tracking-tight mb-2 uppercase italic">
              SISONKE
            </h1>
            <p className="text-zinc-500 font-medium tracking-tight">Admin Gateway • Wellness for Youth</p>
          </div>

          <form
            onSubmit={(e) => {
              e.preventDefault();
              onLogin(email, password);
            }}
            className="space-y-6"
          >
            <div className="space-y-2">
              <label htmlFor="admin-email" className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">
                Email
              </label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
                <input
                  id="admin-email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-primary-mid focus:bg-white outline-none transition-all"
                  placeholder="admin@sisonke.org"
                  autoComplete="email"
                  required
                />
              </div>
            </div>
            <div className="space-y-2">
              <label htmlFor="admin-password" className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
                <input
                  id="admin-password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-zinc-50 border border-zinc-100 rounded-2xl font-bold focus:ring-4 focus:ring-primary-mid focus:bg-white outline-none transition-all"
                  placeholder="••••••••"
                  autoComplete="current-password"
                  required
                />
              </div>
            </div>
            {error && (
              <p
                role="alert"
                className="text-rose-600 text-sm font-semibold text-center bg-rose-50 border border-rose-100 rounded-2xl px-4 py-3"
              >
                {error}
              </p>
            )}
            <button
              type="submit"
              disabled={loading}
              className="w-full py-5 bg-zinc-900 text-white rounded-3xl font-display font-black text-lg shadow-xl shadow-zinc-900/20 hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              {loading ? 'Verifying…' : 'Unlock Dashboard'}
            </button>
          </form>

          <div className="mt-10 pt-8 border-t border-zinc-50 flex items-center justify-center gap-4 text-[10px] font-black text-zinc-300 uppercase tracking-[0.2em]">
            <span>Privacy First</span>
            <span>•</span>
            <span>Secured by Zimbabwe Health</span>
          </div>
        </SisonkeCard>
      </motion.div>
    </div>
  );
};
