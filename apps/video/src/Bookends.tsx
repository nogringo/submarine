import type { ReactNode } from "react";
import { AbsoluteFill } from "remotion";
import vault from "../../../packages/nostr_passwords/lib/src/vault.dart";
import { Captions, Rings, ramp, Sonar, useTime, Wordmark } from "./components.tsx";
import { t } from "./messages.ts";
import { colors, fonts } from "./theme.ts";
import { captions, pings } from "./timeline.ts";

function Centered({ top, shown, children }: { top: number; shown: number; children: ReactNode }) {
  return (
    <div
      style={{
        position: "absolute",
        top,
        left: 0,
        right: 0,
        display: "flex",
        justifyContent: "center",
        opacity: shown,
        transform: `translateY(${(1 - shown) * 18}px)`,
      }}
    >
      {children}
    </div>
  );
}

export function Intro() {
  const time = useTime();
  const [kind, tagline] = captions.intro;
  const wordmark = ramp(time, 1.5, 0.9);
  return (
    <AbsoluteFill>
      <Rings cy={350} />
      <Centered top={180} shown={1}>
        <Sonar size={340} pings={pings.intro} />
      </Centered>
      <Centered top={590} shown={wordmark}>
        <Wordmark size={116} style={{ letterSpacing: 9 + 14 * (1 - wordmark) }} />
      </Centered>
      {kind && (
        <Centered top={735} shown={ramp(time, kind.from, 0.7)}>
          <div style={{ fontSize: 40, color: colors.muted }}>{t(kind.title)}</div>
        </Centered>
      )}
      {tagline && (
        <Centered top={850} shown={ramp(time, tagline.from, 0.7)}>
          <div style={{ fontSize: 48, fontWeight: 600 }}>{t(tagline.title)}</div>
        </Centered>
      )}
    </AbsoluteFill>
  );
}

/** The lines of the vault's createItem, as the package has them. */
const createItem = (() => {
  const lines = vault.split("\n");
  const start = lines.findIndex((line) => line.includes("Future<Envelope> createItem("));
  const end = lines.findIndex((line, i) => i > start && line === "  }");
  return lines
    .slice(start, end + 1)
    .map((line, i) => ({ number: start + i + 1, text: line.slice(2) }));
})();

const tokens = /'[^']*'|\b(?:async|await|final|return|const)\b|\b[A-Z]\w*|\b\w+(?=:)/g;

/** A line of Dart, its strings, keywords, types and argument names told apart. */
function Code({ line }: { line: string }) {
  const parts: ReactNode[] = [];
  let last = 0;
  for (const { 0: token, index } of line.matchAll(tokens)) {
    parts.push(line.slice(last, index));
    const style = token.startsWith("'")
      ? { color: colors.accent }
      : /^[A-Z]/.test(token)
        ? { fontWeight: 600 }
        : line[index + token.length] === ":"
          ? { color: colors.muted }
          : { color: colors.symbol };
    parts.push(
      <span key={index} style={style}>
        {token}
      </span>,
    );
    last = index + token.length;
  }
  parts.push(line.slice(last));
  return parts;
}

export function OpenSource() {
  const time = useTime();
  return (
    <AbsoluteFill>
      <Rings />
      <div
        style={{
          position: "absolute",
          left: 410,
          width: 1100,
          top: 330,
          borderRadius: 16,
          background: colors.surface,
          border: `2px solid ${colors.line}`,
          overflow: "hidden",
          opacity: ramp(time, 0.2, 0.6),
          transform: `translateY(${(1 - ramp(time, 0.2, 0.8)) * 30}px)`,
        }}
      >
        <div
          style={{
            padding: "16px 28px",
            borderBottom: `2px solid ${colors.line}`,
            fontFamily: fonts.mono,
            fontSize: 22,
            color: colors.muted,
          }}
        >
          packages/nostr_passwords/lib/src/vault.dart
        </div>
        <pre
          style={{
            margin: 0,
            padding: "22px 28px 26px",
            fontFamily: fonts.mono,
            fontSize: 26,
            lineHeight: 1.5,
            color: colors.text,
          }}
        >
          {createItem.map(({ number, text }) => (
            <div
              key={number}
              style={{
                opacity: ramp(time, 0.6 + 0.07 * (number - createItem[0].number), 0.4),
                minHeight: 39,
              }}
            >
              <Code line={text} />
            </div>
          ))}
        </pre>
      </div>
      <Captions scene="openSource" />
    </AbsoluteFill>
  );
}

export function Outro() {
  const time = useTime();
  const [license] = captions.outro;
  return (
    <AbsoluteFill>
      <Rings cy={290} />
      <Centered top={150} shown={1}>
        <Sonar size={280} pings={pings.outro} />
      </Centered>
      <Centered top={490} shown={ramp(time, 0.5, 0.8)}>
        <Wordmark size={96} />
      </Centered>
      <Centered top={625} shown={ramp(time, 0.9, 0.8)}>
        <div style={{ fontSize: 84, fontWeight: 700 }}>submarine.li</div>
      </Centered>
      {license && (
        <Centered top={790} shown={ramp(time, license.from, 0.8)}>
          <div style={{ fontSize: 34, color: colors.muted }}>{t(license.title)}</div>
        </Centered>
      )}
    </AbsoluteFill>
  );
}
