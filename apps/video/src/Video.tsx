import { Audio } from "@remotion/media";
import type { ComponentType } from "react";
import { AbsoluteFill, Easing, Sequence, staticFile } from "remotion";
import { Desktop, Devices } from "./App.tsx";
import { Intro, OpenSource, Outro } from "./Bookends.tsx";
import { Backdrop, Fade, ramp, useTime } from "./components.tsx";
import { Encrypted, Key, Relays } from "./Diagrams.tsx";
import { colors, fonts } from "./theme.ts";
import { duration, fps, type Scene, scenes, starts } from "./timeline.ts";

const views: Record<Scene, ComponentType> = {
  intro: Intro,
  desktop: Desktop,
  devices: Devices,
  encrypted: Encrypted,
  key: Key,
  relays: Relays,
  openSource: OpenSource,
  outro: Outro,
};

export function Video() {
  const time = useTime();
  const at = starts();
  const black =
    1 - ramp(time, 0, 0.6, Easing.linear) * (1 - ramp(time, duration - 0.9, 0.9, Easing.linear));
  return (
    <AbsoluteFill style={{ fontFamily: fonts.text, color: colors.text }}>
      <Backdrop />
      {scenes.map(({ scene, seconds }) => {
        const View = views[scene];
        return (
          <Sequence
            key={scene}
            name={scene}
            from={Math.round(at[scene] * fps)}
            durationInFrames={Math.round(seconds * fps)}
            premountFor={fps}
          >
            <Fade seconds={seconds}>
              <View />
            </Fade>
          </Sequence>
        );
      })}
      <AbsoluteFill style={{ background: "#000", opacity: black }} />
      <Audio src={staticFile("soundtrack.wav")} />
    </AbsoluteFill>
  );
}
