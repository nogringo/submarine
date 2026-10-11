import { type CSSProperties, useEffect, useState } from "react";
import { useIntl } from "react-intl";
import { CoreError, callCore } from "@/lib/core";
import { useSecond } from "@/lib/use-second";
import { CopyButton } from "./CopyButton";
import "./TotpTile.css";

interface Code {
  code: string;
  /** When it started, and how long it lasts, in milliseconds. */
  from: number;
  period: number;
}

/** The current code of a verification key, renewed as it expires, as the app shows it. */
export function TotpTile({ label, totpKey }: { label: string; totpKey: string }) {
  const { formatMessage: t } = useIntl();
  const [code, setCode] = useState<Code | "invalid">();
  useEffect(() => {
    let current = true;
    let next: ReturnType<typeof setTimeout>;
    const read = async () => {
      const at = Date.now();
      try {
        const { code, period } = await callCore("totp", { key: totpKey, at });
        if (!current) return;
        const from = at - (at % (period * 1000));
        setCode({ code, from, period: period * 1000 });
        next = setTimeout(read, from + period * 1000 - Date.now());
      } catch (error) {
        if (current && error instanceof CoreError && error.code === "totpInvalid")
          setCode("invalid");
      }
    };
    void read();
    return () => {
      current = false;
      clearTimeout(next);
    };
  }, [totpKey]);
  return (
    <div className="field-tile">
      <div className="field-tile-text">
        <span className="field-tile-label">{label}</span>
        {code === "invalid" ? (
          <span className="field-value totp-invalid">{t({ id: "totpInvalid" })}</span>
        ) : (
          code && (
            <span className="totp-value">
              <span className="totp-code">{grouped(code.code)}</span>
              <TotpRing code={code} />
            </span>
          )
        )}
      </div>
      {code && code !== "invalid" && <CopyButton value={code.code} sensitive />}
    </div>
  );
}

function TotpRing({ code: { from, period } }: { code: Code }) {
  const now = useSecond();
  const seconds = Math.max(0, Math.ceil((from + period - now) / 1000));
  // Bitwarden's threshold, too short to paste the code before it changes.
  const expiring = seconds <= 7;
  return (
    <span className={expiring ? "totp-ring expiring" : "totp-ring"}>
      <svg viewBox="0 0 30 30" aria-hidden="true">
        <circle className="totp-ring-track" cx="15" cy="15" r="13.5" />
        <RingArc key={from} from={from} period={period} />
      </svg>
      <span className="totp-seconds">{seconds}</span>
    </span>
  );
}

/**
 * The time left, which a CSS animation shrinks without a render, started once per code from where
 * the code stands.
 */
function RingArc({ from, period }: { from: number; period: number }) {
  const [delay] = useState(() => from - Date.now());
  const style: CSSProperties = { animationDuration: `${period}ms`, animationDelay: `${delay}ms` };
  return <circle className="totp-ring-left" cx="15" cy="15" r="13.5" style={style} />;
}

/** "892235" reads as "892 235". */
function grouped(code: string): string {
  if (code.length < 6) return code;
  const half = Math.floor(code.length / 2);
  return `${code.slice(0, half)} ${code.slice(half)}`;
}
