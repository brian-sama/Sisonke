import React from "react";
import { interpolate, useCurrentFrame } from "remotion";
import { Colors } from "./Brand";
import { useFloat } from "./Animations";

interface PhoneMockupProps {
  scale?: number;
  children: React.ReactNode;
  /** 0–1 entrance progress */
  enterProgress?: number;
}

export const PhoneMockup: React.FC<PhoneMockupProps> = ({
  scale = 1,
  children,
  enterProgress = 1,
}) => {
  const floatStyle = useFloat(6, 100);
  const phoneW = 280 * scale;
  const phoneH = 580 * scale;
  const r = 40 * scale;

  const translateY = interpolate(enterProgress, [0, 1], [80, 0]);
  const opacity = interpolate(enterProgress, [0, 0.4], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        ...floatStyle,
        opacity,
        transform: `${floatStyle.transform} translateY(${translateY}px)`,
      }}
    >
      {/* Outer shell */}
      <div
        style={{
          width: phoneW,
          height: phoneH,
          borderRadius: r,
          background: `linear-gradient(145deg, #374151, #1f2937)`,
          boxShadow: `0 40px 80px rgba(0,0,0,0.45), 0 0 0 ${2 * scale}px #4b5563, inset 0 2px 4px rgba(255,255,255,0.1)`,
          position: "relative",
          overflow: "hidden",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          padding: `${12 * scale}px ${8 * scale}px ${8 * scale}px`,
        }}
      >
        {/* Status bar */}
        <div style={{ width: "100%", display: "flex", justifyContent: "space-between", paddingLeft: 16 * scale, paddingRight: 16 * scale, marginBottom: 4 * scale }}>
          <span style={{ color: "white", fontSize: 10 * scale, fontFamily: "system-ui", fontWeight: 600 }}>9:41</span>
          <div style={{ display: "flex", gap: 4 * scale, alignItems: "center" }}>
            <span style={{ color: "white", fontSize: 10 * scale }}>●●●</span>
            <span style={{ color: "white", fontSize: 10 * scale }}>WiFi</span>
            <span style={{ color: "white", fontSize: 10 * scale }}>🔋</span>
          </div>
        </div>

        {/* Dynamic island */}
        <div
          style={{
            width: 80 * scale,
            height: 22 * scale,
            background: "#000",
            borderRadius: 12 * scale,
            marginBottom: 6 * scale,
          }}
        />

        {/* Screen content */}
        <div
          style={{
            flex: 1,
            width: "100%",
            borderRadius: 24 * scale,
            overflow: "hidden",
            background: Colors.cream,
          }}
        >
          {children}
        </div>

        {/* Home indicator */}
        <div
          style={{
            width: 100 * scale,
            height: 4 * scale,
            background: "rgba(255,255,255,0.4)",
            borderRadius: 2 * scale,
            marginTop: 8 * scale,
          }}
        />
      </div>
    </div>
  );
};

/** A fake chat bubble for eFriend screen */
export const ChatBubble: React.FC<{
  text: string;
  isUser: boolean;
  scale: number;
  delay: number;
}> = ({ text, isUser, scale, delay }) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame - delay, [0, 8], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const translateY = interpolate(frame - delay, [0, 12], [10, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        opacity,
        transform: `translateY(${translateY}px)`,
        display: "flex",
        justifyContent: isUser ? "flex-end" : "flex-start",
        marginBottom: 8 * scale,
        paddingLeft: isUser ? 24 * scale : 0,
        paddingRight: isUser ? 0 : 24 * scale,
      }}
    >
      {!isUser && (
        <div
          style={{
            width: 24 * scale,
            height: 24 * scale,
            borderRadius: 12 * scale,
            background: Colors.primary,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 12 * scale,
            marginRight: 6 * scale,
            flexShrink: 0,
          }}
        >
          💚
        </div>
      )}
      <div
        style={{
          background: isUser ? Colors.primary : Colors.white,
          color: isUser ? Colors.white : Colors.charcoal,
          borderRadius: isUser ? `${12 * scale}px ${12 * scale}px 2px ${12 * scale}px` : `${12 * scale}px ${12 * scale}px ${12 * scale}px 2px`,
          padding: `${6 * scale}px ${10 * scale}px`,
          fontSize: 9 * scale,
          fontFamily: "system-ui",
          maxWidth: "75%",
          lineHeight: 1.4,
          boxShadow: "0 2px 8px rgba(0,0,0,0.08)",
        }}
      >
        {text}
      </div>
    </div>
  );
};
