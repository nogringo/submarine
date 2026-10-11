import { useEffect, useState } from "react";
import { callCore, type SyncState, syncPort } from "./core";

/**
 * Keeps the vaults synced while the popup is open, and tells where each one stands, read again
 * each time the core tells it moved.
 */
export function useSync(): SyncState[] {
  const [states, setStates] = useState<SyncState[]>([]);
  useEffect(() => {
    let open = true;
    const read = () =>
      callCore("syncStates", {}).then((states) => {
        if (open) setStates(states);
      });
    const port = browser.runtime.connect({ name: syncPort });
    port.onMessage.addListener(read);
    void read();
    return () => {
      open = false;
      port.disconnect();
    };
  }, []);
  return states;
}
