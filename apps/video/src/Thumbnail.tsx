import { AbsoluteFill } from "remotion";
import { Footage, Phone, Window, Wordmark } from "./components.tsx";
import { t } from "./messages.ts";
import { colors, fonts } from "./theme.ts";
import { fps } from "./timeline.ts";

/** The video's thumbnail: the tagline beside the app on a computer and a phone. */
export function Thumbnail() {
  const [first, second] = t("welcomeTagline").split(/(?<=\.) /);
  const rings = [1, 2, 3, 4, 5].map((ring) => (
    <circle key={ring} cx={930} cy={380} r={ring * 120} />
  ));
  return (
    <AbsoluteFill
      style={{
        fontFamily: fonts.text,
        color: colors.text,
        background: `radial-gradient(circle at 930px 380px, ${colors.glow}, ${colors.background} 70%)`,
      }}
    >
      <svg width={1280} height={720} aria-hidden="true" style={{ position: "absolute" }}>
        <g fill="none" stroke="#1d3d5a" strokeWidth={2}>
          {rings}
        </g>
      </svg>
      <Window style={{ left: 560, top: 205, transformOrigin: "0 0", transform: "scale(0.5)" }}>
        <Footage take="desktop" frame={14.5 * fps} frames={29 * fps} />
      </Window>
      <Phone style={{ left: 1010, top: 150, transformOrigin: "0 0", transform: "scale(0.62)" }}>
        <Footage take="phone" frame={0} frames={9 * fps} />
      </Phone>
      <div style={{ position: "absolute", left: 72, top: 96, width: 520 }}>
        <Wordmark size={46} />
        <div style={{ marginTop: 34, fontSize: 70, fontWeight: 700, lineHeight: 1.08 }}>
          {first}
        </div>
        <div style={{ marginTop: 26, fontSize: 50, fontWeight: 700, color: colors.accent }}>
          {second}
        </div>
      </div>
    </AbsoluteFill>
  );
}
