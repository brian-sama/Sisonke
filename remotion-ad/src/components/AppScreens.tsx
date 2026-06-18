/**
 * Pixel-accurate recreations of the actual Sisonke Flutter screens.
 * Layout/colors/content pulled directly from the Flutter source:
 *   - efriend_screen.dart (eFriend AI chat)
 *   - mood_checkin_screen.dart (Daily check-in)
 *   - emergency_toolkit_screen.dart + breathing_exercise_screen.dart
 *   - community_feed_screen.dart
 *   - resources_screen.dart
 */
import React from "react";
import { interpolate, useCurrentFrame } from "remotion";
import { Colors, Fonts } from "./Brand";

// ── Shared micro-components ────────────────────────────────────────────────────
const AppBar: React.FC<{ title: string; subtitle?: string; icon?: string; bg?: string; s: number }> = ({ title, subtitle, icon, bg, s }) => (
  <div style={{ background: bg ?? Colors.primary, padding: `${10 * s}px ${14 * s}px`, display: "flex", alignItems: "center", gap: 10 * s }}>
    {icon && (
      <div style={{ width: 32 * s, height: 32 * s, borderRadius: 16 * s, background: "rgba(255,255,255,0.25)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16 * s }}>
        {icon}
      </div>
    )}
    <div>
      <div style={{ fontFamily: "system-ui", fontSize: 13 * s, fontWeight: 700, color: "white" }}>{title}</div>
      {subtitle && <div style={{ fontFamily: "system-ui", fontSize: 9 * s, color: "rgba(255,255,255,0.7)" }}>{subtitle}</div>}
    </div>
  </div>
);

const StatusBar: React.FC<{ s: number }> = ({ s }) => (
  <div style={{ background: Colors.primaryDark, padding: `${4 * s}px ${14 * s}px`, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
    <span style={{ color: "white", fontSize: 9 * s, fontFamily: "system-ui", fontWeight: 600 }}>9:41</span>
    <div style={{ display: "flex", gap: 4 * s }}>
      <span style={{ color: "white", fontSize: 9 * s }}>●●●</span>
      <span style={{ color: "white", fontSize: 9 * s }}>100%</span>
    </div>
  </div>
);

// ── eFriend Chat Screen (matches efriend_screen.dart) ────────────────────────
export const EFriendScreen: React.FC<{ s: number }> = ({ s }) => {
  const frame = useCurrentFrame();

  const msgs = [
    { user: false, text: "Sawubona! I'm eFriend 💚\nHow are you feeling today?", delay: 0 },
    { user: true, text: "I've been really anxious. I can't sleep.", delay: 18 },
    { user: false, text: "I'm sorry to hear that. Anxiety can feel overwhelming, especially at night.\n\nCan you tell me more about what's been on your mind?", delay: 32 },
    { user: true, text: "Exams and family stress mostly.", delay: 52 },
    { user: false, text: "That's a lot to carry. Let's try a quick breathing exercise together 🫁\n\nIt takes only 2 minutes and really helps.", delay: 66 },
  ];

  return (
    <div style={{ background: Colors.cream, height: "100%", display: "flex", flexDirection: "column" }}>
      <StatusBar s={s} />
      <AppBar title="eFriend" subtitle="AI Support · Always available" icon="💚" s={s} />

      {/* Chat area */}
      <div style={{ flex: 1, padding: `${10 * s}px ${8 * s}px`, display: "flex", flexDirection: "column", justifyContent: "flex-end", gap: 6 * s, overflow: "hidden" }}>
        {msgs.map((m, i) => {
          const opacity = interpolate(frame - m.delay, [0, 10], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          const ty = interpolate(frame - m.delay, [0, 12], [8, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          return (
            <div key={i} style={{ opacity, transform: `translateY(${ty}px)`, display: "flex", justifyContent: m.user ? "flex-end" : "flex-start", gap: 5 * s }}>
              {!m.user && (
                <div style={{ width: 26 * s, height: 26 * s, borderRadius: 13 * s, background: Colors.primary, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13 * s, flexShrink: 0, alignSelf: "flex-end" }}>💚</div>
              )}
              <div style={{
                background: m.user ? Colors.primary : "white",
                color: m.user ? "white" : Colors.charcoal,
                borderRadius: m.user ? `${10 * s}px ${10 * s}px 2px ${10 * s}px` : `${10 * s}px ${10 * s}px ${10 * s}px 2px`,
                padding: `${6 * s}px ${9 * s}px`,
                fontSize: 8.5 * s,
                fontFamily: "system-ui",
                maxWidth: "72%",
                lineHeight: 1.45,
                boxShadow: "0 2px 8px rgba(0,0,0,0.07)",
                whiteSpace: "pre-line",
              }}>
                {m.text}
              </div>
            </div>
          );
        })}
      </div>

      {/* Input bar */}
      <div style={{ background: "white", borderTop: `1px solid ${Colors.primaryDim}`, padding: `${8 * s}px ${10 * s}px`, display: "flex", gap: 6 * s, alignItems: "center" }}>
        <div style={{ flex: 1, background: Colors.muted, borderRadius: 20 * s, padding: `${6 * s}px ${10 * s}px`, fontSize: 8 * s, color: "#9CA3AF", fontFamily: "system-ui" }}>
          Share how you're feeling...
        </div>
        <div style={{ width: 28 * s, height: 28 * s, borderRadius: 14 * s, background: Colors.primary, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13 * s }}>➤</div>
      </div>
    </div>
  );
};

// ── Mood Check-in Screen (matches mood_checkin_screen.dart) ──────────────────
export const MoodCheckinScreen: React.FC<{ s: number }> = ({ s }) => {
  const frame = useCurrentFrame();
  const moods = [
    { emoji: "😭", label: "Low", color: "#EF4444" },
    { emoji: "😔", label: "Sad", color: "#F97316" },
    { emoji: "😐", label: "Okay", color: Colors.warning },
    { emoji: "🙂", label: "Good", color: "#84CC16" },
    { emoji: "😄", label: "Great", color: Colors.success },
  ];
  const selected = 3;
  const energyLevel = 7;

  const headerOp = interpolate(frame, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  const cardOp = interpolate(frame - 8, [0, 14], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  return (
    <div style={{ background: Colors.cream, height: "100%", display: "flex", flexDirection: "column" }}>
      <StatusBar s={s} />
      <AppBar title="Daily Check-in" subtitle="How are you today?" icon="😊" s={s} />

      <div style={{ flex: 1, padding: `${12 * s}px ${10 * s}px`, display: "flex", flexDirection: "column", gap: 10 * s, overflow: "hidden" }}>
        {/* Date */}
        <div style={{ opacity: headerOp }}>
          <div style={{ fontFamily: "system-ui", fontSize: 10 * s, color: "#9CA3AF", fontWeight: 600 }}>WEDNESDAY, 18 JUNE</div>
        </div>

        {/* Mood picker card */}
        <div style={{ opacity: cardOp, background: "white", borderRadius: 16 * s, padding: 14 * s, boxShadow: "0 4px 16px rgba(0,0,0,0.07)" }}>
          <div style={{ fontFamily: "system-ui", fontSize: 10 * s, fontWeight: 700, color: Colors.charcoal, marginBottom: 12 * s }}>How are you feeling?</div>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            {moods.map((m, i) => (
              <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 5 * s }}>
                <div style={{
                  width: 42 * s, height: 42 * s, borderRadius: 21 * s,
                  background: i === selected ? m.color : Colors.muted,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 20 * s,
                  boxShadow: i === selected ? `0 6px 16px ${m.color}44` : "none",
                  transform: i === selected ? "scale(1.12)" : "scale(1)",
                  transition: "all 0.3s",
                }}>
                  {m.emoji}
                </div>
                <span style={{ fontSize: 7 * s, fontFamily: "system-ui", fontWeight: i === selected ? 700 : 400, color: i === selected ? m.color : "#9CA3AF" }}>{m.label}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Energy slider */}
        <div style={{ opacity: cardOp, background: "white", borderRadius: 16 * s, padding: 14 * s, boxShadow: "0 4px 16px rgba(0,0,0,0.07)" }}>
          <div style={{ fontFamily: "system-ui", fontSize: 10 * s, fontWeight: 700, color: Colors.charcoal, marginBottom: 8 * s }}>Energy level</div>
          <div style={{ display: "flex", alignItems: "center", gap: 8 * s }}>
            <span style={{ fontSize: 14 * s }}>⚡</span>
            <div style={{ flex: 1, height: 6 * s, background: Colors.muted, borderRadius: 3 * s, position: "relative" }}>
              <div style={{ width: `${energyLevel * 10}%`, height: "100%", background: `linear-gradient(90deg, ${Colors.primary}, ${Colors.secondary})`, borderRadius: 3 * s }} />
              <div style={{ position: "absolute", left: `${energyLevel * 10}%`, top: "50%", transform: "translate(-50%, -50%)", width: 12 * s, height: 12 * s, borderRadius: 6 * s, background: Colors.primary, border: `2px solid white`, boxShadow: "0 2px 8px rgba(0,0,0,0.2)" }} />
            </div>
            <span style={{ fontFamily: "system-ui", fontSize: 11 * s, fontWeight: 700, color: Colors.primary }}>{energyLevel}/10</span>
          </div>
        </div>

        {/* Journal teaser */}
        <div style={{ opacity: cardOp, background: `linear-gradient(135deg, ${Colors.secondaryDim}, ${Colors.primaryDim})`, borderRadius: 14 * s, padding: `${10 * s}px ${12 * s}px`, display: "flex", alignItems: "center", gap: 8 * s, border: `1px solid ${Colors.primaryMid ?? "#D0E8E3"}` }}>
          <span style={{ fontSize: 18 * s }}>📓</span>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: "system-ui", fontSize: 9 * s, fontWeight: 700, color: Colors.charcoal }}>Write in your journal</div>
            <div style={{ fontFamily: "system-ui", fontSize: 8 * s, color: "#6B7280" }}>Private & encrypted</div>
          </div>
          <div style={{ fontSize: 14 * s, color: Colors.primary }}>›</div>
        </div>

        {/* Save button */}
        <div style={{ background: Colors.primary, borderRadius: 14 * s, padding: `${10 * s}px`, textAlign: "center", marginTop: "auto" }}>
          <span style={{ fontFamily: "system-ui", fontSize: 10 * s, fontWeight: 700, color: "white" }}>Save check-in</span>
        </div>
      </div>
    </div>
  );
};

// ── Breathing Exercise Screen (matches breathing_exercise_screen.dart) ─────────
export const BreathingScreen: React.FC<{ s: number }> = ({ s }) => {
  const frame = useCurrentFrame();
  // Box breathing: 4s inhale, 4s hold, 4s exhale, 4s hold → 16s cycle @ 30fps = 480 frames
  const cycleFrames = 120; // 4-second cycle phase at 30fps
  const phase = Math.floor((frame % (cycleFrames * 4)) / cycleFrames);
  const phaseProgress = ((frame % (cycleFrames * 4)) % cycleFrames) / cycleFrames;

  const phaseLabels = ["Breathe In", "Hold", "Breathe Out", "Hold"];
  const phaseColors = [Colors.primary, Colors.secondary, Colors.forest, Colors.secondary];
  const circleScale = phase === 0 ? 0.7 + 0.3 * phaseProgress
    : phase === 1 ? 1.0
    : phase === 2 ? 1.0 - 0.3 * phaseProgress
    : 0.7;
  const headerOp = interpolate(frame, [0, 12], [0, 1], { extrapolateRight: "clamp" });

  return (
    <div style={{ background: Colors.primaryDark, height: "100%", display: "flex", flexDirection: "column" }}>
      <div style={{ background: "rgba(0,0,0,0.3)", padding: `${4 * s}px ${14 * s}px`, display: "flex", justifyContent: "space-between" }}>
        <span style={{ color: "white", fontSize: 9 * s, fontFamily: "system-ui", fontWeight: 600 }}>9:41</span>
        <span style={{ color: "white", fontSize: 9 * s }}>100%</span>
      </div>
      <div style={{ background: "rgba(0,0,0,0.2)", padding: `${10 * s}px ${14 * s}px`, display: "flex", alignItems: "center", gap: 8 * s }}>
        <div style={{ fontSize: 9 * s, color: "rgba(255,255,255,0.6)", fontFamily: "system-ui" }}>‹</div>
        <div style={{ fontFamily: "system-ui", fontSize: 13 * s, fontWeight: 700, color: "white" }}>Box Breathing</div>
      </div>

      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 16 * s, padding: 16 * s }}>
        {/* Breathing circle */}
        <div style={{ opacity: headerOp, position: "relative", display: "flex", alignItems: "center", justifyContent: "center", width: 140 * s, height: 140 * s }}>
          {/* Outer ring */}
          <div style={{ position: "absolute", width: 140 * s, height: 140 * s, borderRadius: "50%", border: `2px solid rgba(255,255,255,0.15)` }} />
          {/* Animated circle */}
          <div style={{
            width: 90 * s * circleScale,
            height: 90 * s * circleScale,
            borderRadius: "50%",
            background: `radial-gradient(circle, ${phaseColors[phase]}cc, ${phaseColors[phase]}44)`,
            boxShadow: `0 0 ${30 * circleScale * s}px ${phaseColors[phase]}66`,
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <div style={{ fontFamily: "system-ui", fontSize: 9 * s, fontWeight: 700, color: "white", textAlign: "center", lineHeight: 1.3 }}>
              {phaseLabels[phase]}<br />
              <span style={{ fontSize: 7 * s, opacity: 0.75 }}>4 seconds</span>
            </div>
          </div>
        </div>

        {/* Phase indicators */}
        <div style={{ display: "flex", gap: 8 * s }}>
          {phaseLabels.map((p, i) => (
            <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4 * s }}>
              <div style={{ width: 8 * s, height: 8 * s, borderRadius: "50%", background: i === phase ? phaseColors[i] : "rgba(255,255,255,0.2)" }} />
              <span style={{ fontSize: 7 * s, color: i === phase ? "white" : "rgba(255,255,255,0.4)", fontFamily: "system-ui", fontWeight: i === phase ? 700 : 400 }}>{p}</span>
            </div>
          ))}
        </div>

        {/* Technique info */}
        <div style={{ background: "rgba(255,255,255,0.08)", borderRadius: 12 * s, padding: `${8 * s}px ${12 * s}px`, textAlign: "center" }}>
          <div style={{ fontFamily: "system-ui", fontSize: 9 * s, fontWeight: 700, color: "white" }}>Box Breathing · 4-4-4-4</div>
          <div style={{ fontFamily: "system-ui", fontSize: 8 * s, color: "rgba(255,255,255,0.6)", marginTop: 2 * s }}>Reduces anxiety & stress</div>
        </div>
      </div>
    </div>
  );
};

// ── Community Feed Screen (matches community_feed_screen.dart) ────────────────
export const CommunityScreen: React.FC<{ s: number }> = ({ s }) => {
  const frame = useCurrentFrame();
  const posts = [
    { age: "18–24", content: "Exams are overwhelming but I've been using the breathing exercises and they actually help 💚", likes: 12, time: "2m ago" },
    { age: "16–18", content: "Reminder to drink water and eat something today. You're doing great 🌿", likes: 28, time: "15m ago" },
    { age: "25–30", content: "The eFriend AI helped me find the right words to talk to my mum. Thank you Sisonke team 🙏", likes: 47, time: "1h ago" },
  ];

  return (
    <div style={{ background: Colors.cream, height: "100%", display: "flex", flexDirection: "column" }}>
      <StatusBar s={s} />
      <AppBar title="Community" subtitle="Safe · Anonymous · Supportive" icon="🤝" s={s} />

      <div style={{ flex: 1, padding: `${10 * s}px ${8 * s}px`, display: "flex", flexDirection: "column", gap: 8 * s, overflow: "hidden" }}>
        {posts.map((p, i) => {
          const delay = i * 14;
          const opacity = interpolate(frame - delay, [0, 12], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          const ty = interpolate(frame - delay, [0, 14], [14, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          return (
            <div key={i} style={{ opacity, transform: `translateY(${ty}px)`, background: "white", borderRadius: 14 * s, padding: 12 * s, boxShadow: "0 3px 12px rgba(0,0,0,0.06)" }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 6 * s }}>
                <span style={{ background: Colors.primaryDim, color: Colors.primary, borderRadius: 8 * s, padding: `${2 * s}px ${7 * s}px`, fontSize: 7.5 * s, fontFamily: "system-ui", fontWeight: 700 }}>
                  Age {p.age}
                </span>
                <span style={{ fontSize: 7.5 * s, color: "#9CA3AF", fontFamily: "system-ui" }}>{p.time}</span>
              </div>
              <p style={{ fontFamily: "system-ui", fontSize: 9 * s, color: Colors.charcoal, lineHeight: 1.5, margin: 0, marginBottom: 8 * s }}>{p.content}</p>
              <div style={{ display: "flex", gap: 12 * s }}>
                <span style={{ fontSize: 8 * s, color: Colors.primary, fontFamily: "system-ui" }}>💚 {p.likes}</span>
                <span style={{ fontSize: 8 * s, color: "#9CA3AF", fontFamily: "system-ui" }}>💬 Reply</span>
              </div>
            </div>
          );
        })}

        {/* Post box */}
        <div style={{ background: "white", borderRadius: 14 * s, padding: 10 * s, border: `1.5px dashed ${Colors.primaryMid ?? "#D0E8E3"}`, display: "flex", alignItems: "center", gap: 8 * s }}>
          <span style={{ fontSize: 14 * s }}>✏️</span>
          <span style={{ fontFamily: "system-ui", fontSize: 8.5 * s, color: "#9CA3AF" }}>Share something supportive...</span>
        </div>
      </div>
    </div>
  );
};

// ── Resources Screen (matches resources_screen.dart) ─────────────────────────
export const ResourcesScreen: React.FC<{ s: number }> = ({ s }) => {
  const frame = useCurrentFrame();
  const categories = ["All", "Mental Health", "SRHR", "Wellness", "Crisis"];
  const resources = [
    { icon: "🧠", cat: "Mental Health", title: "Managing Exam Anxiety", time: "5 min", offline: true },
    { icon: "❤️", cat: "SRHR", title: "Understanding Consent", time: "8 min", offline: true },
    { icon: "🌿", cat: "Wellness", title: "Self-Care Routines", time: "4 min", offline: false },
    { icon: "🆘", cat: "Crisis", title: "When to Get Help", time: "3 min", offline: true },
  ];

  return (
    <div style={{ background: Colors.cream, height: "100%", display: "flex", flexDirection: "column" }}>
      <StatusBar s={s} />
      <AppBar title="Resources" subtitle="Guides & articles, offline ready" icon="📚" s={s} />

      <div style={{ padding: `${8 * s}px ${8 * s}px ${4 * s}px`, display: "flex", gap: 6 * s, overflow: "hidden" }}>
        {categories.map((c, i) => (
          <div key={i} style={{ background: i === 0 ? Colors.primary : "white", color: i === 0 ? "white" : Colors.charcoal, borderRadius: 20 * s, padding: `${4 * s}px ${10 * s}px`, fontSize: 8 * s, fontFamily: "system-ui", fontWeight: i === 0 ? 700 : 500, whiteSpace: "nowrap", border: `1px solid ${i === 0 ? "transparent" : Colors.primaryDim}` }}>
            {c}
          </div>
        ))}
      </div>

      <div style={{ flex: 1, padding: `${6 * s}px ${8 * s}px`, display: "flex", flexDirection: "column", gap: 8 * s, overflow: "hidden" }}>
        {resources.map((r, i) => {
          const delay = i * 12;
          const opacity = interpolate(frame - delay, [0, 12], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          const ty = interpolate(frame - delay, [0, 14], [12, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          return (
            <div key={i} style={{ opacity, transform: `translateY(${ty}px)`, background: "white", borderRadius: 14 * s, padding: 12 * s, boxShadow: "0 3px 12px rgba(0,0,0,0.06)", display: "flex", gap: 10 * s, alignItems: "center" }}>
              <div style={{ width: 40 * s, height: 40 * s, borderRadius: 12 * s, background: Colors.primaryDim, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20 * s, flexShrink: 0 }}>
                {r.icon}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: "system-ui", fontSize: 9.5 * s, fontWeight: 700, color: Colors.charcoal, marginBottom: 3 * s }}>{r.title}</div>
                <div style={{ display: "flex", gap: 6 * s, alignItems: "center" }}>
                  <span style={{ fontSize: 7.5 * s, color: "#9CA3AF", fontFamily: "system-ui" }}>⏱ {r.time}</span>
                  {r.offline && <span style={{ fontSize: 7 * s, background: Colors.primaryDim, color: Colors.primary, borderRadius: 6 * s, padding: `${1 * s}px ${5 * s}px`, fontFamily: "system-ui", fontWeight: 600 }}>Offline</span>}
                </div>
              </div>
              <div style={{ fontSize: 14 * s, color: "#D1D5DB" }}>›</div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Re-export Colors for use in compositions
export { Colors };
const ColorsMid = { primaryMid: "#D0E8E3" };
export { ColorsMid };
