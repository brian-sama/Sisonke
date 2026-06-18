import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
  Img,
  staticFile,
} from "remotion";
import { Colors, Fonts, FEATURES } from "./Brand";
import { useFadeUp, useScalePop, usePulse } from "./Animations";

// ─── Scene 1: Logo Reveal ─────────────────────────────────────────────────────
export const LogoReveal: React.FC<{ landscape?: boolean }> = ({ landscape }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoScale = spring({ fps, frame, config: { damping: 12, stiffness: 100, mass: 0.7 }, durationInFrames: 30 });
  const logoOpacity = interpolate(frame, [0, 10], [0, 1], { extrapolateRight: "clamp" });
  const textStyle = useFadeUp(20, 20);
  const tagStyle = useFadeUp(35, 20);
  const pulseStyle = usePulse(0.96, 1.04, 80);

  // Portrait: logoBox 200, text 110, tag 30
  // Landscape: logoBox 160, text 90, tag 28
  const logoBox  = landscape ? 160 : 200;
  const logoR    = landscape ? 40 : 50;
  const textSize = landscape ? 90 : 110;
  const tagSize  = landscape ? 28 : 32;
  const tagMax   = landscape ? 520 : 700;

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(160deg, ${Colors.primaryDark} 0%, ${Colors.primary} 60%, ${Colors.forest} 100%)`,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: landscape ? 28 : 36,
      }}
    >
      <div style={{ position: "absolute", top: "-20%", right: "-10%", width: "60%", aspectRatio: "1", borderRadius: "50%", background: "rgba(255,255,255,0.04)" }} />
      <div style={{ position: "absolute", bottom: "-15%", left: "-15%", width: "50%", aspectRatio: "1", borderRadius: "50%", background: "rgba(255,255,255,0.03)" }} />

      {/* Logo */}
      <div style={{ ...pulseStyle, opacity: logoOpacity, transform: `${pulseStyle.transform} scale(${logoScale})`, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ width: logoBox, height: logoBox, borderRadius: logoR, background: "rgba(255,255,255,0.95)", display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 24px 70px rgba(0,0,0,0.35), 0 0 0 4px rgba(255,255,255,0.15)", overflow: "hidden" }}>
          <Img src={staticFile("logo.png")} style={{ width: "80%", height: "80%", objectFit: "contain" }} />
        </div>
      </div>

      {/* App name */}
      <div style={textStyle}>
        <div style={{ fontFamily: Fonts.display, fontSize: textSize, fontWeight: 900, color: Colors.white, letterSpacing: "-0.02em", textAlign: "center", textShadow: "0 4px 24px rgba(0,0,0,0.25)" }}>
          Sisonke
        </div>
      </div>

      {/* Tagline */}
      <div style={tagStyle}>
        <div style={{ fontFamily: Fonts.body, fontSize: tagSize, fontWeight: 500, color: "rgba(255,255,255,0.85)", textAlign: "center", letterSpacing: "0.06em", textTransform: "uppercase", maxWidth: tagMax }}>
          Together · Pamwe · Ndawonye
        </div>
      </div>
    </AbsoluteFill>
  );
};

// ─── Scene 2: Headline ────────────────────────────────────────────────────────
export const HeadlineScene: React.FC<{ landscape?: boolean }> = ({ landscape }) => {
  const line1 = useFadeUp(0, 18);
  const line2 = useFadeUp(15, 18);
  const sub = useFadeUp(30, 18);
  const dot = useFadeUp(45, 15);

  // Portrait: 100px headline, 34px sub
  // Landscape: 80px headline, 26px sub
  const headSize = landscape ? 80 : 100;
  const subSize  = landscape ? 26 : 36;
  const subMax   = landscape ? 640 : 800;
  const dotSize  = landscape ? 16 : 20;

  return (
    <AbsoluteFill style={{ background: Colors.cream, alignItems: "center", justifyContent: "center", padding: landscape ? 80 : 60, flexDirection: "column", gap: 16 }}>
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: "40%", background: `linear-gradient(180deg, ${Colors.primaryDim} 0%, transparent 100%)` }} />

      <div style={{ position: "relative", textAlign: "center" }}>
        <div style={{ ...line1 }}>
          <span style={{ fontFamily: Fonts.display, fontSize: headSize, fontWeight: 900, color: Colors.charcoal, display: "block", lineHeight: 1.1 }}>
            Your mental health
          </span>
        </div>
        <div style={{ ...line2 }}>
          <span style={{ fontFamily: Fonts.display, fontSize: headSize, fontWeight: 900, color: Colors.primary, display: "block", lineHeight: 1.1 }}>
            matters.
          </span>
        </div>
      </div>

      <div style={{ ...sub, marginTop: 20 }}>
        <p style={{ fontFamily: Fonts.body, fontSize: subSize, color: "#6B7280", textAlign: "center", maxWidth: subMax, lineHeight: 1.65, margin: 0 }}>
          Free, private, and built for young Zimbabweans — in English, Shona & Ndebele.
        </p>
      </div>

      <div style={{ ...dot, display: "flex", gap: landscape ? 14 : 18, marginTop: 28 }}>
        {[Colors.primary, Colors.secondary, Colors.accent].map((c, i) => (
          <div key={i} style={{ width: dotSize, height: dotSize, borderRadius: "50%", background: c }} />
        ))}
      </div>
    </AbsoluteFill>
  );
};

// ─── Scene 3: eFriend Chat (legacy — only used in landscape flow) ─────────────
export const EFriendScene: React.FC<{ landscape?: boolean }> = ({ landscape }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneEnter = spring({ fps, frame, config: { damping: 14, stiffness: 80 }, durationInFrames: 30 });
  const labelStyle = useFadeUp(5);

  const chats = [
    { text: "I've been feeling really anxious lately...", isUser: true, delay: 20 },
    { text: "I hear you. Anxiety can feel overwhelming. Can you tell me more about when it started?", isUser: false, delay: 32 },
    { text: "It's been weeks. I can't sleep.", isUser: true, delay: 52 },
    { text: "That sounds exhausting. Let's try a quick breathing exercise together 🫁", isUser: false, delay: 64 },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(135deg, ${Colors.primaryDim} 0%, ${Colors.secondaryDim} 100%)`,
        alignItems: "center",
        justifyContent: landscape ? "space-around" : "center",
        flexDirection: landscape ? "row" : "column",
        gap: landscape ? 60 : 20,
        padding: landscape ? "40px 80px" : "20px 20px",
      }}
    >
      <div style={{ ...labelStyle, ...(landscape ? {} : { position: "absolute", top: 40 }), textAlign: landscape ? "left" : "center", maxWidth: landscape ? 400 : undefined }}>
        <div style={{ fontFamily: Fonts.display, fontSize: landscape ? 52 : 64, fontWeight: 900, color: Colors.charcoal, lineHeight: 1.1, marginBottom: 12 }}>
          Always here,<br />never judging.
        </div>
      </div>
    </AbsoluteFill>
  );
};

// ─── Scene 4: Mood + Community (legacy) ──────────────────────────────────────
export const MoodCommunityScene: React.FC<{ landscape?: boolean }> = ({ landscape }) => {
  return (
    <AbsoluteFill style={{ background: `linear-gradient(135deg, ${Colors.secondaryDim} 0%, #E4DDF6 100%)`, alignItems: "center", justifyContent: "center" }}>
      <div style={{ fontFamily: Fonts.display, fontSize: landscape ? 64 : 80, fontWeight: 900, color: Colors.charcoal }}>Track your journey.</div>
    </AbsoluteFill>
  );
};

// ─── Scene 5: Emergency & Resources (legacy) ─────────────────────────────────
export const EmergencyScene: React.FC<{ landscape?: boolean }> = ({ landscape }) => {
  return (
    <AbsoluteFill style={{ background: `linear-gradient(135deg, #FFF1F2 0%, ${Colors.primaryDim} 100%)`, alignItems: "center", justifyContent: "center" }}>
      <div style={{ fontFamily: Fonts.display, fontSize: landscape ? 64 : 80, fontWeight: 900, color: Colors.charcoal }}>Help is always a tap away.</div>
    </AbsoluteFill>
  );
};

// ─── Scene 6: Features Grid (used in landscape) ───────────────────────────────
export const FeaturesGrid: React.FC<{ landscape?: boolean }> = ({ landscape }) => {
  const frame = useCurrentFrame();
  const headerStyle = useFadeUp(0, 18);

  return (
    <AbsoluteFill
      style={{
        background: Colors.cream,
        padding: landscape ? "40px 60px" : "40px 36px",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 32,
      }}
    >
      <div style={{ ...headerStyle, textAlign: "center" }}>
        <div style={{ fontFamily: Fonts.display, fontSize: landscape ? 64 : 80, fontWeight: 900, color: Colors.charcoal }}>Everything you need</div>
        <div style={{ fontFamily: Fonts.body, fontSize: landscape ? 22 : 30, color: "#6B7280", marginTop: 8 }}>in one safe space</div>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: landscape ? "repeat(3, 1fr)" : "repeat(2, 1fr)", gap: landscape ? 20 : 16, width: "100%", maxWidth: landscape ? 900 : undefined }}>
        {FEATURES.map((f, i) => {
          const delay = 10 + i * 8;
          const opacity = interpolate(frame - delay, [0, 12], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          const ty = interpolate(frame - delay, [0, 14], [20, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

          return (
            <div key={i} style={{ opacity, transform: `translateY(${ty}px)`, background: "white", borderRadius: landscape ? 24 : 20, padding: landscape ? "24px 20px" : "18px 14px", boxShadow: `0 4px 24px ${f.color}15`, border: `1px solid ${f.bg}`, display: "flex", flexDirection: "column", gap: landscape ? 12 : 10 }}>
              <div style={{ width: landscape ? 56 : 48, height: landscape ? 56 : 48, borderRadius: landscape ? 16 : 12, background: f.bg, display: "flex", alignItems: "center", justifyContent: "center", fontSize: landscape ? 28 : 24 }}>{f.icon}</div>
              <div>
                <div style={{ fontFamily: Fonts.body, fontSize: landscape ? 18 : 22, fontWeight: 800, color: Colors.charcoal }}>{f.title}</div>
                <div style={{ fontFamily: Fonts.body, fontSize: landscape ? 14 : 17, color: "#9CA3AF", lineHeight: 1.45, marginTop: 4 }}>{f.subtitle}</div>
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// ─── Scene 7: CTA ─────────────────────────────────────────────────────────────
export const CTAScene: React.FC<{ landscape?: boolean }> = ({ landscape }) => {
  const pulseStyle = usePulse(0.97, 1.03, 70);
  const logoStyle = useScalePop(0);
  const headline = useFadeUp(10, 18);
  const sub = useFadeUp(22, 18);
  const btnStyle = useFadeUp(36, 18);
  const frame = useCurrentFrame();

  const storeOpacity = interpolate(frame - 50, [0, 15], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  // Portrait: bold, tall layout needs very large text
  // Landscape: standard large text
  const logoBox   = landscape ? 160  : 200;
  const logoR     = landscape ? 40   : 50;
  const headSize  = landscape ? 90   : 120;
  const subSize   = landscape ? 28   : 48;
  const subMax    = landscape ? 560  : 820;
  const btnPad    = landscape ? "18px 44px" : "24px 60px";
  const btnFont   = landscape ? 22   : 36;
  const btnIcon   = landscape ? 26   : 42;
  const urlFont   = landscape ? 16   : 26;
  const lineW     = landscape ? 70   : 100;
  const gap       = landscape ? 20   : 28;

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(160deg, ${Colors.primaryDark} 0%, ${Colors.primary} 55%, #4A9E8B 100%)`,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap,
      }}
    >
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 60%, rgba(255,255,255,0.07) 0%, transparent 70%)" }} />

      {/* Logo */}
      <div style={{ ...logoStyle }}>
        <div style={{ width: logoBox, height: logoBox, borderRadius: logoR, background: "rgba(255,255,255,0.95)", display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 24px 70px rgba(0,0,0,0.28)", overflow: "hidden" }}>
          <Img src={staticFile("logo.png")} style={{ width: "80%", height: "80%", objectFit: "contain" }} />
        </div>
      </div>

      {/* Headline */}
      <div style={{ ...headline, textAlign: "center" }}>
        <div style={{ fontFamily: Fonts.display, fontSize: headSize, fontWeight: 900, color: "white", letterSpacing: "-0.02em", lineHeight: 1.05 }}>
          Download Sisonke
        </div>
      </div>

      {/* Subtitle */}
      <div style={{ ...sub, textAlign: "center" }}>
        <div style={{ fontFamily: Fonts.body, fontSize: subSize, color: "rgba(255,255,255,0.85)", maxWidth: subMax, lineHeight: 1.55, textAlign: "center" }}>
          Free. Private. Always there.
          <br />
          <span style={{ opacity: 0.65 }}>For young Zimbabweans, by Zimbabweans.</span>
        </div>
      </div>

      {/* CTA button */}
      <div style={{ ...btnStyle, display: "flex", gap: 18, flexWrap: "wrap", justifyContent: "center" }}>
        <div style={{
          ...pulseStyle,
          background: "white",
          color: Colors.primaryDark,
          borderRadius: 20,
          padding: btnPad,
          fontFamily: Fonts.body,
          fontSize: btnFont,
          fontWeight: 800,
          display: "flex",
          alignItems: "center",
          gap: 14,
          boxShadow: "0 16px 48px rgba(0,0,0,0.22)",
        }}>
          <span style={{ fontSize: btnIcon }}>🤖</span> Get on Android
        </div>
      </div>

      {/* URL */}
      <div style={{ opacity: storeOpacity, display: "flex", gap: 14, alignItems: "center", justifyContent: "center", marginTop: 8 }}>
        <div style={{ height: 2, width: lineW, background: "rgba(255,255,255,0.25)" }} />
        <span style={{ fontFamily: Fonts.body, fontSize: urlFont, color: "rgba(255,255,255,0.55)", letterSpacing: "0.12em", textTransform: "uppercase" }}>
          sisonke.mmpzmne.co.zw
        </span>
        <div style={{ height: 2, width: lineW, background: "rgba(255,255,255,0.25)" }} />
      </div>
    </AbsoluteFill>
  );
};
