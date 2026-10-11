import type { SyncState } from "./core";

export type SyncStatus =
  | { id: "syncFailed" | "syncing" | "syncedJustNow" }
  | { id: "syncedMinutesAgo"; minutes: number }
  | { id: "syncedHoursAgo"; hours: number }
  | { id: "syncedOn"; date: Date };

/**
 * Where the sync of several vaults stands, as one, as the app tells it: a failure as soon as one
 * vault reaches no relay, else the oldest last sync. A vault the sync did not get to yet syncs.
 */
export function syncStatus(pubkeys: string[], states: SyncState[], now = new Date()): SyncStatus {
  const selected = pubkeys.map((pubkey) => states.find((state) => state.pubkey === pubkey));
  if (selected.some((state) => state?.phase === "failed")) return { id: "syncFailed" };
  const lastSyncs = selected.map((state) => state?.lastSync);
  if (lastSyncs.length === 0 || lastSyncs.some((lastSync) => !lastSync)) return { id: "syncing" };
  const lastSync = Math.min(...lastSyncs.map((lastSync) => Date.parse(lastSync ?? "")));
  const minutes = Math.floor((now.getTime() - lastSync) / 60_000);
  if (minutes < 1) return { id: "syncedJustNow" };
  if (minutes < 60) return { id: "syncedMinutesAgo", minutes };
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return { id: "syncedHoursAgo", hours };
  return { id: "syncedOn", date: new Date(lastSync) };
}

/** Whether one of the vaults of `pubkeys` syncs, as the app's sync button turns. */
export function anySyncing(pubkeys: string[], states: SyncState[]): boolean {
  return states.some((state) => state.phase === "syncing" && pubkeys.includes(state.pubkey));
}
