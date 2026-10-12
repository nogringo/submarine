import syncIcon from "@material-design-icons/svg/round/sync.svg";
import { useEffect, useState } from "react";
import { Button } from "react-aria-components";
import { useIntl } from "react-intl";
import { callCore } from "@/lib/core";
import { Icon } from "./Icon";
import "./SyncButton.css";

/**
 * Syncs `vault`, or every vault without one, at once. Its arrows turn from the press until the core
 * answers and while `syncing`, and it waits meanwhile, keeping the focus.
 */
export function SyncButton({ vault, syncing }: { vault?: string; syncing: boolean }) {
  const { formatMessage: t } = useIntl();
  // The core tells a phase once it read the vault again: a quick sync ends before it says so.
  const [asked, setAsked] = useState(false);
  const pending = syncing || asked;
  // Ends its turn rather than stop askew, as in the app.
  const [turning, setTurning] = useState(pending);
  useEffect(() => {
    if (pending) setTurning(true);
  }, [pending]);
  return (
    <Button
      className="button icon-button sync-button"
      aria-label={t({ id: "syncNow" })}
      isPending={pending}
      onPress={() => {
        setAsked(true);
        void callCore("syncNow", vault ? { vault } : {}).finally(() => setAsked(false));
      }}
    >
      <span
        className="sync-button-arrows"
        data-turning={turning || undefined}
        onAnimationIteration={() => {
          if (!pending) setTurning(false);
        }}
      >
        <Icon src={syncIcon} />
      </span>
    </Button>
  );
}
