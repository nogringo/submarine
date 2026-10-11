import { useEffect, useRef, useState } from "react";
import { DialogTrigger } from "react-aria-components";
import { type IntlShape, useIntl } from "react-intl";
import { TextButton } from "@/components/Button";
import { type LockPasswordChange, LockPasswordDialog } from "@/components/LockPasswordDialog";
import { Page, PageHeader } from "@/components/Page";
import { SelectTile } from "@/components/SelectTile";
import { SettingsSection, SettingsTile } from "@/components/SettingsSection";
import {
  type ClipboardTimeout,
  clipboardTimeouts,
  readClipboardTimeout,
  saveClipboardTimeout,
} from "@/lib/clipboard";
import { callCore, type LockTimeout, lockTimeouts } from "@/lib/core";
import "./Settings.css";

/** The settings of the extension on this device, as in the app. */
export function Settings({
  hasLockPassword,
  onBack,
}: {
  hasLockPassword: boolean;
  onBack: () => void;
}) {
  const intl = useIntl();
  const { formatMessage: t } = intl;
  const [clipboardTimeout, setClipboardTimeout] = useState<ClipboardTimeout>();
  const [lockTimeout, setLockTimeout] = useState<LockTimeout>();
  useEffect(() => {
    void readClipboardTimeout().then(setClipboardTimeout);
    void callCore("lockTimeout", {}).then(setLockTimeout);
  }, []);
  const lockPasswordActions = useRef<HTMLDivElement>(null);
  const hadLockPassword = useRef(hasLockPassword);
  useEffect(() => {
    // The button pressed went with the password set or removed: the one in its place gets the focus.
    if (hadLockPassword.current !== hasLockPassword) {
      lockPasswordActions.current?.querySelector("button")?.focus();
    }
    hadLockPassword.current = hasLockPassword;
  }, [hasLockPassword]);
  const lockPasswordButton = (change: LockPasswordChange, label: string) => (
    <DialogTrigger>
      <TextButton>{label}</TextButton>
      <LockPasswordDialog change={change} />
    </DialogTrigger>
  );
  return (
    <Page className="settings" onBack={onBack}>
      <div className="page-content">
        <PageHeader title={t({ id: "settings" })} />
        <SettingsSection title={t({ id: "security" })}>
          <SettingsTile
            title={t({ id: "lockPassword" })}
            description={t({ id: "lockPasswordDescription" })}
          >
            <div ref={lockPasswordActions} className="settings-lock-password-actions">
              {hasLockPassword ? (
                <>
                  {lockPasswordButton("change", t({ id: "changeLockPassword" }))}
                  {lockPasswordButton("remove", t({ id: "removeLockPassword" }))}
                </>
              ) : (
                lockPasswordButton("set", t({ id: "setLockPassword" }))
              )}
            </div>
          </SettingsTile>
          {hasLockPassword && lockTimeout && (
            <SelectTile
              title={t({ id: "lockAfter" })}
              value={lockTimeout}
              options={lockTimeouts.map((id) => ({ id, label: lockTimeoutLabel(id, intl) }))}
              onChange={(timeout) => {
                setLockTimeout(timeout);
                void callCore("setLockTimeout", { timeout });
              }}
            />
          )}
          {clipboardTimeout && (
            <SelectTile
              title={t({ id: "clearClipboardAfter" })}
              value={clipboardTimeout}
              options={Object.keys(clipboardTimeouts).map((id) => ({
                id: id as ClipboardTimeout,
                label: clipboardTimeoutLabel(id as ClipboardTimeout, intl),
              }))}
              onChange={(timeout) => {
                setClipboardTimeout(timeout);
                void saveClipboardTimeout(timeout);
              }}
            />
          )}
        </SettingsSection>
      </div>
    </Page>
  );
}

function lockTimeoutLabel(timeout: LockTimeout, { formatMessage: t }: IntlShape) {
  switch (timeout) {
    case "immediately":
      return t({ id: "lockImmediately" });
    case "oneMinute":
      return t({ id: "minutes" }, { count: 1 });
    case "fiveMinutes":
      return t({ id: "minutes" }, { count: 5 });
    case "fifteenMinutes":
      return t({ id: "minutes" }, { count: 15 });
    case "thirtyMinutes":
      return t({ id: "minutes" }, { count: 30 });
    case "oneHour":
      return t({ id: "hours" }, { count: 1 });
    case "fourHours":
      return t({ id: "hours" }, { count: 4 });
    case "onRestart":
      return t({ id: "lockOnBrowserRestart" });
  }
}

function clipboardTimeoutLabel(timeout: ClipboardTimeout, { formatMessage: t }: IntlShape) {
  const delay = clipboardTimeouts[timeout];
  if (delay === null) return t({ id: "never" });
  if (delay >= 60_000) return t({ id: "minutes" }, { count: delay / 60_000 });
  return t({ id: "seconds" }, { count: delay / 1000 });
}
