import React, { useState, useEffect, useId } from 'react';
import { Search, Plus, Edit2, Trash2, Phone, PhoneCall, X } from 'lucide-react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, EmptyState, SkeletonBlock, ConfirmDialog, LiveAnnouncer } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const EmergencyContacts: React.FC = () => {
  const [contacts, setContacts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [announcement, setAnnouncement] = useState('');
  
  // Dialog and Form States
  const [contactToDelete, setContactToDelete] = useState<any | null>(null);
  const [editingContact, setEditingContact] = useState<any | null>(null);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [formData, setFormData] = useState({
    id: '',
    name: '',
    phoneNumber: '',
    category: 'gbv',
    description: '',
    country: 'Zimbabwe',
    isActive: true,
  });

  const searchInputId = useId();

  const fetchContacts = () => {
    setLoading(true);
    apiFetch('/api/emergency/contacts')
      .then(async (res) => {
        const payload = await res.json();
        const list = Array.isArray(payload) ? payload : payload.data?.contacts ?? payload.contacts ?? [];
        if (!Array.isArray(list) && typeof list === 'object') {
          const flattened: any[] = [];
          Object.keys(list).forEach((cat) => {
            (list[cat] || []).forEach((c: any) => flattened.push({ ...c, category: cat }));
          });
          setContacts(flattened);
        } else {
          setContacts(list);
        }
        setAnnouncement(`Loaded ${list.length} emergency contacts.`);
      })
      .catch(() => {
        setContacts([]);
        setAnnouncement('Failed to load emergency contacts.');
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchContacts();
  }, []);

  const filtered = contacts.filter((c) =>
    (c.name || c.helplineName || '').toLowerCase().includes(search.toLowerCase()) ||
    (c.category || '').toLowerCase().includes(search.toLowerCase())
  );

  const handleDeleteConfirm = async () => {
    if (!contactToDelete) return;
    try {
      await apiFetch(`/api/emergency/contacts/${contactToDelete.id}`, { method: 'DELETE' });
      setContacts((prev) => prev.filter((c) => c.id !== contactToDelete.id));
      setAnnouncement(`Contact ${contactToDelete.name} was removed.`);
    } catch (err) {
      console.error('Delete contact error:', err);
    } finally {
      setContactToDelete(null);
    }
  };

  const handleOpenAdd = () => {
    setFormData({
      id: '',
      name: '',
      phoneNumber: '',
      category: 'gbv',
      description: '',
      country: 'Zimbabwe',
      isActive: true,
    });
    setEditingContact(null);
    setIsFormOpen(true);
  };

  const handleOpenEdit = (contact: any) => {
    setFormData({
      id: contact.id,
      name: contact.name || contact.helplineName || '',
      phoneNumber: contact.phoneNumber || contact.number || '',
      category: contact.category || 'gbv',
      description: contact.description || '',
      country: contact.country || 'Zimbabwe',
      isActive: contact.isActive !== false,
    });
    setEditingContact(contact);
    setIsFormOpen(true);
  };

  const handleSaveContact = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.phoneNumber.trim()) return;

    try {
      if (formData.id) {
        await apiFetch(`/api/emergency/contacts/${formData.id}`, {
          method: 'PUT',
          body: JSON.stringify(formData),
        });
        setContacts((prev) => prev.map((c) => (c.id === formData.id ? { ...c, ...formData } : c)));
        setAnnouncement(`Contact ${formData.name} updated successfully.`);
      } else {
        const res = await apiFetch('/api/emergency/contacts', {
          method: 'POST',
          body: JSON.stringify(formData),
        });
        const newContact = await res.json();
        setContacts((prev) => [...prev, newContact]);
        setAnnouncement(`New contact ${formData.name} added.`);
      }
      setIsFormOpen(false);
    } catch (err) {
      console.error('Save contact error:', err);
    }
  };

  return (
    <div className="p-6 lg:p-10 space-y-8 max-w-7xl mx-auto">
      <LiveAnnouncer message={announcement} />

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div className="relative flex-1 max-w-lg">
          <label htmlFor={searchInputId} className="sr-only">
            Search emergency helpline contacts
          </label>
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={20} aria-hidden="true" />
          <input
            id={searchInputId}
            type="text"
            placeholder="Search specialized support hotlines..."
            className="w-full pl-12 pr-6 py-4 bg-white border border-zinc-200 rounded-2xl shadow-sm focus:ring-4 focus:ring-primary/10 focus:border-primary focus:outline-none transition-all placeholder:text-zinc-400 font-medium"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <button
          type="button"
          onClick={handleOpenAdd}
          className="flex items-center justify-center gap-2 px-6 py-4 bg-primary text-white rounded-2xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 active:translate-y-0 transition-all focus-visible:ring-4 focus-visible:ring-primary/20"
        >
          <Plus size={20} strokeWidth={3} aria-hidden="true" /> Add New Contact
        </button>
      </div>

      <SisonkeCard className="p-0 overflow-hidden">
        {loading ? (
          <div className="p-8 space-y-4" role="status" aria-label="Loading emergency contacts">
            <SkeletonBlock className="h-12 w-full" />
            <SkeletonBlock className="h-12 w-full" />
            <SkeletonBlock className="h-12 w-full" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="p-10">
            <EmptyState
              icon={Phone}
              title="No emergency contacts found"
              description="No contacts match your query. Add a new contact or clear search filters."
            />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse" aria-label="Emergency helpline directory">
              <thead className="bg-zinc-50/80 border-b border-zinc-100">
                <tr>
                  <th scope="col" className="px-8 py-5 text-[11px] font-black uppercase tracking-[0.2em] text-zinc-500">
                    Contact Details
                  </th>
                  <th scope="col" className="px-8 py-5 text-[11px] font-black uppercase tracking-[0.2em] text-zinc-500">
                    Classification
                  </th>
                  <th scope="col" className="px-8 py-5 text-[11px] font-black uppercase tracking-[0.2em] text-zinc-500">
                    Direct Line
                  </th>
                  <th scope="col" className="px-8 py-5 text-[11px] font-black uppercase tracking-[0.2em] text-zinc-500">
                    Live Status
                  </th>
                  <th scope="col" className="px-8 py-5 text-[11px] font-black uppercase tracking-[0.2em] text-zinc-500 text-right">
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
                      <div className="text-sm text-zinc-600 mt-0.5 line-clamp-1">
                        {contact.description || contact.languages?.join(', ') || 'Helpline support'}
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <span className="inline-flex items-center px-3 py-1 rounded-xl text-[11px] font-black uppercase tracking-wider bg-white border border-zinc-200 text-zinc-700 shadow-sm">
                        {(contact.category || 'general').replace('-', ' ')}
                      </span>
                    </td>
                    <td className="px-8 py-6">
                      <a
                        href={`tel:${contact.phoneNumber || contact.number}`}
                        className="inline-flex items-center gap-2 font-mono text-base font-bold text-primary hover:underline focus-visible:ring-2 focus-visible:ring-primary rounded-lg px-1"
                        aria-label={`Call ${contact.name || 'helpline'} at ${contact.phoneNumber || contact.number}`}
                      >
                        <PhoneCall size={16} aria-hidden="true" />
                        {contact.phoneNumber || contact.number}
                      </a>
                    </td>
                    <td className="px-8 py-6">
                      <div
                        className={cn(
                          'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-black uppercase tracking-tighter',
                          contact.isActive !== false ? 'bg-emerald-100 text-emerald-800' : 'bg-zinc-100 text-zinc-600'
                        )}
                      >
                        <div
                          className={cn(
                            'w-2 h-2 rounded-full',
                            contact.isActive !== false ? 'bg-emerald-600 animate-pulse' : 'bg-zinc-400'
                          )}
                          aria-hidden="true"
                        />
                        {contact.isActive !== false ? 'Active' : 'Offline'}
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex items-center justify-end gap-3 opacity-90 sm:opacity-0 group-hover:opacity-100 focus-within:opacity-100 transition-opacity">
                        <button
                          type="button"
                          onClick={() => handleOpenEdit(contact)}
                          aria-label={`Edit contact ${contact.name || contact.helplineName}`}
                          className="p-2.5 text-zinc-500 hover:text-primary hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-200 transition-all focus-visible:ring-2 focus-visible:ring-primary"
                        >
                          <Edit2 size={18} aria-hidden="true" />
                        </button>
                        <button
                          type="button"
                          onClick={() => setContactToDelete(contact)}
                          aria-label={`Delete contact ${contact.name || contact.helplineName}`}
                          className="p-2.5 text-zinc-500 hover:text-rose-600 hover:bg-white rounded-xl shadow-sm border border-transparent hover:border-zinc-200 transition-all focus-visible:ring-2 focus-visible:ring-rose-500"
                        >
                          <Trash2 size={18} aria-hidden="true" />
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

      {/* Confirmation Modal for Contact Deletion */}
      <ConfirmDialog
        isOpen={Boolean(contactToDelete)}
        title="Delete Emergency Contact"
        description={`Are you sure you want to remove "${contactToDelete?.name || 'this contact'}" from the live emergency directory? Users in distress will no longer be able to reach this helpline directly.`}
        confirmText="Delete Contact"
        cancelText="Keep Contact"
        isDestructive={true}
        onConfirm={handleDeleteConfirm}
        onCancel={() => setContactToDelete(null)}
      />

      {/* Accessible Contact Form Modal */}
      {isFormOpen && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-900/60 backdrop-blur-sm"
          role="dialog"
          aria-modal="true"
          aria-labelledby="modal-contact-title"
        >
          <div className="w-full max-w-lg p-8 bg-white rounded-3xl shadow-2xl border border-zinc-100 space-y-6">
            <div className="flex items-center justify-between">
              <h3 id="modal-contact-title" className="text-xl font-display font-black text-zinc-900">
                {editingContact ? 'Edit Emergency Contact' : 'Add Emergency Helpline'}
              </h3>
              <button
                type="button"
                onClick={() => setIsFormOpen(false)}
                aria-label="Close dialog"
                className="p-2 text-zinc-400 hover:text-zinc-700 rounded-xl hover:bg-zinc-100"
              >
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleSaveContact} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-zinc-700 uppercase tracking-wider mb-1.5" htmlFor="c-name">
                  Helpline Name
                </label>
                <input
                  id="c-name"
                  type="text"
                  required
                  placeholder="e.g. Musasa Project GBV Line"
                  className="w-full px-4 py-3 border border-zinc-200 rounded-xl focus:ring-4 focus:ring-primary/10 focus:border-primary focus:outline-none"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-zinc-700 uppercase tracking-wider mb-1.5" htmlFor="c-phone">
                  Direct Phone Number
                </label>
                <input
                  id="c-phone"
                  type="text"
                  required
                  placeholder="e.g. 08080074 or +263..."
                  className="w-full px-4 py-3 border border-zinc-200 rounded-xl focus:ring-4 focus:ring-primary/10 focus:border-primary focus:outline-none font-mono"
                  value={formData.phoneNumber}
                  onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-zinc-700 uppercase tracking-wider mb-1.5" htmlFor="c-cat">
                    Category
                  </label>
                  <select
                    id="c-cat"
                    className="w-full px-4 py-3 border border-zinc-200 rounded-xl focus:ring-4 focus:ring-primary/10 focus:border-primary focus:outline-none"
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  >
                    <option value="gbv">GBV Support</option>
                    <option value="child-protection">Child Protection</option>
                    <option value="mental-health">Mental Health</option>
                    <option value="medical">Medical & SRHR</option>
                    <option value="legal">Legal Aid</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-zinc-700 uppercase tracking-wider mb-1.5" htmlFor="c-country">
                    Country
                  </label>
                  <input
                    id="c-country"
                    type="text"
                    className="w-full px-4 py-3 border border-zinc-200 rounded-xl focus:ring-4 focus:ring-primary/10 focus:border-primary focus:outline-none"
                    value={formData.country}
                    onChange={(e) => setFormData({ ...formData, country: e.target.value })}
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-zinc-700 uppercase tracking-wider mb-1.5" htmlFor="c-desc">
                  Support Details & Coverage
                </label>
                <textarea
                  id="c-desc"
                  rows={3}
                  placeholder="24/7 toll-free crisis intervention and shelter referrals..."
                  className="w-full px-4 py-3 border border-zinc-200 rounded-xl focus:ring-4 focus:ring-primary/10 focus:border-primary focus:outline-none resize-none"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100">
                <button
                  type="button"
                  onClick={() => setIsFormOpen(false)}
                  className="px-5 py-3 text-zinc-700 font-bold hover:bg-zinc-100 rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-6 py-3 bg-primary text-white font-bold rounded-xl shadow-lg shadow-primary/20 hover:bg-primary-dark"
                >
                  {editingContact ? 'Save Changes' : 'Create Contact'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
