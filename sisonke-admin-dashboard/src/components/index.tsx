import React from 'react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// ── SisonkeCard ────────────────────────────────────────────────────────────────
export const SisonkeCard = ({
  children,
  className,
  padding = 'p-8',
}: {
  children: React.ReactNode;
  className?: string;
  padding?: string;
}) => (
  <div
    className={cn(
      'bg-white border border-zinc-100 rounded-[1.75rem] shadow-sm hover:shadow-md transition-shadow',
      padding,
      className,
    )}
  >
    {children}
  </div>
);

// ── PageHeader ─────────────────────────────────────────────────────────────────
export const PageHeader = ({
  title,
  subtitle,
  action,
}: {
  title: string;
  subtitle?: string;
  action?: React.ReactNode;
}) => (
  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
    <div>
      <h3 className="text-2xl font-display font-black text-zinc-900 leading-tight">{title}</h3>
      {subtitle && <p className="text-zinc-500 font-medium mt-0.5">{subtitle}</p>}
    </div>
    {action && <div className="shrink-0">{action}</div>}
  </div>
);

// ── SectionLabel ──────────────────────────────────────────────────────────────
export const SectionLabel = ({ children, className }: { children: React.ReactNode; className?: string }) => (
  <p className={cn('text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400', className)}>
    {children}
  </p>
);

// ── RiskBadge ─────────────────────────────────────────────────────────────────
type RiskLevel = 'high' | 'medium' | 'low';

const riskConfig: Record<RiskLevel, { bg: string; text: string; dot: string; label: string }> = {
  high:   { bg: 'bg-[#FEE2E2]', text: 'text-[#F43F5E]', dot: 'bg-[#F43F5E]', label: 'High Risk' },
  medium: { bg: 'bg-[#FEF3C7]', text: 'text-[#F59E0B]', dot: 'bg-[#F59E0B]', label: 'Medium Risk' },
  low:    { bg: 'bg-[#D1FAE5]', text: 'text-[#10B981]', dot: 'bg-[#10B981]', label: 'Low Risk' },
};

export const RiskBadge = ({
  level,
  label,
  pulse,
}: {
  level: RiskLevel;
  label?: string;
  pulse?: boolean;
}) => {
  const cfg = riskConfig[level];
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider',
        cfg.bg,
        cfg.text,
      )}
    >
      <span className={cn('w-1.5 h-1.5 rounded-full', cfg.dot, pulse && 'animate-pulse')} />
      {label ?? cfg.label}
    </span>
  );
};

// ── PrimaryButton ─────────────────────────────────────────────────────────────
export const PrimaryButton = ({
  children,
  onClick,
  className,
  type = 'button',
  disabled,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  className?: string;
  type?: 'button' | 'submit' | 'reset';
  disabled?: boolean;
}) => (
  <button
    type={type}
    onClick={onClick}
    disabled={disabled}
    className={cn(
      'flex items-center justify-center gap-2 px-6 py-3.5 bg-primary text-white rounded-[1.75rem] font-bold',
      'shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 active:translate-y-0 transition-all',
      'disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0',
      className,
    )}
  >
    {children}
  </button>
);

// ── GhostButton ───────────────────────────────────────────────────────────────
export const GhostButton = ({
  children,
  onClick,
  className,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  className?: string;
}) => (
  <button
    type="button"
    onClick={onClick}
    className={cn(
      'flex items-center justify-center gap-2 px-6 py-3.5 border border-zinc-200 text-zinc-600 rounded-[1.75rem] font-bold',
      'hover:bg-primary-dim hover:text-primary hover:border-primary-mid transition-all',
      className,
    )}
  >
    {children}
  </button>
);

// ── StatTile ──────────────────────────────────────────────────────────────────
export const StatTile = ({
  title,
  value,
  icon: Icon,
  iconColor,
  iconBg,
  trend,
}: {
  title: string;
  value: string | number;
  icon: React.ComponentType<{ size?: number; strokeWidth?: number }>;
  iconColor: string;
  iconBg: string;
  trend?: string;
}) => (
  <SisonkeCard className="group">
    <div className="flex items-center gap-4 mb-4">
      <div
        className={cn(
          'p-3 rounded-2xl transition-transform group-hover:scale-110 group-hover:rotate-6',
          iconBg,
          iconColor,
        )}
      >
        <Icon size={28} strokeWidth={2.5} />
      </div>
      <SectionLabel>{title}</SectionLabel>
    </div>
    <div className="flex items-baseline gap-2">
      <h3 className="text-4xl font-display font-black text-zinc-900 tracking-tight">
        {typeof value === 'number' ? value.toLocaleString() : value}
      </h3>
      {trend && <span className="text-xs font-bold text-emerald-500">{trend}</span>}
    </div>
  </SisonkeCard>
);

// ── EmptyState ────────────────────────────────────────────────────────────────
export const EmptyState = ({
  icon: Icon,
  title,
  description,
  action,
}: {
  icon: React.ComponentType<{ size?: number; className?: string }>;
  title: string;
  description?: string;
  action?: React.ReactNode;
}) => (
  <div className="flex flex-col items-center justify-center py-20 text-center px-8">
    <div className="w-16 h-16 rounded-[1.75rem] bg-primary-dim flex items-center justify-center mb-5">
      <Icon size={28} className="text-primary" />
    </div>
    <h4 className="text-lg font-display font-black text-zinc-900 mb-2">{title}</h4>
    {description && <p className="text-zinc-500 text-sm max-w-xs mb-6">{description}</p>}
    {action}
  </div>
);

// ── SkeletonBlock ─────────────────────────────────────────────────────────────
export const SkeletonBlock = ({ className }: { className?: string }) => (
  <div className={cn('animate-pulse bg-primary-dim rounded-2xl', className)} />
);

export const SkeletonCard = () => (
  <SisonkeCard>
    <div className="space-y-4">
      <SkeletonBlock className="h-5 w-32" />
      <SkeletonBlock className="h-10 w-24" />
    </div>
  </SisonkeCard>
);
