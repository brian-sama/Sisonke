import React, { useState } from 'react';
import { Lock } from 'lucide-react';
import { motion } from 'motion/react';
import { SisonkeCard, PrimaryButton } from '../components';
import { apiFetch } from '../lib/api';

export const ChangePasswordPage = ({ onDone, onLogout }: { onDone: () => void; onLogout: () => void }) => {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  return (
    <div className="min-h-screen bg-[#FAF9F5] flex items-center justify-center p-6 sm:p-12 overflow-hidden relative font-sans">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="w-full max-w-md">
        <SisonkeCard className="p-10 border-none shadow-2xl bg-white/90 backdrop-blur-xl text-center">
          <div className="w-16 h-16 bg-primary-dim rounded-3xl mx-auto mb-4 flex items-center justify-center">
            <Lock className="text-primary" size={28} />
          </div>
          <h2 className="text-2xl font-display font-black text-zinc-900">Choose a new password</h2>
          <p className="text-zinc-500 text-xs mt-1.5 mb-6">
            Your team lead has requested you update your password before accessing the care portal.
          </p>

          <form
            onSubmit={async (event) => {
              event.preventDefault();
              setError('');
              setLoading(true);
              try {
                const res = await apiFetch('/api/auth/change-password', {
                  method: 'POST',
                  body: JSON.stringify({ newPassword: password }),
                });
                const payload = await res.json();
                if (!res.ok || !payload.success) throw new Error(payload.error || 'Could not change password.');
                onDone();
              } catch (err: any) {
                setError(err instanceof Error ? err.message : 'Could not change password.');
              } finally {
                setLoading(false);
              }
            }}
            className="space-y-4 text-left"
          >
            <div>
              <label className="text-xs font-bold text-zinc-600 block mb-1">New Password</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl outline-none focus:ring-4 focus:ring-primary/10 font-bold text-sm"
                placeholder="At least 8 characters"
                minLength={8}
                required
              />
            </div>

            {error && (
              <p className="text-xs font-bold text-rose-600 bg-rose-50 border border-rose-100 p-2.5 rounded-xl text-center">
                {error}
              </p>
            )}

            <PrimaryButton type="submit" disabled={loading} className="w-full py-3.5 text-sm">
              {loading ? 'Saving...' : 'Set Password & Continue'}
            </PrimaryButton>

            <button
              type="button"
              onClick={onLogout}
              className="w-full text-center text-xs font-bold text-zinc-400 hover:text-zinc-700 pt-2 transition-colors"
            >
              Sign out
            </button>
          </form>
        </SisonkeCard>
      </motion.div>
    </div>
  );
};
