import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

/** Fade + slide up entrance */
export const useFadeUp = (delay = 0, duration = 20) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({
    fps,
    frame: frame - delay,
    config: { damping: 14, stiffness: 80, mass: 0.8 },
    durationInFrames: duration,
  });
  return {
    opacity: interpolate(frame - delay, [0, 8], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),
    transform: `translateY(${interpolate(progress, [0, 1], [40, 0])}px)`,
  };
};

/** Scale pop entrance */
export const useScalePop = (delay = 0) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const scale = spring({
    fps,
    frame: frame - delay,
    config: { damping: 12, stiffness: 120, mass: 0.6 },
    durationInFrames: 20,
  });
  const opacity = interpolate(frame - delay, [0, 4], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return { opacity, transform: `scale(${scale})` };
};

/** Fade-in only */
export const useFadeIn = (delay = 0, duration = 15) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame - delay, [0, duration], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return { opacity };
};

/** Horizontal slide in from right */
export const useSlideInRight = (delay = 0) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({
    fps,
    frame: frame - delay,
    config: { damping: 16, stiffness: 90 },
    durationInFrames: 25,
  });
  const opacity = interpolate(frame - delay, [0, 8], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return {
    opacity,
    transform: `translateX(${interpolate(progress, [0, 1], [60, 0])}px)`,
  };
};

/** Continuous float animation */
export const useFloat = (amplitude = 8, periodFrames = 90) => {
  const frame = useCurrentFrame();
  const y = amplitude * Math.sin((frame / periodFrames) * Math.PI * 2);
  return { transform: `translateY(${y}px)` };
};

/** Pulsing glow */
export const usePulse = (minScale = 0.97, maxScale = 1.03, periodFrames = 60) => {
  const frame = useCurrentFrame();
  const s = minScale + (maxScale - minScale) * (0.5 + 0.5 * Math.sin((frame / periodFrames) * Math.PI * 2));
  return { transform: `scale(${s})` };
};
