import type { CSSProperties, ReactNode } from "react";
import { AbsoluteFill, Easing, Img, interpolate, staticFile, useCurrentFrame } from "remotion";
import { t } from "./messages.ts";
import { colors, fonts } from "./theme.ts";
import { captions, fps, type Scene } from "./timeline.ts";

export const easeOut = Easing.out(Easing.cubic);
export const easeInOut = Easing.inOut(Easing.cubic);

/** From 0 to 1 over `length` seconds from `from`, as `time` passes. */
export function ramp(time: number, from: number, length: number, easing = easeOut): number {
  return interpolate(time, [from, from + length], [0, 1], {
    easing,
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
}

/** Seconds into the current sequence. */
export function useTime(): number {
  return useCurrentFrame() / fps;
}

/** The deep blue of the app and its glow, behind every scene. */
export function Backdrop() {
  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 960px 600px, ${colors.glow}, ${colors.background} 70%)`,
      }}
    />
  );
}

/** Sonar rings around the subject of a scene. */
export function Rings({ cx = 960, cy = 600 }: { cx?: number; cy?: number }) {
  return (
    <svg width={1920} height={1080} aria-hidden="true" style={{ position: "absolute" }}>
      <g fill="none" stroke="#1d3d5a" strokeWidth={2}>
        {[1, 2, 3, 4, 5, 6, 7, 8].map((ring) => (
          <circle key={ring} cx={cx} cy={cy} r={ring * 150} />
        ))}
      </g>
    </svg>
  );
}

/**
 * The app's sonar, `size` pixels wide: its rings draw in from `from` seconds, and a ping travels
 * outwards at each of `pings`, for 3.2 seconds, as on the site.
 */
export function Sonar({
  size,
  from = 0,
  pings = [],
}: {
  size: number;
  from?: number;
  pings?: number[];
}) {
  const time = useTime() - from;
  const ping = pings.findLast((at) => time >= at && time < at + 3.2);
  const cycle = ping === undefined ? 1 : (time - ping) / 3.2;
  const signal = ramp(time, 0.45, 0.5, Easing.out(Easing.back(2.2)));
  return (
    <svg width={size} height={size} viewBox="-100 -100 200 200" aria-hidden="true">
      <g fill="none" stroke={colors.line} strokeWidth={1.5} vectorEffect="non-scaling-stroke">
        {[24, 49, 74, 99].map((r, i) => {
          const shown = ramp(time, 0.08 * i, 0.6);
          return (
            <circle
              key={r}
              r={r * (0.85 + 0.15 * shown)}
              opacity={shown}
              vectorEffect="non-scaling-stroke"
            />
          );
        })}
        <path
          d="M-100 0H100M0-100V100"
          opacity={ramp(time, 0.3, 0.6)}
          vectorEffect="non-scaling-stroke"
        />
      </g>
      {ping !== undefined && (
        <circle
          r={99 * easeOut(cycle)}
          fill="none"
          stroke={colors.accent}
          strokeWidth={3}
          strokeOpacity={1 - cycle}
          vectorEffect="non-scaling-stroke"
        />
      )}
      <circle r={6 * signal} fill={colors.accent} />
      <circle
        cx={35}
        cy={-46}
        r={3.5 * ramp(time, 1, 0.4, Easing.out(Easing.back(2)))}
        fill={colors.accent}
        opacity={1 - 0.65 * cycle}
      />
    </svg>
  );
}

export function Wordmark({ size, style }: { size: number; style?: CSSProperties }) {
  return (
    <div
      style={{
        fontFamily: fonts.wordmark,
        fontSize: size,
        letterSpacing: size * 0.08,
        color: colors.accent,
        textTransform: "uppercase",
        lineHeight: 1,
        ...style,
      }}
    >
      Submarine
    </div>
  );
}

/** The captions of `scene` at the top of the frame, each faded in and out in its time. */
export function Captions({ scene }: { scene: Scene }) {
  const time = useTime();
  return captions[scene].map((caption) => {
    const shown = ramp(time, caption.from, 0.45) * (1 - ramp(time, caption.to - 0.35, 0.35));
    if (shown <= 0) return null;
    return (
      <div
        key={caption.title}
        style={{
          position: "absolute",
          top: 64,
          left: 0,
          right: 0,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          opacity: shown,
          transform: `translateY(${(1 - shown) * 14}px)`,
        }}
      >
        <h1
          style={{
            margin: 0,
            maxWidth: 1560,
            fontSize: 56,
            fontWeight: 700,
            lineHeight: 1.15,
            textAlign: "center",
            textWrap: "balance",
          }}
        >
          {t(caption.title)}
        </h1>
        {caption.body && (
          <p
            style={{
              margin: "18px 0 0",
              maxWidth: 1240,
              fontSize: 31,
              lineHeight: 1.45,
              color: colors.muted,
              textAlign: "center",
              textWrap: "balance",
            }}
          >
            {t(caption.body)}
          </p>
        )}
      </div>
    );
  });
}

/** A frame of a take of apps/app/tool/video_test.dart, held on its last one past its end. */
export function Footage({ take, frame, frames }: { take: string; frame: number; frames: number }) {
  const n = Math.min(Math.max(Math.round(frame), 0), frames - 1);
  return (
    <Img
      src={staticFile(`footage/${take}/${String(n).padStart(4, "0")}.png`)}
      style={{ display: "block", width: "100%", height: "100%" }}
    />
  );
}

/** A desktop window, as the site frames its screenshots. */
export function Window({ children, style }: { children: ReactNode; style?: CSSProperties }) {
  return (
    <div
      style={{
        position: "absolute",
        width: 1280,
        height: 800,
        borderRadius: 12,
        overflow: "hidden",
        outline: `1.5px solid ${colors.outline}`,
        boxShadow: "0 40px 90px -20px rgb(0 0 0 / 0.6)",
        ...style,
      }}
    >
      {children}
    </div>
  );
}

/** A phone in its shell, as the site frames its screenshots, 390 by 844 inside. */
export function Phone({ children, style }: { children: ReactNode; style?: CSSProperties }) {
  return (
    <div
      style={{
        position: "absolute",
        padding: 9,
        borderRadius: 50,
        background: "#050f17",
        outline: `1.5px solid ${colors.line}`,
        boxShadow: "0 40px 90px -20px rgb(0 0 0 / 0.6)",
        ...style,
      }}
    >
      <div style={{ width: 390, height: 844, borderRadius: 41, overflow: "hidden" }}>
        {children}
      </div>
    </div>
  );
}

/** Fades its scene in and out, over `edge` seconds, within `seconds`. */
export function Fade({
  seconds,
  edge = 0.4,
  children,
}: {
  seconds: number;
  edge?: number;
  children: ReactNode;
}) {
  const time = useTime();
  const opacity =
    ramp(time, 0, edge, Easing.linear) * (1 - ramp(time, seconds - edge, edge, Easing.linear));
  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
}
