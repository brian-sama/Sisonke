/**
 * Portrait ad — 1080×1920, 30s @ 30fps (900 frames)
 * Format: Instagram / TikTok / WhatsApp Story (9:16)
 *
 * Sizing guide for 1080-wide canvas:
 *  - Main headlines : 96–120 px
 *  - Sub-headlines  : 40–56 px
 *  - Body           : 32–40 px
 *  - Phone width    : ~520 px  → PHONE_SCALE 1.86
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

// Phone fills most of the lower half of the 1080-wide canvas
const PHONE_SCALE = 1.86;

const SceneWrapper: React.FC<{ children: React.ReactNode; durationInFrames: number }> = ({
  children,
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

const PhoneFeatureScene: React.FC<{
  label: string;
  icon: string;
  headline: string;
  accentColor: string;
  bgGradient: string;
  Screen: React.FC<{ s: number }>;
}> = ({ label, icon, headline, accentColor, bgGradient, Screen }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneEnter = spring({ fps, frame, config: { damping: 14, stiffness: 75 }, durationInFrames: 35 });
  const phoneOpacity = interpolate(phoneEnter, [0, 1], [0, 1]);
  const phoneY = interpolate(phoneEnter, [0, 1], [120, 0]);

  const labelStyle = useFadeUp(6, 20);
  const headStyle = useFadeUp(18, 22);

  return (
    <AbsoluteFill style={{ background: bgGradient, flexDirection: "column", alignItems: "center" }}>
      {/* ── Header text (top ~35% of canvas) ── */}
      <div
        style={{
          width: "100%",
          paddingTop: 100,
          paddingLeft: 64,
          paddingRight: 64,
          textAlign: "center",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 20,
        }}
      >
        {/* Feature chip */}
        <div style={{ ...labelStyle, display: "flex", alignItems: "center", gap: 14 }}>
          <span style={{ fontSize: 56 }}>{icon}</span>
          <span
            style={{
              fontFamily: Fonts.body,
              fontSize: 28,
              fontWeight: 800,
              textTransform: "uppercase",
              letterSpacing: "0.12em",
              color: accentColor,
              background: `${accentColor}18`,
              padding: "8px 22px",
              borderRadius: 40,
            }}
          >
            {label}
          </span>
        </div>

        {/* Headline */}
        <div style={headStyle}>
          <div
            style={{
              fontFamily: Fonts.display,
              fontSize: 96,
              fontWeight: 900,
              color: Colors.charcoal,
              lineHeight: 1.05,
              letterSpacing: "-0.02em",
              whiteSpace: "pre-line",
            }}
          >
            {headline}
          </div>
        </div>
      </div>

      {/* ── Phone (fills lower ~65%) ── */}
      <div
        style={{
          flex: 1,
          display: "flex",
          alignItems: "flex-start",
          justifyContent: "center",
          paddingTop: 40,
          opacity: phoneOpacity,
          transform: `translateY(${phoneY}px)`,
        }}
      >
        <PhoneMockup scale={PHONE_SCALE} enterProgress={1}>
          <Screen s={PHONE_SCALE} />
        </PhoneMockup>
      </div>
    </AbsoluteFill>
  );
};

export const SisonkePortrait: React.FC = () => (
  <Series>
    {/* 1 · Logo reveal — 2 s */}
    <Series.Sequence durationInFrames={60}>
      <SceneWrapper durationInFrames={60}>
        <LogoReveal />
      </SceneWrapper>
    </Series.Sequence>

    {/* 2 · Headline — 2.5 s */}
    <Series.Sequence durationInFrames={75}>
      <SceneWrapper durationInFrames={75}>
        <HeadlineScene />
      </SceneWrapper>
    </Series.Sequence>

    {/* 3 · eFriend chat — 4 s */}
    <Series.Sequence durationInFrames={120}>
      <SceneWrapper durationInFrames={120}>
        <PhoneFeatureScene
          label="eFriend AI"
          icon="💬"
          headline={"Always here,\nnever judging."}
          accentColor={Colors.primary}
          bgGradient={`linear-gradient(180deg, ${Colors.primaryDim} 0%, ${Colors.cream} 100%)`}
          Screen={EFriendScreen}
        />
      </SceneWrapper>
    </Series.Sequence>

    {/* 4 · Mood check-in — 3.5 s */}
    <Series.Sequence durationInFrames={105}>
      <SceneWrapper durationInFrames={105}>
        <PhoneFeatureScene
          label="Daily Check-in"
          icon="😊"
          headline={"Track your\njourney."}
          accentColor={Colors.secondary}
          bgGradient={`linear-gradient(180deg, ${Colors.secondaryDim} 0%, ${Colors.cream} 100%)`}
          Screen={MoodCheckinScreen}
        />
      </SceneWrapper>
    </Series.Sequence>

    {/* 5 · Breathing — 4 s */}
    <Series.Sequence durationInFrames={120}>
      <SceneWrapper durationInFrames={120}>
        <PhoneFeatureScene
          label="Breathing Tools"
          icon="🫁"
          headline={"Calm in\n2 minutes."}
          accentColor={Colors.forest}
          bgGradient={`linear-gradient(180deg, ${Colors.mint} 0%, ${Colors.cream} 100%)`}
          Screen={BreathingScreen}
        />
      </SceneWrapper>
    </Series.Sequence>

    {/* 6 · Community — 3 s */}
    <Series.Sequence durationInFrames={90}>
      <SceneWrapper durationInFrames={90}>
        <PhoneFeatureScene
          label="Community"
          icon="🤝"
          headline={"You're not\nalone."}
          accentColor="#D97706"
          bgGradient={`linear-gradient(180deg, #FEF3C7 0%, ${Colors.cream} 100%)`}
          Screen={CommunityScreen}
        />
      </SceneWrapper>
    </Series.Sequence>

    {/* 7 · Resources — 3 s */}
    <Series.Sequence durationInFrames={90}>
      <SceneWrapper durationInFrames={90}>
        <PhoneFeatureScene
          label="Resources"
          icon="📚"
          headline={"Know more,\nfear less."}
          accentColor={Colors.primary}
          bgGradient={`linear-gradient(180deg, ${Colors.primaryDim} 0%, ${Colors.cream} 100%)`}
          Screen={ResourcesScreen}
        />
      </SceneWrapper>
    </Series.Sequence>

    {/* 8 · CTA — 8 s */}
    <Series.Sequence durationInFrames={240}>
      <CTAScene />
    </Series.Sequence>
  </Series>
);
