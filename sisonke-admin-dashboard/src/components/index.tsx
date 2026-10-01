import React, { useEffect, useRef } from 'react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { AlertTriangle, X } from 'lucide-react';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// ── SkipLink (WCAG 2.1 Bypass Blocks) ──────────────────────────────────────────
export const SkipLink = ({ targetId = 'main-content' }: { targetId?: string }) => (
  <a
    href={`#${targetId}`}
    className="sr-only sr-only-focusable fixed top-4 left-4 z-50 px-6 py-3 bg-primary text-white font-bold rounded-xl shadow-2xl focus:outline-none ring-4 ring-primary-mid transition-all"
  >
    Skip to main content
  </a>
);

// ── LiveAnnouncer (Screen Reader Live Region) ──────────────────────────────────
export const LiveAnnouncer = ({ message }: { message: string }) => (
  <div role="status" aria-live="polite" aria-atomic="true" className="sr-only">
    {message}
  </div>
);

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
      {subtitle && <p className="text-zinc-600 font-medium mt-0.5">{subtitle}</p>}
    </div>
    {action && <div className="shrink-0">{action}</div>}
  </div>
);

// ── SectionLabel ──────────────────────────────────────────────────────────────
export const SectionLabel = ({ children, className }: { children: React.ReactNode; className?: string }) => (
  <p className={cn('text-[11px] font-black uppercase tracking-[0.2em] text-zinc-500', className)}>
    {children}
  </p>
);

// ── RiskBadge ─────────────────────────────────────────────────────────────────
type RiskLevel = 'high' | 'medium' | 'low';

const riskConfig: Record<RiskLevel, { bg: string; text: string; dot: string; label: string }> = {
  high:   { bg: 'bg-rose-100', text: 'text-rose-800', dot: 'bg-rose-600', label: 'High Risk' },
  medium: { bg: 'bg-amber-100', text: 'text-amber-900', dot: 'bg-amber-600', label: 'Medium Risk' },
  low:    { bg: 'bg-emerald-100', text: 'text-emerald-900', dot: 'bg-emerald-600', label: 'Low Risk' },
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
  const cfg = riskConfig[level] || riskConfig.low;
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-black uppercase tracking-wider',
        cfg.bg,
        cfg.text,
      )}
      role="status"
    >
      <span className={cn('w-2 h-2 rounded-full', cfg.dot, pulse && 'animate-pulse')} aria-hidden="true" />
      <span>{label ?? cfg.label}</span>
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
  ariaLabel,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  className?: string;
  type?: 'button' | 'submit' | 'reset';
  disabled?: boolean;
  ariaLabel?: string;
}) => (
  <button
    type={type}
    onClick={onClick}
    disabled={disabled}
    aria-label={ariaLabel}
    className={cn(
      'flex items-center justify-center gap-2 px-6 py-3.5 bg-primary text-white rounded-[1.75rem] font-bold min-h-[44px]',
      'shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5 active:translate-y-0 transition-all',
      'focus-visible:ring-4 focus-visible:ring-primary/20 focus-visible:outline-none',
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
  ariaLabel,
  disabled,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  className?: string;
  ariaLabel?: string;
  disabled?: boolean;
}) => (
  <button
    type="button"
    onClick={onClick}
    disabled={disabled}
    aria-label={ariaLabel}
    className={cn(
      'flex items-center justify-center gap-2 px-6 py-3.5 border border-zinc-200 text-zinc-700 rounded-[1.75rem] font-bold min-h-[44px]',
      'hover:bg-primary-dim hover:text-primary hover:border-primary-mid transition-all',
      'focus-visible:ring-4 focus-visible:ring-primary/20 focus-visible:outline-none',
      'disabled:opacity-50 disabled:cursor-not-allowed',
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
  icon: React.ComponentType<{ size?: number; strokeWidth?: number; 'aria-hidden'?: boolean }>;
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
        <Icon size={28} strokeWidth={2.5} aria-hidden={true} />
      </div>
      <SectionLabel>{title}</SectionLabel>
    </div>
    <div className="flex items-baseline gap-2">
      <h3 className="text-4xl font-display font-black text-zinc-900 tracking-tight">
        {typeof value === 'number' ? value.toLocaleString() : value}
      </h3>
      {trend && <span className="text-xs font-bold text-emerald-600">{trend}</span>}
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
  icon: React.ComponentType<{ size?: number; className?: string; 'aria-hidden'?: boolean }>;
  title: string;
  description?: string;
  action?: React.ReactNode;
}) => (
  <div className="flex flex-col items-center justify-center py-20 text-center px-8" role="status">
    <div className="w-16 h-16 rounded-[1.75rem] bg-primary-dim flex items-center justify-center mb-5">
      <Icon size={28} className="text-primary" aria-hidden={true} />
    </div>
    <h4 className="text-lg font-display font-black text-zinc-900 mb-2">{title}</h4>
    {description && <p className="text-zinc-600 text-sm max-w-xs mb-6">{description}</p>}
    {action}
  </div>
);

// ── SkeletonBlock ─────────────────────────────────────────────────────────────
export const SkeletonBlock = ({ className }: { className?: string }) => (
  <div className={cn('animate-pulse bg-primary-dim rounded-2xl', className)} aria-hidden="true" />
);

export const SkeletonCard = () => (
  <SisonkeCard>
    <div className="space-y-4">
      <SkeletonBlock className="h-5 w-32" />
      <SkeletonBlock className="h-10 w-24" />
    </div>
  </SisonkeCard>
);

// ── Accessible Confirmation Dialog ──────────────────────────────────────────
export interface ConfirmDialogProps {
  isOpen: boolean;
  title: string;
  description: string;
  confirmText?: string;
  cancelText?: string;
  isDestructive?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

export const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  isOpen,
  title,
  description,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  isDestructive = false,
  onConfirm,
  onCancel,
}) => {
  const dialogRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onCancel();
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onCancel]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-900/60 backdrop-blur-sm animate-in fade-in duration-200"
      role="alertdialog"
      aria-modal="true"
      aria-labelledby="confirm-dialog-title"
      aria-describedby="confirm-dialog-desc"
    >
      <div
        ref={dialogRef}
        className="w-full max-w-md p-8 bg-white rounded-3xl shadow-2xl border border-zinc-100 space-y-6"
      >
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className={cn(
              'p-3 rounded-2xl',
              isDestructive ? 'bg-rose-100 text-rose-600' : 'bg-primary-dim text-primary'
            )}>
              <AlertTriangle size={24} />
            </div>
            <h3 id="confirm-dialog-title" className="text-xl font-display font-black text-zinc-900">
              {title}
            </h3>
          </div>
          <button
            type="button"
            onClick={onCancel}
            aria-label="Close dialog"
            className="p-2 text-zinc-400 hover:text-zinc-700 rounded-xl hover:bg-zinc-100"
          >
            <X size={20} />
          </button>
        </div>

        <p id="confirm-dialog-desc" className="text-zinc-600 text-sm leading-relaxed">
          {description}
        </p>

        <div className="flex items-center justify-end gap-3 pt-2">
          <button
            type="button"
            onClick={onCancel}
            className="px-5 py-3 text-zinc-700 font-bold hover:bg-zinc-100 rounded-2xl transition-colors"
          >
            {cancelText}
          </button>
          <button
            type="button"
            onClick={onConfirm}
            className={cn(
              'px-6 py-3 text-white font-bold rounded-2xl shadow-lg transition-all',
              isDestructive
                ? 'bg-rose-600 hover:bg-rose-700 shadow-rose-600/20'
                : 'bg-primary hover:bg-primary-dark shadow-primary/20'
            )}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
};

// ── Accessible Error Boundary ────────────────────────────────────────────────
interface ErrorBoundaryProps {
  children: React.ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  override componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('ErrorBoundary caught error:', error, errorInfo);
  }

  override render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-[50vh] flex flex-col items-center justify-center p-8 text-center" role="alert">
          <div className="p-4 bg-rose-100 text-rose-700 rounded-3xl mb-4">
            <AlertTriangle size={36} />
          </div>
          <h2 className="text-2xl font-display font-black text-zinc-900 mb-2">
            Something unexpected occurred
          </h2>
          <p className="text-zinc-600 max-w-md mb-6 text-sm">
            {this.state.error?.message || 'The application encountered an error. Please try reloading.'}
          </p>
          <button
            type="button"
            onClick={() => window.location.reload()}
            className="px-6 py-3 bg-primary text-white font-bold rounded-2xl shadow-lg shadow-primary/20 hover:bg-primary-dark"
          >
            Reload Page
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
