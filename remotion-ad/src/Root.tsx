import React from "react";
import { Composition } from "remotion";
import { SisonkePortrait } from "./SisonkePortrait";
import { SisonkeLandscape } from "./SisonkeLandscape";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* 9:16 Portrait — Instagram / TikTok / WhatsApp Story — 30 seconds */}
      <Composition
        id="SisonkePortrait"
        component={SisonkePortrait}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{}}
      />

      {/* 16:9 Landscape — YouTube / Web — 60 seconds */}
      <Composition
        id="SisonkeLandscape"
        component={SisonkeLandscape}
        durationInFrames={1800}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{}}
      />
    </>
  );
};
