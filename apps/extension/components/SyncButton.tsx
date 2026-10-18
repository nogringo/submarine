import syncIcon from "@material-design-icons/svg/round/sync.svg";
import { useEffect, useState } from "react";
import { Button } from "react-aria-components";
import { useIntl } from "react-intl";
import { callCore } from "@/lib/core";
import { Icon } from "./Icon";
import "./SyncButton.css";

/**
 * Syncs `vault`, or every vault without one, at once. Its arrows turn from the press until the core
 * answers and while `syncing`, and it waits meanwhile, keeping the focus. Outlined and labelled
 * with `labelled`, as in the vault settings.
 */
export function SyncButton({
  vault,
  syncing,
  labelled,
}: {
  vault?: string;
  syncing: boolean;
  labelled?: boolean;
}) {
  const { formatMessage: t } = useIntl();
  // The core tells a phase once it read the vault again: a quick sync ends before it says so.
  const [asked, setAsked] = useState(false);
  const pending = syncing || asked;
  return (
    <Button
      className={labelled ? "button outlined sync-button" : "button icon-button sync-button"}
      aria-label={labelled ? undefined : t({ id: "syncNow" })}
      isPending={pending}
      onPress={() => {
        setAsked(true);
        void callCore("syncNow", vault ? { vault } : {}).finally(() => setAsked(false));
      }}
    >
      <SyncArrows turning={pending} size={labelled ? 18 : undefined} />
      {labelled && t({ id: "syncNow" })}
    </Button>
  );
}

/** Arrows that turn while `turning`, and end their turn rather than stop askew, as in the app. */
export function SyncArrows({ turning, size }: { turning: boolean; size?: number }) {
  const [shown, setShown] = useState(turning);
  useEffect(() => {
    if (turning) setShown(true);
  }, [turning]);
  return (
    <span
      className="sync-button-arrows"
      data-turning={shown || undefined}
      onAnimationIteration={() => {
        if (!turning) setShown(false);
      }}
    >
      <Icon src={syncIcon} size={size} />
    </span>
  );
}
