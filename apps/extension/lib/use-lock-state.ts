import { useCallback, useEffect, useRef, useState } from "react";
import { callCore, type LockState } from "./core";

/**
 * Whether the vaults are locked, read again at each `revision` or `read`, the last read winning.
 * `lockNow` shows them locked at once: no read sent before the lock ends can show them again.
 */
export function useLockState(revision: number) {
  const [lock, setLock] = useState<LockState>();
  const lastRead = useRef(0);
  const locking = useRef(false);
  const read = useCallback(() => {
    const thisRead = ++lastRead.current;
    void callCore("lockState", {}).then((state) => {
      if (thisRead === lastRead.current && !locking.current) setLock(state);
    });
  }, []);
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(() => read(), [revision]);
  const lockNow = useCallback(() => {
    locking.current = true;
    setLock((lock) => lock && { ...lock, locked: true });
    void callCore("lock", {}).finally(() => {
      locking.current = false;
      read();
    });
  }, [read]);
  return { lock, read, lockNow };
}
