import { useEffect, useState } from "react";
import { DialogTrigger } from "react-aria-components";
import { type IntlShape, useIntl } from "react-intl";
import { TextButton } from "@/components/Button";
import { SetLockPasswordDialog } from "@/components/LockPasswordDialog";
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
  return (
    <Page className="settings" onBack={onBack}>
      <div className="page-content">
        <PageHeader title={t({ id: "settings" })} />
        <SettingsSection title={t({ id: "security" })}>
          <SettingsTile
            title={t({ id: "lockPassword" })}
            description={t({ id: "lockPasswordDescription" })}
          >
            {!hasLockPassword && (
              <DialogTrigger>
                <TextButton>{t({ id: "setLockPassword" })}</TextButton>
                <SetLockPasswordDialog />
              </DialogTrigger>
            )}
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
