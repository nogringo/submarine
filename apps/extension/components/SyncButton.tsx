import syncIcon from "@material-design-icons/svg/round/sync.svg";
import { useEffect, useState } from "react";
import { Button } from "react-aria-components";
import { useIntl } from "react-intl";
import { callCore } from "@/lib/core";
import { Icon } from "./Icon";
import "./SyncButton.css";

/**
 * Syncs `vault`, or every vault without one, at once. Its arrows turn while `syncing`, and it waits
 * meanwhile, keeping the focus.
 */
export function SyncButton({ vault, syncing }: { vault?: string; syncing: boolean }) {
  const { formatMessage: t } = useIntl();
  // Ends its turn rather than stop askew, as in the app.
  const [turning, setTurning] = useState(syncing);
  useEffect(() => {
    if (syncing) setTurning(true);
  }, [syncing]);
  return (
    <Button
      className="button icon-button sync-button"
      aria-label={t({ id: "syncNow" })}
      isPending={syncing}
      onPress={() => void callCore("syncNow", vault ? { vault } : {})}
    >
      <span
        className="sync-button-arrows"
        data-turning={turning || undefined}
        onAnimationIteration={() => {
          if (!syncing) setTurning(false);
        }}
      >
        <Icon src={syncIcon} />
      </span>
    </Button>
  );
}
