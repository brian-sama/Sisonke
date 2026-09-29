import React, { useState, useEffect } from 'react';
import { MessageSquare, AlertTriangle, Check, X } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, EmptyState, PageHeader, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

function timeAgo(ts: number): string {
  const diff = Date.now() - ts;
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

type PendingPost = {
  id: string;
  anonId: string;
  ts: number;
  content: string;
  flagCount: number;
};

export const ModerationQueue: React.FC = () => {
  const [posts, setPosts] = useState<PendingPost[]>([]);
  const [selected, setSelected] = useState<PendingPost | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actioning, setActioning] = useState<string | null>(null);

  useEffect(() => {
    apiFetch('/api/community/pending')
      .then(async (res) => {
        const payload = await res.json();
        const raw = Array.isArray(payload) ? payload : payload.data ?? [];
        setPosts(
          raw.map((p: any) => ({
            id: p.id,
            anonId: p.anonId || `User-${p.id?.slice(0, 4) || 'anon'}`,
            ts: p.createdAt ? new Date(p.createdAt).getTime() : Date.now() - 3600000,
            content: p.content || '',
            flagCount: p.reportCount || p.flagCount || 0,
          }))
        );
      })
      .catch(() => setError('The moderation queue is currently unavailable.'))
      .finally(() => setLoading(false));
  }, []);

  const handleAction = async (id: string, action: 'approve' | 'reject') => {
    setActioning(id);
    try {
      await apiFetch(`/api/community/${id}/${action}`, { method: 'POST' }).catch(() => {});
    } finally {
      setPosts((prev) => prev.filter((p) => p.id !== id));
      if (selected?.id === id) setSelected(null);
      setActioning(null);
    }
  };

  if (loading)
    return (
      <div className="p-10 grid grid-cols-2 gap-8 max-w-7xl mx-auto">
        <div className="space-y-4">
          {[1, 2, 3].map((i) => (
            <SkeletonCard key={i} />
          ))}
        </div>
        <SkeletonCard />
      </div>
    );

  if (error) return <EmptyState icon={MessageSquare} title="Moderation unavailable" description={error} />;

  return (
    <div className="p-6 lg:p-10 max-w-7xl mx-auto">
      <div className="mb-8">
        <PageHeader title="Content Moderation" subtitle="Community posts awaiting review before going live" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="space-y-3">
          {posts.length === 0 ? (
            <EmptyState icon={Check} title="Queue is clear" description="All posts are reviewed. Check back later." />
          ) : (
            posts.map((post) => (
              <button
                key={post.id}
                type="button"
                onClick={() => setSelected(post)}
                className={cn(
                  'w-full text-left rounded-[1.75rem] border p-5 transition-all',
                  selected?.id === post.id
                    ? 'border-primary ring-2 ring-primary/20 bg-primary-dim'
                    : 'border-zinc-100 bg-white hover:border-primary-dim hover:bg-primary-dim/40 shadow-sm'
                )}
              >
                <div className="flex items-start justify-between gap-3 mb-2">
                  <span className="text-[10px] font-black text-zinc-400 uppercase tracking-widest">{post.anonId}</span>
                  <div className="flex items-center gap-2 shrink-0">
                    {post.flagCount > 0 && (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 bg-rose-100 text-rose-600 rounded-lg text-[10px] font-black uppercase tracking-wide">
                        <AlertTriangle size={10} strokeWidth={3} /> {post.flagCount}
                      </span>
                    )}
                    <span className="text-[10px] font-bold text-zinc-400">{timeAgo(post.ts)}</span>
                  </div>
                </div>
                <p className="text-sm text-zinc-700 font-medium leading-snug line-clamp-2">{post.content}</p>
              </button>
            ))
          )}
        </div>

        <div className="lg:sticky lg:top-24 self-start">
          <AnimatePresence mode="wait">
            {selected ? (
              <motion.div
                key={selected.id}
                initial={{ opacity: 0, scale: 0.97 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.97 }}
              >
                <SisonkeCard className="p-8 space-y-6 border-2 border-primary-dim">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-[10px] font-black text-zinc-400 uppercase tracking-widest">{selected.anonId}</p>
                      <p className="text-xs text-zinc-400 mt-0.5">{timeAgo(selected.ts)}</p>
                    </div>
                    {selected.flagCount > 0 && (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-rose-100 text-rose-600 rounded-2xl text-[10px] font-black uppercase tracking-widest">
                        <AlertTriangle size={12} strokeWidth={3} /> {selected.flagCount} flag
                        {selected.flagCount !== 1 ? 's' : ''}
                      </span>
                    )}
                  </div>

                  <div className="bg-zinc-50 border border-zinc-100 rounded-2xl p-5">
                    <p className="text-zinc-800 font-medium leading-relaxed">{selected.content}</p>
                  </div>

                  <div className="flex gap-3">
                    <button
                      type="button"
                      disabled={actioning === selected.id}
                      onClick={() => handleAction(selected.id, 'approve')}
                      className="flex-1 py-4 bg-emerald-500 text-white rounded-[1.75rem] font-bold text-sm shadow-lg shadow-emerald-200 hover:bg-emerald-600 hover:-translate-y-0.5 active:translate-y-0 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                    >
                      <Check size={18} strokeWidth={3} /> Approve
                    </button>
                    <button
                      type="button"
                      disabled={actioning === selected.id}
                      onClick={() => handleAction(selected.id, 'reject')}
                      className="flex-1 py-4 bg-rose-500 text-white rounded-[1.75rem] font-bold text-sm shadow-lg shadow-rose-200 hover:bg-rose-600 hover:-translate-y-0.5 active:translate-y-0 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                    >
                      <X size={18} strokeWidth={3} /> Reject
                    </button>
                  </div>
                </SisonkeCard>
              </motion.div>
            ) : (
              <motion.div key="empty" initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                <div className="h-80 border-4 border-dashed border-zinc-100 rounded-[2.5rem] flex flex-col items-center justify-center p-10 text-center">
                  <div className="w-16 h-16 bg-zinc-50 rounded-full flex items-center justify-center mb-4">
                    <MessageSquare className="text-zinc-200" size={28} />
                  </div>
                  <h4 className="text-lg font-display font-bold text-zinc-300 mb-1">No post selected</h4>
                  <p className="text-zinc-400 text-sm">Click a post in the queue to review it here.</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};
