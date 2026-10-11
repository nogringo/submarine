import { useEffect, useState } from "react";
import { callCore, type SyncState, syncPort } from "./core";

export interface Sync {
  states: SyncState[];
  /** Goes up each time the core tells the vaults changed, for their items to be read again. */
  revision: number;
}

/**
 * Keeps the vaults synced while the popup is open, and tells where each one stands, read again
 * each time the core tells it moved.
 */
export function useSync(): Sync {
  const [states, setStates] = useState<SyncState[]>([]);
  const [revision, setRevision] = useState(0);
  useEffect(() => {
    let open = true;
    const read = () =>
      callCore("syncStates", {}).then((states) => {
        if (open) setStates(states);
      });
    const port = browser.runtime.connect({ name: syncPort });
    port.onMessage.addListener(() => {
      setRevision((revision) => revision + 1);
      void read();
    });
    void read();
    return () => {
      open = false;
      port.disconnect();
    };
  }, []);
  return { states, revision };
}
