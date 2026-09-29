import React, { useState, useEffect } from 'react';
import { Search, Plus, AlertTriangle, Users } from 'lucide-react';
import { apiFetch } from '../lib/api';
import {
  SisonkeCard,
  PageHeader,
  SectionLabel,
  RiskBadge,
  PrimaryButton,
  GhostButton,
  EmptyState,
  SkeletonBlock,
} from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const roleOptions = [
  { value: 'super-admin', label: 'Super Admin' },
  { value: 'admin', label: 'System Admin' },
  { value: 'counselor', label: 'Counselor' },
  { value: 'moderator', label: 'Community Moderator' },
  { value: 'content-manager', label: 'Content Manager' },
  { value: 'safety-reviewer', label: 'Safety Reviewer' },
  { value: 'analyst', label: 'Reports Analyst' },
  { value: 'user', label: 'Standard User' },
];

export const PeopleManagement: React.FC = () => {
  const blankForm = {
    id: '',
    email: '',
    name: '',
    avatarUrl: '',
    password: '',
    roles: ['user'],
    mustChangePassword: true,
    isSuspended: false,
  };
  const [people, setPeople] = useState<any[]>([]);
  const [form, setForm] = useState<any>(blankForm);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterRole, setFilterRole] = useState('all');

  const loadPeople = async () => {
    try {
      setLoading(true);
      const res = await apiFetch('/api/admin/users');
      const payload = await res.json();
      if (!res.ok || !payload.success) throw new Error(payload.error || 'Failed to load team members.');
      setPeople(Array.isArray(payload.data) ? payload.data : []);
      setError('');
    } catch (err: any) {
      setError(err instanceof Error ? err.message : 'Could not load users.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPeople();
  }, []);

  const toggleRole = (role: string) => {
    setForm((current: any) => {
      const roles = current.roles.includes(role)
        ? current.roles.filter((item: string) => item !== role)
        : [...current.roles, role];
      return { ...current, roles: roles.length ? roles : ['user'] };
    });
  };

  const editPerson = (person: any) => {
    setForm({
      id: person.id,
      email: person.email || '',
      name: person.name || '',
      avatarUrl: person.avatarUrl || '',
      password: '',
      roles: person.roles?.length ? person.roles : [person.role || 'user'],
      mustChangePassword: Boolean(person.mustChangePassword),
      isSuspended: Boolean(person.isSuspended),
    });
    setMessage('');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const savePerson = async (event: React.FormEvent) => {
    event.preventDefault();
    setMessage('');
    setError('');
    if (!form.email.trim()) return setMessage('Please enter an email address.');
    if (!form.id && !form.password) return setMessage('Please enter an initial password.');

    try {
      if (form.id) {
        const res = await apiFetch(`/api/admin/users/${form.id}`, {
          method: 'PUT',
          body: JSON.stringify({
            email: form.email,
            name: form.name || null,
            avatarUrl: form.avatarUrl || null,
            roles: form.roles,
            mustChangePassword: form.mustChangePassword,
            isSuspended: form.isSuspended,
          }),
        });
        const payload = await res.json();
        if (!res.ok || !payload.success) throw new Error(payload.error || 'Failed to update user.');

        if (form.password) {
          const passRes = await apiFetch(`/api/admin/users/${form.id}/password`, {
            method: 'PUT',
            body: JSON.stringify({ password: form.password, mustChangePassword: form.mustChangePassword }),
          });
          const passPayload = await passRes.json();
          if (!passRes.ok || !passPayload.success) throw new Error(passPayload.error || 'Password update failed.');
        }
        setMessage('User updated successfully.');
      } else {
        const res = await apiFetch('/api/admin/users', {
          method: 'POST',
          body: JSON.stringify({
            email: form.email,
            password: form.password,
            name: form.name || undefined,
            avatarUrl: form.avatarUrl || undefined,
            roles: form.roles,
            mustChangePassword: form.mustChangePassword,
          }),
        });
        const payload = await res.json();
        if (!res.ok || !payload.success) throw new Error(payload.error || 'Failed to add user.');
        setMessage('New team member added successfully.');
      }
      setForm(blankForm);
      await loadPeople();
    } catch (err: any) {
      setMessage(err instanceof Error ? err.message : 'Failed to save person.');
    }
  };

  const filteredPeople = people.filter((p) => {
    const matchesSearch =
      (p.name || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.email || '').toLowerCase().includes(search.toLowerCase());
    const matchesRole = filterRole === 'all' || (p.roles || []).includes(filterRole);
    return matchesSearch && matchesRole;
  });

  return (
    <div className="p-6 lg:p-10 space-y-10 max-w-7xl mx-auto">
      <PageHeader
        title="People & Roles"
        subtitle="Manage team members, assign clinical/administrative roles, and control access permissions."
        action={
          <PrimaryButton onClick={() => setForm(blankForm)} className="text-xs">
            <Plus size={16} /> Add Member
          </PrimaryButton>
        }
      />

      {error && (
        <div className="p-4 bg-rose-50 border border-rose-100 text-rose-800 rounded-2xl font-bold flex items-center gap-3">
          <AlertTriangle className="text-rose-600 shrink-0" size={20} />
          <span>{error}</span>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-[400px_1fr] gap-8">
        <SisonkeCard className="p-8 h-fit">
          <SectionLabel className="mb-2">Member Account</SectionLabel>
          <h4 className="text-xl font-display font-black text-zinc-900 mb-6">
            {form.id ? 'Edit Team Member' : 'New Team Member'}
          </h4>

          <form onSubmit={savePerson} className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-zinc-600">Email Address</label>
              <input
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl outline-none focus:ring-4 focus:ring-primary/10 focus:border-primary font-medium text-sm"
                value={form.email}
                onChange={(e) => setForm({ ...form, email: e.target.value })}
                type="email"
                placeholder="colleague@sisonke.org"
                required
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-zinc-600">Full Name</label>
              <input
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl outline-none focus:ring-4 focus:ring-primary/10 focus:border-primary font-medium text-sm"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                placeholder="e.g. Brian Magagula"
                type="text"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-zinc-600">Avatar Image URL (Optional)</label>
              <input
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl outline-none focus:ring-4 focus:ring-primary/10 focus:border-primary font-medium text-sm"
                value={form.avatarUrl}
                onChange={(e) => setForm({ ...form, avatarUrl: e.target.value })}
                placeholder="https://images.unsplash.com/..."
                type="url"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-zinc-600">
                {form.id ? 'Reset Password (optional)' : 'Initial Password'}
              </label>
              <input
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl outline-none focus:ring-4 focus:ring-primary/10 focus:border-primary font-medium text-sm"
                value={form.password}
                onChange={(e) => setForm({ ...form, password: e.target.value })}
                placeholder={form.id ? 'Leave blank to keep unchanged' : 'Min 8 characters'}
                type="password"
                minLength={form.id && !form.password ? 0 : 8}
              />
            </div>

            <div className="space-y-2 pt-2">
              <label className="text-xs font-bold text-zinc-600">Permissions & Roles</label>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {roleOptions.map((role) => {
                  const isChecked = form.roles.includes(role.value);
                  return (
                    <label
                      key={role.value}
                      className={cn(
                        'flex items-center gap-2.5 px-3 py-2.5 rounded-xl border text-xs font-bold cursor-pointer transition-all',
                        isChecked
                          ? 'bg-primary-dim border-primary text-primary-dark shadow-sm'
                          : 'bg-white border-zinc-200 text-zinc-500 hover:border-zinc-300'
                      )}
                    >
                      <input
                        type="checkbox"
                        className="accent-primary"
                        checked={isChecked}
                        onChange={() => toggleRole(role.value)}
                      />
                      {role.label}
                    </label>
                  );
                })}
              </div>
            </div>

            <div className="pt-2 space-y-2">
              <label className="flex items-center gap-3 p-3 bg-amber-50 text-amber-900 border border-amber-200/60 rounded-xl font-bold text-xs cursor-pointer">
                <input
                  type="checkbox"
                  className="accent-amber-600"
                  checked={form.mustChangePassword}
                  onChange={(e) => setForm({ ...form, mustChangePassword: e.target.checked })}
                />
                Require password change on next login
              </label>

              {form.id && (
                <label className="flex items-center gap-3 p-3 bg-rose-50 text-rose-900 border border-rose-200/60 rounded-xl font-bold text-xs cursor-pointer">
                  <input
                    type="checkbox"
                    className="accent-rose-600"
                    checked={form.isSuspended}
                    onChange={(e) => setForm({ ...form, isSuspended: e.target.checked })}
                  />
                  Suspend / pause account access
                </label>
              )}
            </div>

            <div className="flex gap-3 pt-3">
              <PrimaryButton type="submit" className="flex-1 text-sm py-3">
                {form.id ? 'Save Changes' : 'Create Member'}
              </PrimaryButton>
              {form.id && (
                <GhostButton onClick={() => setForm(blankForm)} className="text-sm py-3 px-5">
                  Cancel
                </GhostButton>
              )}
            </div>

            {message && (
              <p
                className={cn(
                  'text-xs font-bold text-center mt-2 p-2 rounded-lg',
                  message.includes('success') || message.includes('added') || message.includes('updated')
                    ? 'bg-emerald-50 text-emerald-700'
                    : 'bg-amber-50 text-amber-700'
                )}
              >
                {message}
              </p>
            )}
          </form>
        </SisonkeCard>

        <div className="space-y-6">
          <div className="flex flex-col sm:flex-row gap-4 justify-between items-center bg-white p-4 rounded-2xl border border-zinc-100 shadow-sm">
            <div className="relative w-full sm:w-72">
              <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-zinc-400" size={16} />
              <input
                type="text"
                placeholder="Search by name or email..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full pl-9 pr-4 py-2 bg-zinc-50 border border-zinc-200 rounded-xl text-xs font-medium outline-none focus:border-primary"
              />
            </div>
            <div className="flex items-center gap-2 w-full sm:w-auto">
              <span className="text-xs font-bold text-zinc-500">Filter:</span>
              <select
                value={filterRole}
                onChange={(e) => setFilterRole(e.target.value)}
                className="px-3 py-2 bg-zinc-50 border border-zinc-200 rounded-xl text-xs font-bold text-zinc-700 outline-none"
              >
                <option value="all">All Roles</option>
                {roleOptions.map((r) => (
                  <option key={r.value} value={r.value}>
                    {r.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <SisonkeCard className="p-0 overflow-hidden">
            {loading ? (
              <div className="p-10 space-y-4">
                <SkeletonBlock className="h-10 w-full" />
                <SkeletonBlock className="h-10 w-full" />
                <SkeletonBlock className="h-10 w-full" />
              </div>
            ) : filteredPeople.length === 0 ? (
              <div className="p-10">
                <EmptyState
                  icon={Users}
                  title="No team members found"
                  description="Try adjusting your search query or add a new team member."
                />
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left">
                  <thead className="bg-zinc-50 border-b border-zinc-100">
                    <tr>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-wider text-zinc-400">Member</th>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-wider text-zinc-400">Roles</th>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-wider text-zinc-400">Status</th>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-wider text-zinc-400 text-right">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-zinc-100">
                    {filteredPeople.map((person) => (
                      <tr key={person.id} className="hover:bg-zinc-50/50 transition-colors">
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-3">
                            {person.avatarUrl ? (
                              <img
                                src={person.avatarUrl}
                                alt={person.name || person.email}
                                className="w-9 h-9 rounded-full object-cover shrink-0 border border-zinc-200"
                              />
                            ) : (
                              <div className="w-9 h-9 rounded-full bg-primary/10 text-primary-dark flex items-center justify-center font-bold text-xs shrink-0">
                                {(person.name || person.email || '?').charAt(0).toUpperCase()}
                              </div>
                            )}
                            <div>
                              <div className="font-bold text-sm text-zinc-900 leading-tight">
                                {person.name || person.email}
                              </div>
                              {person.name && <div className="text-xs text-zinc-400 font-normal">{person.email}</div>}
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex flex-wrap gap-1.5 max-w-xs">
                            {(person.roles || []).map((role: string) => {
                              const label = roleOptions.find((r) => r.value === role)?.label || role;
                              return (
                                <span
                                  key={role}
                                  className="px-2.5 py-0.5 bg-zinc-100 text-zinc-600 rounded-lg text-[10px] font-bold"
                                >
                                  {label}
                                </span>
                              );
                            })}
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="space-y-1">
                            {person.isSuspended ? (
                              <RiskBadge level="high" label="Suspended" />
                            ) : (
                              <RiskBadge level="low" label="Active" />
                            )}
                            {person.mustChangePassword && (
                              <div className="text-[10px] font-bold text-amber-700">Must reset pwd</div>
                            )}
                          </div>
                        </td>
                        <td className="px-6 py-4 text-right">
                          <button
                            onClick={() => editPerson(person)}
                            className="px-3 py-1.5 bg-zinc-100 hover:bg-primary hover:text-white text-zinc-700 rounded-xl text-xs font-bold transition-all"
                          >
                            Edit
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </SisonkeCard>
        </div>
      </div>
    </div>
  );
};
