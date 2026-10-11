import { describe, expect, it } from "vitest";
import type { SyncState } from "./core";
import { anySyncing, syncStatus } from "./sync-status";

const now = new Date("2026-10-11T12:00:00Z");

function state(pubkey: string, phase: SyncState["phase"], lastSync: string | null): SyncState {
  return { pubkey, phase, lastSync };
}

describe("syncStatus", () => {
  it("syncs until every vault reached a relay once", () => {
    const states = [state("a", "synced", "2026-10-11T11:59:30Z"), state("b", "syncing", null)];
    expect(syncStatus(["a", "b"], states, now)).toEqual({ id: "syncing" });
  });

  it("syncs a vault the sync did not get to yet", () => {
    expect(syncStatus(["a"], [], now)).toEqual({ id: "syncing" });
  });

  it("tells the oldest last sync of the vaults", () => {
    const states = [
      state("a", "synced", "2026-10-11T11:59:30Z"),
      state("b", "synced", "2026-10-11T11:55:00Z"),
    ];
    expect(syncStatus(["a"], states, now)).toEqual({ id: "syncedJustNow" });
    expect(syncStatus(["a", "b"], states, now)).toEqual({ id: "syncedMinutesAgo", minutes: 5 });
  });

  it("counts in hours, then tells the date", () => {
    const hours = [state("a", "synced", "2026-10-11T09:00:00Z")];
    expect(syncStatus(["a"], hours, now)).toEqual({ id: "syncedHoursAgo", hours: 3 });
    const days = [state("a", "synced", "2026-10-09T09:00:00Z")];
    expect(syncStatus(["a"], days, now)).toEqual({
      id: "syncedOn",
      date: new Date("2026-10-09T09:00:00Z"),
    });
  });

  it("fails as soon as one vault reaches no relay", () => {
    const states = [
      state("a", "synced", "2026-10-11T11:59:30Z"),
      state("b", "failed", "2026-10-11T11:00:00Z"),
    ];
    expect(syncStatus(["a", "b"], states, now)).toEqual({ id: "syncFailed" });
    expect(syncStatus(["a"], states, now)).toEqual({ id: "syncedJustNow" });
  });
});

describe("anySyncing", () => {
  it("tells whether one of the vaults syncs, the others left out", () => {
    const states = [state("a", "synced", "2026-10-11T11:59:30Z"), state("b", "syncing", null)];
    expect(anySyncing(["a", "b"], states)).toBe(true);
    expect(anySyncing(["a"], states)).toBe(false);
    expect(anySyncing(["c"], states)).toBe(false);
  });
});
