import { AbsoluteFill, Easing, interpolate, random } from "remotion";
import { Captions, easeInOut, Rings, ramp, useTime } from "./components.tsx";
import { colors, fonts } from "./theme.ts";

const vaults = [
  { letter: "P", color: "#2f6fd0" },
  { letter: "F", color: "#b95a22" },
  { letter: "W", color: "#2a7f61" },
];

const base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/** `text` turned into ciphertext as `progress` goes from 0 to 1, a character after another. */
function scramble(text: string, progress: number, seed: string): string {
  return [...text]
    .map((char, i) => {
      const turn = (i / text.length) * 0.75 + random(`${seed}${i}`) * 0.25;
      if (progress < turn) return char;
      return char === " " ? "" : base64[Math.floor(random(`${seed}c${i}`) * base64.length)];
    })
    .join("");
}

function Lock({ x, y, size, color }: { x: number; y: number; size: number; color: string }) {
  const s = size / 24;
  return (
    <g transform={`translate(${x - size / 2} ${y - size / 2}) scale(${s})`}>
      <path d="M7 11V8a5 5 0 0 1 10 0v3" fill="none" stroke={color} strokeWidth={2.4} />
      <rect x={4.5} y={10.5} width={15} height={11} rx={2.5} fill={color} />
    </g>
  );
}

/** A relay: a server in a circle. */
function Relay({
  x,
  y,
  r = 46,
  stroke = colors.outline,
}: {
  x: number;
  y: number;
  r?: number;
  stroke?: string;
}) {
  const bar = r * 0.9;
  return (
    <g>
      <circle cx={x} cy={y} r={r} fill={colors.surface} stroke={stroke} strokeWidth={2.5} />
      {[-1, 0, 1].map((row) => (
        <g key={row}>
          <rect
            x={x - bar / 2}
            y={y + row * r * 0.3 - r * 0.11}
            width={bar}
            height={r * 0.22}
            rx={r * 0.06}
            fill="none"
            stroke={stroke}
            strokeWidth={2}
          />
          <circle cx={x + bar * 0.3} cy={y + row * r * 0.3} r={r * 0.04} fill={stroke} />
        </g>
      ))}
    </g>
  );
}

function Laptop({
  x,
  y,
  width,
  unlocked,
}: {
  x: number;
  y: number;
  width: number;
  unlocked: number;
}) {
  const height = width * 0.62;
  const left = x - width / 2;
  const top = y - height / 2;
  return (
    <g>
      <rect
        x={left}
        y={top}
        width={width}
        height={height}
        rx={width * 0.04}
        fill={colors.surface}
        stroke={colors.outline}
        strokeWidth={3}
      />
      <rect
        x={left - width * 0.1}
        y={top + height + 6}
        width={width * 1.2}
        height={width * 0.045}
        rx={width * 0.02}
        fill={colors.outline}
      />
      <Screen left={left} top={top} width={width} height={height} unlocked={unlocked} rail />
    </g>
  );
}

function Handset({
  x,
  y,
  height,
  unlocked,
}: {
  x: number;
  y: number;
  height: number;
  unlocked: number;
}) {
  const width = height * 0.52;
  const left = x - width / 2;
  const top = y - height / 2;
  return (
    <g>
      <rect
        x={left}
        y={top}
        width={width}
        height={height}
        rx={width * 0.16}
        fill={colors.surface}
        stroke={colors.outline}
        strokeWidth={3}
      />
      <Screen left={left} top={top} width={width} height={height} unlocked={unlocked} />
    </g>
  );
}

/** A device's screen, locked, then showing the vaults as `unlocked` goes from 0 to 1. */
function Screen({
  left,
  top,
  width,
  height,
  unlocked,
  rail = false,
}: {
  left: number;
  top: number;
  width: number;
  height: number;
  unlocked: number;
  rail?: boolean;
}) {
  const unit = Math.min(width, height) / 9;
  const rows = [0, 1, 2, 3];
  const listLeft = rail ? left + unit * 2.6 : left + unit * 1.1;
  return (
    <g>
      <g opacity={1 - unlocked}>
        <Lock x={left + width / 2} y={top + height / 2} size={unit * 3} color={colors.muted} />
      </g>
      <g opacity={unlocked}>
        {rail &&
          vaults.map((vault, i) => (
            <circle
              key={vault.letter}
              cx={left + unit * 1.3}
              cy={top + unit * (1.4 + i * 1.8)}
              r={unit * 0.7 * ramp(unlocked, 0.15 * i, 0.5)}
              fill={vault.color}
            />
          ))}
        {rows.map((row) => {
          const shown = ramp(unlocked, 0.2 + 0.12 * row, 0.5);
          const rowTop = top + unit * (1 + row * (rail ? 1.65 : 2.1));
          return (
            <g key={row} opacity={shown}>
              <rect
                x={listLeft}
                y={rowTop}
                width={unit * 1.1}
                height={unit * 1.1}
                rx={unit * 0.25}
                fill={vaults[row % 3]?.color}
              />
              <rect
                x={listLeft + unit * 1.6}
                y={rowTop + unit * 0.15}
                width={(rail ? width * 0.42 : width * 0.5) * (0.7 + 0.3 * random(`row${row}`))}
                height={unit * 0.32}
                rx={unit * 0.16}
                fill={colors.muted}
              />
              <rect
                x={listLeft + unit * 1.6}
                y={rowTop + unit * 0.65}
                width={(rail ? width * 0.28 : width * 0.34) * (0.6 + 0.4 * random(`sub${row}`))}
                height={unit * 0.26}
                rx={unit * 0.13}
                fill={colors.line}
              />
            </g>
          );
        })}
      </g>
    </g>
  );
}

const plain = [
  { label: "Username", value: "alice-dev" },
  { label: "Password", value: "correct horse battery staple" },
];

/** An item leaving the device, its text turned to ciphertext on the way to a relay. */
export function Encrypted() {
  const time = useTime();
  const travel = ramp(time, 1.2, 2.4, easeInOut);
  const leaving = ramp(time, 1, 0.3);
  const arrived = ramp(time, 3.6, 0.5, Easing.in(Easing.cubic));
  const packetX = interpolate(travel, [0, 1], [1000, 1290]) + 270 * arrived;
  const relay = { x: 1560, y: 600 };
  const pulse = ramp(time, 3.6, 1.2);
  return (
    <AbsoluteFill>
      <svg width={1920} height={1080} aria-hidden="true" style={{ position: "absolute" }}>
        <g fill="none" stroke="#1d3d5a" strokeWidth={2}>
          <circle cx={relay.x} cy={relay.y} r={150} />
          <circle cx={relay.x} cy={relay.y} r={230} />
        </g>
        <line
          x1={800}
          y1={600}
          x2={relay.x - 100}
          y2={600}
          stroke={colors.line}
          strokeWidth={3}
          strokeDasharray="10 14"
          opacity={ramp(time, 0.5, 0.6)}
        />
        {pulse > 0 && pulse < 1 && (
          <circle
            cx={relay.x}
            cy={relay.y}
            r={100 + 150 * pulse}
            fill="none"
            stroke={colors.accent}
            strokeWidth={3}
            strokeOpacity={1 - pulse}
          />
        )}
        <g opacity={ramp(time, 0.3, 0.6)}>
          <Relay x={relay.x} y={relay.y} r={100} />
        </g>
      </svg>
      <ItemCard
        left={200}
        top={430}
        opacity={ramp(time, 0.1, 0.6)}
        rows={plain.map(({ label, value }) => ({ label, value }))}
      />
      {leaving > 0 && (
        <div
          style={{
            position: "absolute",
            left: packetX,
            top: 600,
            transform: `translate(-50%, -50%) scale(${0.62 * (1 - 0.75 * arrived)})`,
            opacity: leaving * (1 - arrived),
          }}
        >
          <ItemCard
            left={0}
            top={0}
            position="relative"
            locked
            rows={plain.map(({ label, value }) => ({
              label: scramble(label, travel, `l${label}`),
              value: scramble(value, travel, `v${value}`),
            }))}
          />
        </div>
      )}
      <div
        style={{
          position: "absolute",
          left: relay.x - 230,
          width: 460,
          top: relay.y + 140,
          fontFamily: fonts.mono,
          fontSize: 24,
          lineHeight: 1.5,
          color: colors.muted,
          textAlign: "center",
          wordBreak: "break-all",
          opacity: ramp(time, 4, 0.6),
        }}
      >
        {scramble("x".repeat(46), 1, "stored")}
      </div>
      <Captions scene="encrypted" />
    </AbsoluteFill>
  );
}

function ItemCard({
  left,
  top,
  rows,
  opacity = 1,
  locked = false,
  position = "absolute",
}: {
  left: number;
  top: number;
  rows: { label: string; value: string }[];
  opacity?: number;
  locked?: boolean;
  position?: "absolute" | "relative";
}) {
  return (
    <div
      style={{
        position,
        left,
        top,
        width: 600,
        opacity,
        borderRadius: 18,
        background: colors.surface,
        border: `2px solid ${locked ? colors.accent : colors.line}`,
        overflow: "hidden",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 18, padding: "22px 26px" }}>
        <div
          style={{
            width: 60,
            height: 60,
            borderRadius: 14,
            background: colors.raised,
            display: "grid",
            placeItems: "center",
            fontSize: 30,
            fontWeight: 700,
          }}
        >
          {locked ? (
            <svg width={34} height={34} viewBox="0 0 34 34" aria-hidden="true">
              <Lock x={17} y={17} size={34} color={colors.accent} />
            </svg>
          ) : (
            "G"
          )}
        </div>
        <div style={{ fontSize: 34, fontWeight: 700 }}>{locked ? "" : "GitHub"}</div>
      </div>
      {rows.map(({ label, value }) => (
        <div key={label} style={{ borderTop: `2px solid ${colors.line}`, padding: "16px 26px" }}>
          <div style={{ fontSize: 22, color: colors.muted, minHeight: 28 }}>{label}</div>
          <div
            style={{
              fontFamily: fonts.mono,
              fontSize: 30,
              marginTop: 4,
              minHeight: 40,
              whiteSpace: "nowrap",
              color: locked ? colors.symbol : colors.text,
            }}
          >
            {value}
          </div>
        </div>
      ))}
    </div>
  );
}

/** One key, which opens the vault on each device. */
export function Key() {
  const time = useTime();
  const key = ramp(time, 0.2, 0.7, Easing.out(Easing.back(1.8)));
  const lines = ramp(time, 1, 0.8, easeInOut);
  const unlocked = ramp(time, 1.8, 1.2, Easing.linear);
  const laptop = { x: 470, y: 640 };
  const handset = { x: 1450, y: 640 };
  return (
    <AbsoluteFill>
      <Rings cy={640} />
      <svg width={1920} height={1080} aria-hidden="true" style={{ position: "absolute" }}>
        {[laptop.x + 240, handset.x - 110].map((end, i) => {
          const start = i === 0 ? 860 : 1060;
          return (
            <line
              key={end}
              x1={start}
              y1={640}
              x2={start + (end - start) * lines}
              y2={640}
              stroke={colors.accent}
              strokeWidth={4}
              strokeDasharray="12 14"
              strokeLinecap="round"
            />
          );
        })}
        <g opacity={ramp(time, 0, 0.6)}>
          <Laptop x={laptop.x} y={laptop.y} width={400} unlocked={unlocked} />
          <Handset x={handset.x} y={handset.y} height={330} unlocked={unlocked} />
        </g>
        <g
          transform={`translate(960 640) scale(${key}) rotate(${(1 - key) * -30})`}
          fill={colors.accent}
        >
          <circle r={58} fill="none" stroke={colors.accent} strokeWidth={26} cx={-52} />
          <rect x={4} y={-13} width={120} height={26} rx={6} />
          <rect x={84} y={6} width={18} height={36} rx={4} />
          <rect x={50} y={6} width={18} height={26} rx={4} />
        </g>
      </svg>
      <Captions scene="key" />
    </AbsoluteFill>
  );
}

const center = { x: 960, y: 640 };
const relays = [-90, -18, 54, 126, 198].map((degrees) => {
  const angle = (degrees * Math.PI) / 180;
  return { x: center.x + 250 * Math.cos(angle), y: center.y + 250 * Math.sin(angle) };
});
const failed = 1;
const failsAt = 8.5;
const from = { x: 395, y: 640 };
const to = { x: 1560, y: 640 };

/** The vault going through several relays, from one device to the other, and on as one fails. */
export function Relays() {
  const time = useTime();
  const failure = ramp(time, failsAt, 0.6);
  const dots: { x: number; y: number; opacity: number; key: string }[] = [];
  const arrivals: number[] = [];
  for (let sent = 0.9; sent < 12; sent += 2.2) {
    relays.forEach((relay, k) => {
      if (k === failed && sent + 0.9 > failsAt) return;
      const start = sent + k * 0.1;
      for (const [a, b, leg] of [
        [from, relay, 0],
        [relay, to, 1],
      ] as const) {
        const p = (time - start - leg * 1) / 0.9;
        if (p < 0 || p > 1) continue;
        const e = easeInOut(p);
        dots.push({
          x: a.x + (b.x - a.x) * e,
          y: a.y + (b.y - a.y) * e,
          opacity: Math.min(1, p * 6, (1 - p) * 6),
          key: `${sent}-${k}-${leg}`,
        });
      }
      arrivals.push(start + 1.9);
    });
  }
  const arrival = arrivals.findLast((at) => time >= at && time < at + 0.8);
  const pulse = arrival === undefined ? 1 : (time - arrival) / 0.8;
  return (
    <AbsoluteFill>
      <svg width={1920} height={1080} aria-hidden="true">
        <g fill="none" stroke="#1d3d5a" strokeWidth={2}>
          {[120, 250, 380].map((r) => (
            <circle key={r} cx={center.x} cy={center.y} r={r} />
          ))}
        </g>
        <g stroke={colors.line} strokeWidth={2} opacity={ramp(time, 0.4, 0.6)}>
          {relays.map((relay, k) => (
            <g key={`${relay.x}`} opacity={k === failed ? 1 - 0.7 * failure : 1}>
              <line x1={from.x} y1={from.y} x2={relay.x} y2={relay.y} />
              <line x1={relay.x} y1={relay.y} x2={to.x} y2={to.y} />
            </g>
          ))}
        </g>
        {relays.map((relay, k) => {
          const shown = ramp(time, 0.3 + 0.1 * k, 0.6, Easing.out(Easing.back(1.6)));
          const down = k === failed ? failure : 0;
          return (
            <g
              key={`${relay.y}`}
              opacity={(1 - 0.55 * down) * Math.min(1, shown)}
              transform={`translate(${relay.x} ${relay.y}) scale(${shown}) translate(${-relay.x} ${-relay.y})`}
            >
              <Relay x={relay.x} y={relay.y} stroke={down > 0.5 ? colors.danger : colors.outline} />
              {down > 0 && (
                <g stroke={colors.danger} strokeWidth={6} strokeLinecap="round" opacity={down}>
                  <line x1={relay.x - 26} y1={relay.y - 26} x2={relay.x + 26} y2={relay.y + 26} />
                  <line x1={relay.x + 26} y1={relay.y - 26} x2={relay.x - 26} y2={relay.y + 26} />
                </g>
              )}
            </g>
          );
        })}
        {dots.map((dot) => (
          <circle
            key={dot.key}
            cx={dot.x}
            cy={dot.y}
            r={8}
            fill={colors.accent}
            opacity={dot.opacity}
          />
        ))}
        {pulse < 1 && (
          <circle
            cx={to.x + 50}
            cy={to.y}
            r={110 + 70 * pulse}
            fill="none"
            stroke={colors.accent}
            strokeWidth={3}
            strokeOpacity={0.8 * (1 - pulse)}
          />
        )}
        <g opacity={ramp(time, 0, 0.6)}>
          <Laptop x={from.x - 125} y={from.y} width={240} unlocked={1} />
          <Handset x={to.x + 50} y={to.y} height={200} unlocked={1} />
        </g>
      </svg>
      <Captions scene="relays" />
    </AbsoluteFill>
  );
}
