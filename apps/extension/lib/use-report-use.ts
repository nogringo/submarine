import { useEffect } from "react";
import { callCore } from "./core";

/** Often enough for the lock to wait from the last use, give or take this. */
const reportEvery = 5_000;

const uses = ["pointerdown", "pointermove", "keydown", "wheel"] as const;

/** While `active`, tells the core each use of the popup, as the app counts them, to push the lock back. */
export function useReportUse(active: boolean) {
  useEffect(() => {
    if (!active) return;
    let reported = 0;
    const report = () => {
      const now = Date.now();
      if (now - reported < reportEvery) return;
      reported = now;
      void callCore("used", {});
    };
    for (const type of uses) document.addEventListener(type, report, { capture: true });
    return () => {
      for (const type of uses) document.removeEventListener(type, report, { capture: true });
    };
  }, [active]);
}
