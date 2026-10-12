import upload from "@material-design-icons/svg/round/upload.svg";
import { useEffect, useState } from "react";
import { useIntl } from "react-intl";
import type { SyncState } from "@/lib/core";
import { dayFormat } from "@/lib/i18n";
import { syncStatus } from "@/lib/sync-status";
import { Icon } from "./Icon";
import "./SyncStatus.css";

/**
 * Where the sync of the vaults of `pubkeys` stands, in a line of muted text, the changes still to
 * send after an arrow, a failure in red.
 */
export function SyncStatus({ pubkeys, states }: { pubkeys: string[]; states: SyncState[] }) {
  const { formatMessage: t, formatDate } = useIntl();
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    // "Synced 3 min ago" has to become "4 min ago" on its own.
    const ticker = setInterval(() => setNow(new Date()), 20_000);
    return () => clearInterval(ticker);
  }, []);
  const status = syncStatus(pubkeys, states, now);
  const text =
    status.id === "syncedOn"
      ? t({ id: status.id }, { date: formatDate(status.date, dayFormat) })
      : t({ id: status.id }, status);
  // A screen reader announces a failure, as the app does, and nothing else.
  return status.id === "syncFailed" ? (
    <p className="sync-status" data-failed role="alert">
      {text}
    </p>
  ) : (
    <p className="sync-status">
      {status.id === "changesNotSent" && <Icon src={upload} size={15} />}
      {text}
    </p>
  );
}
