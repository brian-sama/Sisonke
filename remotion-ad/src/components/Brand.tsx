// Sisonke brand tokens — keep in sync with sisonke_colors.dart
export const Colors = {
  primary: "#2E6F60",
  primaryDim: "#E8F2EF",
  primaryMid: "#D0E8E3",
  primaryDark: "#1A3D36",
  secondary: "#7361A9",
  secondaryDim: "#F0EDF8",
  accent: "#D68A7F",
  cream: "#FFFBF2",
  muted: "#F5F0E8",
  charcoal: "#2F3433",
  success: "#10B981",
  warning: "#F59E0B",
  danger: "#F43F5E",
  sage: "#CFE6D2",
  mint: "#DDF3EA",
  sky: "#D8EEF8",
  blush: "#EBCBD0",
  lavender: "#E4DDF6",
  forest: "#315F46",
  clay: "#E8B9A2",
  white: "#FFFFFF",
};

export const Fonts = {
  display: `"Playfair Display", Georgia, serif`,
  body: `"Inter", system-ui, -apple-system, sans-serif`,
};

export type Feature = {
  icon: string;
  title: string;
  subtitle: string;
  color: string;
  bg: string;
};

export const FEATURES: Feature[] = [
  {
    icon: "💬",
    title: "eFriend AI",
    subtitle: "24/7 mental health support in your language",
    color: Colors.primary,
    bg: Colors.primaryDim,
  },
  {
    icon: "😊",
    title: "Daily Check-in",
    subtitle: "Track your mood & journal privately",
    color: Colors.secondary,
    bg: Colors.secondaryDim,
  },
  {
    icon: "🫁",
    title: "Breathing Tools",
    subtitle: "Calm your mind with guided exercises",
    color: Colors.forest,
    bg: Colors.mint,
  },
  {
    icon: "🤝",
    title: "Safe Community",
    subtitle: "Connect with peers who understand",
    color: "#D97706",
    bg: "#FEF3C7",
  },
  {
    icon: "📞",
    title: "Crisis Helplines",
    subtitle: "Zimbabwe's support network, always available",
    color: Colors.danger,
    bg: "#FFF1F2",
  },
  {
    icon: "📚",
    title: "Resource Library",
    subtitle: "SRHR & mental health guides, offline",
    color: Colors.primary,
    bg: Colors.primaryDim,
  },
];
