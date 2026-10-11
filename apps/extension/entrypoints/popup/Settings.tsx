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
  useEffect(() => {
    void readClipboardTimeout().then(setClipboardTimeout);
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

function clipboardTimeoutLabel(timeout: ClipboardTimeout, { formatMessage: t }: IntlShape) {
  const delay = clipboardTimeouts[timeout];
  if (delay === null) return t({ id: "never" });
  if (delay >= 60_000) return t({ id: "minutes" }, { count: delay / 60_000 });
  return t({ id: "seconds" }, { count: delay / 1000 });
}
