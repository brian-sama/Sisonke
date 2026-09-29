import React, { useState, useEffect } from 'react';
import { Bell, Send } from 'lucide-react';
import { apiFetch } from '../lib/api';
import { SisonkeCard, PageHeader, SectionLabel, EmptyState, SkeletonCard } from '../components';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

type CampaignStatus = 'Draft' | 'Sent' | 'Scheduled';

type Campaign = {
  id: string;
  title: string;
  status: CampaignStatus;
  segment: string;
  sentAt: string;
};

const campaignStatusStyle: Record<CampaignStatus, { bg: string; text: string }> = {
  Draft: { bg: 'bg-zinc-100', text: 'text-zinc-500' },
  Sent: { bg: 'bg-[#D1FAE5]', text: 'text-[#10B981]' },
  Scheduled: { bg: 'bg-[#FEF3C7]', text: 'text-[#F59E0B]' },
};

const SEGMENT_OPTIONS = ['All users', 'Inactive (7+ days)', 'High-risk', 'Age group'];
const AGE_GROUP_OPTIONS = ['13–15', '16–18', '19–24'];

export const OutreachCampaigns: React.FC = () => {
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [segment, setSegment] = useState('All users');
  const [ageGroup, setAgeGroup] = useState('13–15');
  const [scheduleMode, setScheduleMode] = useState<'now' | 'later'>('now');
  const [scheduleAt, setScheduleAt] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    apiFetch('/api/admin/outreach')
      .then(async (res) => {
        const payload = await res.json();
        setCampaigns(Array.isArray(payload) ? payload : payload.data ?? []);
      })
      .catch(() => setError('Outreach campaigns are currently unavailable.'))
      .finally(() => setLoading(false));
  }, []);

  const resetForm = () => {
    setTitle('');
    setMessage('');
    setSegment('All users');
    setAgeGroup('13–15');
    setScheduleMode('now');
    setScheduleAt('');
  };

  const submitCampaign = async (status: 'Draft' | 'Sent' | 'Scheduled') => {
    if (!title.trim() || !message.trim()) return;
    setSaving(true);
    const payload = {
      title,
      message,
      segment: segment === 'Age group' ? `Age group ${ageGroup}` : segment,
      status,
      scheduleAt: status === 'Scheduled' ? scheduleAt : undefined,
    };
    try {
      const response = await apiFetch('/api/admin/outreach', { method: 'POST', body: JSON.stringify(payload) });
      if (!response.ok) throw new Error('Campaign could not be saved.');
      const newCampaign: Campaign = {
        id: `c${Date.now()}`,
        title: payload.title,
        status,
        segment: payload.segment,
        sentAt: status === 'Sent' ? 'Just now' : status === 'Scheduled' ? scheduleAt : '—',
      };
      setCampaigns((prev) => [newCampaign, ...prev]);
      resetForm();
    } finally {
      setSaving(false);
    }
  };

  const statusCfg = campaignStatusStyle;

  return (
    <div className="p-6 lg:p-10 max-w-7xl mx-auto">
      <div className="mb-8">
        <PageHeader title="Outreach Campaigns" subtitle="Send targeted push notifications to user segments" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Campaign list */}
        <div className="space-y-3">
          <SectionLabel className="px-1 mb-3">All Campaigns</SectionLabel>
          {error ? (
            <EmptyState icon={Bell} title="Outreach unavailable" description={error} />
          ) : loading ? (
            [1, 2, 3].map((i) => <SkeletonCard key={i} />)
          ) : campaigns.length === 0 ? (
            <EmptyState icon={Bell} title="No campaigns yet" description="Create your first outreach campaign." />
          ) : (
            campaigns.map((c) => (
              <SisonkeCard key={c.id} className="p-5 flex items-start justify-between gap-4">
                <div className="space-y-1 min-w-0">
                  <h5 className="font-display font-black text-zinc-900 truncate">{c.title}</h5>
                  <p className="text-[11px] font-bold text-zinc-400 uppercase tracking-widest">{c.segment}</p>
                  <p className="text-xs text-zinc-400">{c.sentAt}</p>
                </div>
                <span
                  className={cn(
                    'shrink-0 inline-flex items-center px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider',
                    statusCfg[c.status]?.bg || 'bg-zinc-100',
                    statusCfg[c.status]?.text || 'text-zinc-500'
                  )}
                >
                  {c.status}
                </span>
              </SisonkeCard>
            ))
          )}
        </div>

        {/* Builder form */}
        <SisonkeCard className="p-8 space-y-6 border-2 border-primary-dim self-start lg:sticky lg:top-24">
          <h4 className="font-display font-black text-zinc-900 text-lg">Campaign Builder</h4>

          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Campaign Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. World Mental Health Day"
              className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none transition-all placeholder:text-zinc-300"
            />
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between px-1">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest">Message</label>
              <span className={cn('text-[10px] font-black', message.length > 150 ? 'text-rose-500' : 'text-zinc-400')}>
                {message.length}/160
              </span>
            </div>
            <textarea
              rows={4}
              maxLength={160}
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Write a clear, supportive message..."
              className="w-full p-4 bg-zinc-50 border border-zinc-200 rounded-2xl font-medium text-sm leading-relaxed focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none transition-all resize-none placeholder:text-zinc-300"
            />
          </div>

          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Target Segment</label>
            <select
              value={segment}
              onChange={(e) => setSegment(e.target.value)}
              className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold text-sm focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none"
            >
              {SEGMENT_OPTIONS.map((o) => (
                <option key={o}>{o}</option>
              ))}
            </select>
          </div>

          {segment === 'Age group' && (
            <div className="space-y-2">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Age Group</label>
              <select
                value={ageGroup}
                onChange={(e) => setAgeGroup(e.target.value)}
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold text-sm focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none"
              >
                {AGE_GROUP_OPTIONS.map((o) => (
                  <option key={o}>{o}</option>
                ))}
              </select>
            </div>
          )}

          <div className="space-y-2">
            <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Send Schedule</label>
            <div className="flex gap-2">
              {(['now', 'later'] as const).map((mode) => (
                <button
                  key={mode}
                  type="button"
                  onClick={() => setScheduleMode(mode)}
                  className={cn(
                    'flex-1 py-3 rounded-2xl text-xs font-black uppercase tracking-widest transition-all',
                    scheduleMode === mode
                      ? 'bg-primary text-white shadow-lg shadow-primary/20'
                      : 'bg-zinc-100 text-zinc-500 hover:bg-primary-dim hover:text-primary'
                  )}
                >
                  {mode === 'now' ? 'Send Now' : 'Schedule'}
                </button>
              ))}
            </div>
          </div>

          {scheduleMode === 'later' && (
            <div className="space-y-2">
              <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest px-1">Date & Time</label>
              <input
                type="datetime-local"
                value={scheduleAt}
                onChange={(e) => setScheduleAt(e.target.value)}
                className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-2xl font-bold text-sm focus:ring-4 focus:ring-primary/20 focus:border-primary outline-none"
              />
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <button
              type="button"
              disabled={saving || !title.trim() || !message.trim()}
              onClick={() => submitCampaign('Draft')}
              className="flex-1 py-3.5 border-2 border-zinc-200 text-zinc-600 rounded-[1.75rem] font-bold text-sm hover:bg-zinc-50 transition-all disabled:opacity-40 disabled:cursor-not-allowed"
            >
              Save Draft
            </button>
            <button
              type="button"
              disabled={saving || !title.trim() || !message.trim() || (scheduleMode === 'later' && !scheduleAt)}
              onClick={() => submitCampaign(scheduleMode === 'later' ? 'Scheduled' : 'Sent')}
              className="flex-1 py-3.5 bg-primary text-white rounded-[1.75rem] font-bold text-sm shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 active:translate-y-0 transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              <Send size={16} strokeWidth={3} />
              {scheduleMode === 'later' ? 'Schedule' : 'Send Campaign'}
            </button>
          </div>
        </SisonkeCard>
      </div>
    </div>
  );
};
