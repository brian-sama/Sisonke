/**
 * Landscape ad — 1920×1080, 60s @ 30fps (1800 frames)
 * Format: YouTube / Web (16:9)
 *
 * Sizing guide for 1920-wide canvas:
 *  - Main headlines : 80–96 px
 *  - Sub-headlines  : 26–36 px
 *  - Body           : 22–28 px
 *  - Phone height   : ~950 px  → PHONE_SCALE 1.64 (280×1.64=459px wide, 580×1.64=951px tall)
 */
import React from "react";
import {
  AbsoluteFill,
  interpolate,
  Series,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Colors, Fonts } from "./components/Brand";
import { useFadeUp } from "./components/Animations";
import { PhoneMockup } from "./components/PhoneMockup";
import { LogoReveal, HeadlineScene, CTAScene } from "./components/Scenes";
import {
  EFriendScreen,
  MoodCheckinScreen,
  BreathingScreen,
  CommunityScreen,
  ResourcesScreen,
} from "./components/AppScreens";

// Phone fills the full height of the 1080px canvas inside its column
const PHONE_SCALE = 1.64;

const SceneWrapper: React.FC<{ children: React.ReactNode; durationInFrames: number }> = ({ children, durationInFrames }) => {
  const frame = useCurrentFrame();
  const fadeOut = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  return <AbsoluteFill style={{ opacity: fadeOut }}>{children}</AbsoluteFill>;
};

// Two-column layout: text left, phone right (or reversed)
const LandscapeFeature: React.FC<{
  label: string;
  icon: string;
  headline: string;
  body: string;
  accentColor: string;
  bg: string;
  Screen: React.FC<{ s: number }>;
  reverse?: boolean;
}> = ({ label, icon, headline, body, accentColor, bg, Screen, reverse }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneEnter = spring({ fps, frame, config: { damping: 14, stiffness: 75 }, durationInFrames: 35 });
  const opacity = interpolate(phoneEnter, [0, 1], [0, 1]);
  const translateX = interpolate(phoneEnter, [0, 1], [reverse ? -100 : 100, 0]);
  const labelStyle = useFadeUp(8, 20);
  const headStyle = useFadeUp(18, 20);
  const bodyStyle = useFadeUp(30, 20);
  const chipStyle = useFadeUp(44, 16);

  const textSection = (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "center", padding: "48px 72px" }}>
      {/* Feature chip */}
      <div style={{ ...labelStyle, display: "flex", alignItems: "center", gap: 16, marginBottom: 24 }}>
        <div style={{ width: 64, height: 64, borderRadius: 18, background: `${accentColor}18`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 32 }}>{icon}</div>
        <span style={{ fontFamily: Fonts.body, fontSize: 18, fontWeight: 700, textTransform: "uppercase" as const, letterSpacing: "0.12em", color: accentColor }}>{label}</span>
      </div>

      {/* Headline */}
      <div style={headStyle}>
        <div style={{ fontFamily: Fonts.display, fontSize: 80, fontWeight: 900, color: Colors.charcoal, lineHeight: 1.06, letterSpacing: "-0.02em", marginBottom: 24, whiteSpace: "pre-line" }}>{headline}</div>
      </div>

      {/* Body text */}
      <div style={bodyStyle}>
        <p style={{ fontFamily: Fonts.body, fontSize: 26, color: "#6B7280", lineHeight: 1.7, margin: 0, maxWidth: 580 }}>{body}</p>
      </div>

      {/* Chips */}
      <div style={{ ...chipStyle, display: "flex", gap: 14, marginTop: 40, flexWrap: "wrap" as const }}>
        <div style={{ background: accentColor, color: "white", borderRadius: 28, padding: "14px 32px", fontSize: 20, fontFamily: Fonts.body, fontWeight: 700, boxShadow: `0 10px 28px ${accentColor}44` }}>
          Free to use
        </div>
        <div style={{ background: "white", color: Colors.charcoal, borderRadius: 28, padding: "14px 32px", fontSize: 20, fontFamily: Fonts.body, fontWeight: 600, border: `2px solid ${Colors.muted}` }}>
          100% Private
        </div>
      </div>
    </div>
  );

  const phoneSection = (
    <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", opacity, transform: `translateX(${translateX}px)` }}>
      <PhoneMockup scale={PHONE_SCALE} enterProgress={1}>
        <Screen s={PHONE_SCALE} />
      </PhoneMockup>
    </div>
  );

  return (
    <AbsoluteFill style={{ background: bg, flexDirection: "row" }}>
      {reverse ? <>{phoneSection}{textSection}</> : <>{textSection}{phoneSection}</>}
    </AbsoluteFill>
  );
};

// Stats / Social proof scene
const StatsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const stats = [
    { value: "24/7", label: "AI Support", icon: "💬", color: Colors.primary },
    { value: "100%", label: "Free & Private", icon: "🔒", color: Colors.secondary },
    { value: "3+", label: "Languages", icon: "🌍", color: Colors.forest },
    { value: "0", label: "Judgment", icon: "💚", color: "#D97706" },
  ];

  return (
    <AbsoluteFill style={{ background: Colors.cream, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 56, padding: "48px 80px" }}>
      <div style={{ textAlign: "center" }}>
        <div style={{ fontFamily: Fonts.display, fontSize: 80, fontWeight: 900, color: Colors.charcoal, lineHeight: 1.05 }}>Built for Zimbabwe's youth.</div>
        <div style={{ fontFamily: Fonts.body, fontSize: 28, color: "#6B7280", marginTop: 16 }}>In English, Shona & Ndebele.</div>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 28, width: "100%" }}>
        {stats.map((s, i) => {
          const delay = 12 + i * 10;
          const opacity = interpolate(frame - delay, [0, 14], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          const scale = interpolate(frame - delay, [0, 16], [0.85, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          return (
            <div key={i} style={{ opacity, transform: `scale(${scale})`, background: "white", borderRadius: 32, padding: "44px 32px", textAlign: "center", boxShadow: `0 10px 40px ${s.color}1A`, border: `1.5px solid ${s.color}22` }}>
              <div style={{ fontSize: 48, marginBottom: 14 }}>{s.icon}</div>
              <div style={{ fontFamily: Fonts.display, fontSize: 64, fontWeight: 900, color: s.color, lineHeight: 1 }}>{s.value}</div>
              <div style={{ fontFamily: Fonts.body, fontSize: 18, color: "#9CA3AF", fontWeight: 600, marginTop: 10, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>{s.label}</div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

export const SisonkeLandscape: React.FC = () => {
  return (
    <Series>
      {/* 1. Logo — 75f (2.5s) */}
      <Series.Sequence durationInFrames={75}>
        <SceneWrapper durationInFrames={75}><LogoReveal landscape /></SceneWrapper>
      </Series.Sequence>

      {/* 2. Headline — 90f (3s) */}
      <Series.Sequence durationInFrames={90}>
        <SceneWrapper durationInFrames={90}><HeadlineScene landscape /></SceneWrapper>
      </Series.Sequence>

      {/* 3. eFriend — 180f (6s) */}
      <Series.Sequence durationInFrames={180}>
        <SceneWrapper durationInFrames={180}>
          <LandscapeFeature
            label="eFriend AI Chat"
            icon="💬"
            headline={"Always here,\nnever judging."}
            body="24/7 mental health support powered by AI, with trained human counselors always on standby. Responds in English, Shona, and Ndebele."
            accentColor={Colors.primary}
            bg={Colors.cream}
            Screen={EFriendScreen}
          />
        </SceneWrapper>
      </Series.Sequence>

      {/* 4. Mood check-in — 150f (5s) */}
      <Series.Sequence durationInFrames={150}>
        <SceneWrapper durationInFrames={150}>
          <LandscapeFeature
            label="Daily Check-in & Journal"
            icon="😊"
            headline={"Track your\njourney privately."}
            body="Log your mood, energy level, and thoughts every day. Your journal is fully encrypted — only you can read it."
            accentColor={Colors.secondary}
            bg={`linear-gradient(135deg, ${Colors.secondaryDim}, ${Colors.cream})`}
            Screen={MoodCheckinScreen}
            reverse
          />
        </SceneWrapper>
      </Series.Sequence>

      {/* 5. Breathing — 150f (5s) */}
      <Series.Sequence durationInFrames={150}>
        <SceneWrapper durationInFrames={150}>
          <LandscapeFeature
            label="Emergency Toolkit"
            icon="🫁"
            headline={"Calm your mind\nin 2 minutes."}
            body="Box breathing, 4-7-8 technique, and grounding exercises — all available offline, anytime you need them."
            accentColor={Colors.forest}
            bg={`linear-gradient(135deg, ${Colors.mint}, ${Colors.primaryDim})`}
            Screen={BreathingScreen}
          />
        </SceneWrapper>
      </Series.Sequence>

      {/* 6. Community — 150f (5s) */}
      <Series.Sequence durationInFrames={150}>
        <SceneWrapper durationInFrames={150}>
          <LandscapeFeature
            label="Safe Community"
            icon="🤝"
            headline={"You're not\nalone."}
            body="Connect anonymously with peers who understand. All posts are moderated by trained safety reviewers before they appear."
            accentColor="#D97706"
            bg={`linear-gradient(135deg, #FEF3C7, ${Colors.cream})`}
            Screen={CommunityScreen}
            reverse
          />
        </SceneWrapper>
      </Series.Sequence>

      {/* 7. Resources — 135f (4.5s) */}
      <Series.Sequence durationInFrames={135}>
        <SceneWrapper durationInFrames={135}>
          <LandscapeFeature
            label="Resource Library"
            icon="📚"
            headline={"Know more,\nfear less."}
            body="Mental health, SRHR, and wellness guides — available offline. Written in plain language for young Zimbabweans."
            accentColor={Colors.primary}
            bg={Colors.cream}
            Screen={ResourcesScreen}
          />
        </SceneWrapper>
      </Series.Sequence>

      {/* 8. Stats / social proof — 120f (4s) */}
      <Series.Sequence durationInFrames={120}>
        <SceneWrapper durationInFrames={120}>
          <StatsScene />
        </SceneWrapper>
      </Series.Sequence>

      {/* 9. CTA — 750f (25s) — longer for YouTube */}
      <Series.Sequence durationInFrames={750}>
        <CTAScene landscape />
      </Series.Sequence>
    </Series>
  );
};
