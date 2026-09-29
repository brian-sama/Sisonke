import React, { useState, useEffect } from 'react';
import { Search, Plus, Edit2, Trash2, Phone } from 'lucide-react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, EmptyState, SkeletonBlock } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const EmergencyContacts: React.FC = () => {
  const [contacts, setContacts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    apiFetch('/api/emergency/contacts')
      .then(async (res) => {
        const payload = await res.json();
        const list = Array.isArray(payload) ? payload : payload.data?.contacts ?? payload.contacts ?? [];
        // Flatten categories if structured as category map
        if (!Array.isArray(list) && typeof list === 'object') {
          const flattened: any[] = [];
          Object.keys(list).forEach((cat) => {
            (list[cat] || []).forEach((c: any) => flattened.push({ ...c, category: cat }));
          });
          setContacts(flattened);
        } else {
          setContacts(list);
        }
      })
      .catch(() => setContacts([]))
      .finally(() => setLoading(false));
  }, []);

  const filtered = contacts.filter((c) =>
    (c.name || c.helplineName || '').toLowerCase().includes(search.toLowerCase()) ||
    (c.category || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div className="relative flex-1 max-w-lg">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} />
          <input
            type="text"
            placeholder="Find specialized support contacts..."
            className="w-full pl-12 pr-6 py-4 bg-white border border-zinc-200 rounded-2xl shadow-sm focus:ring-4 focus:ring-primary/10 focus:border-primary focus:outline-none transition-all placeholder:text-zinc-400 font-medium"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <button className="flex items-center justify-center gap-2 px-6 py-4 bg-primary text-white rounded-2xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 active:translate-y-0 transition-all">
          <Plus size={20} strokeWidth={3} /> Add New Contact
        </button>
      </div>

      <SisonkeCard className="p-0 overflow-hidden">
        {loading ? (
          <div className="p-8 space-y-4">
            <SkeletonBlock className="h-12 w-full" />
            <SkeletonBlock className="h-12 w-full" />
            <SkeletonBlock className="h-12 w-full" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="p-10">
            <EmptyState
              icon={Phone}
              title="No emergency contacts found"
              description="No contacts match your query. Add a contact or change filters."
            />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead className="bg-zinc-50/50 border-b border-zinc-100">
                <tr>
                  <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">
                    Contact Details
                  </th>
                  <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">
                    Classification
                  </th>
                  <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">
                    Direct Line
                  </th>
                  <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400">
                    Live Status
                  </th>
                  <th className="px-8 py-5 text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 text-right">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100">
                {filtered.map((contact) => (
                  <tr key={contact.id} className="hover:bg-primary-dim/30 transition-colors group">
                    <td className="px-8 py-6">
                      <div className="font-display font-bold text-zinc-900 text-base">
                        {contact.name || contact.helplineName}
                      </div>
                      <div className="text-sm text-zinc-500 mt-0.5 line-clamp-1">
                        {contact.description || contact.languages?.join(', ') || 'Helpline support'}
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <span className="inline-flex items-center px-3 py-1 rounded-xl text-[11px] font-black uppercase tracking-wider bg-white border border-zinc-100 text-zinc-600 shadow-sm">
                        {(contact.category || 'general').replace('-', ' ')}
                      </span>
                    </td>
                    <td className="px-8 py-6 font-mono text-base font-bold text-primary">
                      {contact.phoneNumber || contact.number}
                    </td>
                    <td className="px-8 py-6">
                      <div
                        className={cn(
                          'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter',
                          contact.isActive !== false ? 'bg-emerald-100 text-emerald-700' : 'bg-zinc-100 text-zinc-500'
                        )}
                      >
                        <div
                          className={cn(
                            'w-1.5 h-1.5 rounded-full',
                            contact.isActive !== false ? 'bg-emerald-500 animate-pulse' : 'bg-zinc-400'
                          )}
                        />
                        {contact.isActive !== false ? 'Active' : 'Offline'}
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button
                          type="button"
                          aria-label="Edit contact"
                          className="p-2.5 text-zinc-400 hover:text-primary hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-100 transition-all"
                        >
                          <Edit2 size={18} />
                        </button>
                        <button
                          type="button"
                          aria-label="Remove contact"
                          className="p-2.5 text-zinc-400 hover:text-rose-600 hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-100 transition-all"
                        >
                          <Trash2 size={18} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </SisonkeCard>
    </div>
  );
};
