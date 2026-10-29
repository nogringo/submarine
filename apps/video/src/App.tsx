import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import {
  Captions,
  easeInOut,
  Footage,
  Phone,
  Rings,
  ramp,
  useTime,
  Window,
} from "./components.tsx";
import { t } from "./messages.ts";
import { colors } from "./theme.ts";
import { fps, platforms } from "./timeline.ts";

const desktopFrames = 29 * fps;
const phoneFrames = 9 * fps;

/**
 * Where the camera looks in the desktop take, by its seconds: the point of the window at the middle
 * of the frame below the captions, and the zoom.
 */
const shots = [
  { at: 0, zoom: 1.3, x: 640, y: 311 },
  { at: 7.9, zoom: 1.3, x: 640, y: 311 },
  { at: 8.7, zoom: 1.45, x: 560, y: 300 },
  { at: 9.9, zoom: 1.45, x: 560, y: 300 },
  { at: 10.9, zoom: 2, x: 970, y: 290 },
  { at: 21, zoom: 2, x: 970, y: 290 },
  { at: 21.8, zoom: 1, x: 640, y: 400 },
  { at: 22.1, zoom: 1, x: 640, y: 400 },
  { at: 22.9, zoom: 1.65, x: 645, y: 270 },
];

export function Desktop() {
  const frame = useCurrentFrame();
  const time = useTime();
  const at = shots.map((shot) => shot.at);
  const along = (values: number[]) =>
    interpolate(time, at, values, {
      easing: easeInOut,
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    });
  const zoom = along(shots.map((shot) => shot.zoom));
  const x = along(shots.map((shot) => shot.x));
  const y = along(shots.map((shot) => shot.y));
  const entrance = ramp(time, 0, 0.7);
  return (
    <AbsoluteFill>
      <Rings />
      <Window
        style={{
          left: 0,
          top: 0,
          transformOrigin: "0 0",
          transform: `translate(${960 - x * zoom}px, ${655 - y * zoom + (1 - entrance) * 60}px) scale(${zoom})`,
          opacity: entrance,
        }}
      >
        <Footage take="desktop" frame={frame} frames={desktopFrames} />
      </Window>
      {/* The captions stay readable over the window as the camera comes closer. */}
      <AbsoluteFill
        style={{
          background: `linear-gradient(${colors.background} 0, ${colors.background} 205px, transparent 250px)`,
        }}
      />
      <Captions scene="desktop" />
    </AbsoluteFill>
  );
}

/** The same vault open on a computer and on a phone, the platforms named under them. */
export function Devices() {
  const frame = useCurrentFrame();
  const time = useTime();
  const window = ramp(time, 0, 0.7);
  const phone = ramp(time, 0.2, 0.7);
  return (
    <AbsoluteFill>
      <Rings />
      <Window
        style={{
          left: 225,
          top: 330,
          transformOrigin: "0 0",
          transform: `translateX(${(1 - window) * -50}px) scale(0.75)`,
          opacity: window,
        }}
      >
        <Footage take="desktop" frame={14.5 * fps} frames={desktopFrames} />
      </Window>
      <Phone
        style={{
          left: 1325,
          top: 300,
          transformOrigin: "0 0",
          transform: `translateX(${(1 - phone) * 50}px) scale(0.78)`,
          opacity: phone,
        }}
      >
        <Footage take="phone" frame={frame - 0.3 * fps} frames={phoneFrames} />
      </Phone>
      <div
        style={{
          position: "absolute",
          left: 225,
          width: 960,
          top: 958,
          display: "flex",
          justifyContent: "center",
          gap: 16,
        }}
      >
        {platforms.map((platform, i) => {
          const shown = ramp(time, 1.2 + 0.12 * i, 0.5);
          return (
            <div
              key={platform}
              style={{
                padding: "8px 22px",
                borderRadius: 999,
                border: `1.5px solid ${colors.outline}`,
                background: colors.surface,
                fontSize: 26,
                fontWeight: 600,
                opacity: shown,
                transform: `translateY(${(1 - shown) * 12}px)`,
              }}
            >
              {t(platform)}
            </div>
          );
        })}
      </div>
      <Captions scene="devices" />
    </AbsoluteFill>
  );
}
