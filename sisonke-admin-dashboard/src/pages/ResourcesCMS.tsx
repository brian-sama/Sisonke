import React, { useState, useEffect } from 'react';
import { Plus, Edit2, X, Check, BookOpen } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, EmptyState, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const ResourcesCMS: React.FC = () => {
  const [resources, setResources] = useState<any[]>([]);
  const [editing, setEditing] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const loadResources = async () => {
    try {
      setLoading(true);
      const res = await apiFetch('/api/resources');
      const payload = await res.json();
      const list = Array.isArray(payload) ? payload : payload.data?.resources ?? payload.resources ?? [];
      setResources(list);
    } catch {
      setResources([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadResources();
  }, []);

  const handleSave = async () => {
    if (!editing.title) return;
    try {
      if (editing.id) {
        await apiFetch(`/api/resources/${editing.id}`, {
          method: 'PUT',
          body: JSON.stringify(editing),
        });
      } else {
        await apiFetch('/api/resources', {
          method: 'POST',
          body: JSON.stringify(editing),
        });
      }
      setEditing(null);
      await loadResources();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="p-6 lg:p-10 grid grid-cols-1 lg:grid-cols-12 gap-10 max-w-screen-2xl mx-auto">
      <div className="lg:col-span-12 xl:col-span-8 space-y-8">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
          <div>
            <h3 className="text-3xl font-display font-black text-zinc-900 leading-tight">Content Library</h3>
            <p className="text-zinc-500 font-medium">Manage wellness guides and resources for Zimbabwe youth</p>
          </div>
          <button
            onClick={() => setEditing({ title: '', content: '', category: 'wellness', isPublished: false, language: 'en' })}
            className="flex items-center justify-center gap-2 px-8 py-4 bg-primary text-white rounded-2xl font-bold hover:bg-primary-dark shadow-xl shadow-primary/20 active:scale-95 transition-all"
          >
            <Plus size={20} strokeWidth={3} /> Create Resource
          </button>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {[1, 2, 3, 4].map((i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        ) : resources.length === 0 ? (
          <EmptyState
            icon={BookOpen}
            title="No resources found"
            description="Create educational articles and guides for the mobile application."
          />
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {resources.map((r) => (
              <SisonkeCard
                key={r.id}
                className="p-0 border-none bg-white shadow-xl shadow-zinc-200/50 hover:shadow-2xl hover:shadow-primary-dim transition-all overflow-hidden group"
              >
                <div
                  className={cn(
                    'h-32 p-6 flex items-end relative overflow-hidden',
                    r.category === 'mental-health'
                      ? 'bg-primary'
                      : r.category === 'srhr'
                      ? 'bg-rose-500'
                      : 'bg-amber-500'
                  )}
                >
                  <div className="absolute top-4 right-4">
                    <span
                      className={cn(
                        'px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider',
                        r.isPublished ? 'bg-emerald-400/20 text-white' : 'bg-white/20 text-white'
                      )}
                    >
                      {r.isPublished ? 'Live' : 'Draft'}
                    </span>
                  </div>
                  <h4 className="font-display font-black text-white text-xl leading-tight group-hover:translate-x-2 transition-transform">
                    {r.title}
                  </h4>
                </div>
                <div className="p-6 space-y-4">
                  <div className="flex items-center gap-4 text-[10px] font-black uppercase tracking-widest text-zinc-400">
                    <span className="bg-zinc-100 px-2 py-1 rounded-lg">{r.category}</span>
                    <span>•</span>
                    <span>{r.language || 'English'}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-zinc-500 font-medium italic">
                      Updated {r.updatedAt ? new Date(r.updatedAt).toLocaleDateString() : 'recently'}
                    </span>
                    <button
                      type="button"
                      aria-label="Edit resource"
                      onClick={() => setEditing(r)}
                      className="w-10 h-10 rounded-xl bg-zinc-50 flex items-center justify-center hover:bg-primary-dim hover:text-primary transition-colors"
                    >
                      <Edit2 size={18} />
                    </button>
                  </div>
                </div>
              </SisonkeCard>
            ))}
          </div>
        )}
      </div>

      <div className="lg:col-span-12 xl:col-span-4 self-start">
        <AnimatePresence mode="wait">
          {editing ? (
            <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95 }}>
              <SisonkeCard className="p-10 space-y-10 sticky top-24 border-primary-dim ring-4 ring-primary-dim shadow-2xl">
                <div className="flex items-center justify-between">
                  <h3 className="font-display font-black text-2xl tracking-tight">
                    {editing.id ? 'Refine' : 'Compose'}
                  </h3>
                  <button
                    type="button"
                    aria-label="Close editor"
                    onClick={() => setEditing(null)}
                    className="w-8 h-8 rounded-full bg-zinc-100 flex items-center justify-center text-zinc-400 hover:text-rose-600 transition-colors"
                  >
                    <X size={18} strokeWidth={3} />
                  </button>
                </div>

                <div className="space-y-8">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Resource Title</label>
                    <input
                      autoFocus
                      value={editing.title || ''}
                      onChange={(e) => setEditing({ ...editing, title: e.target.value })}
                      className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl font-display font-bold text-lg focus:ring-4 focus:ring-primary-mid outline-none transition-all"
                      placeholder="Enter a catchy title..."
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Markdown Fabric</label>
                    <textarea
                      rows={12}
                      value={editing.content || ''}
                      onChange={(e) => setEditing({ ...editing, content: e.target.value })}
                      className="w-full p-4 bg-zinc-50 border border-zinc-200 rounded-xl font-mono text-xs leading-relaxed focus:ring-4 focus:ring-primary-mid outline-none transition-all resize-none"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Pillar</label>
                      <select
                        value={editing.category || 'wellness'}
                        onChange={(e) => setEditing({ ...editing, category: e.target.value })}
                        className="w-full p-3 bg-zinc-50 border border-zinc-200 rounded-xl font-bold text-sm focus:ring-4 focus:ring-primary-mid outline-none"
                      >
                        <option value="mental-health">🧠 Mental Health</option>
                        <option value="srhr">🩸 SRHR</option>
                        <option value="wellness">🌿 Wellness</option>
                      </select>
                    </div>
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Visibility</label>
                      <button
                        type="button"
                        onClick={() => setEditing({ ...editing, isPublished: !editing.isPublished })}
                        className={cn(
                          'w-full p-3 rounded-xl font-black text-[10px] uppercase tracking-widest flex items-center justify-center gap-2 transition-all shadow-sm',
                          editing.isPublished ? 'bg-emerald-500 text-white' : 'bg-zinc-100 text-zinc-500'
                        )}
                      >
                        {editing.isPublished ? <Check size={14} strokeWidth={4} /> : <div className="w-3.5 h-3.5 border-2 border-zinc-300 rounded-sm" />}
                        {editing.isPublished ? 'Published' : 'Draft Mode'}
                      </button>
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={handleSave}
                    className="w-full py-5 bg-zinc-900 text-white rounded-3xl font-display font-bold text-lg shadow-xl shadow-zinc-900/20 active:scale-95 transition-all"
                  >
                    Save Resource & Publish
                  </button>
                </div>
              </SisonkeCard>
            </motion.div>
          ) : (
            <div className="h-[600px] border-4 border-dashed border-zinc-100 rounded-[3rem] flex flex-col items-center justify-center p-12 text-center">
              <div className="w-20 h-20 bg-zinc-50 rounded-full flex items-center justify-center mb-6">
                <BookOpen className="text-zinc-200" size={32} />
              </div>
              <h4 className="text-xl font-display font-bold text-zinc-300 mb-2">Editor Inactive</h4>
              <p className="text-zinc-400 text-sm max-w-[200px]">Select a card to refine content or tap '+' to build a new wellness guide.</p>
            </div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
};
