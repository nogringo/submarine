import { type FormEvent, type ReactNode, useEffect, useRef, useState } from "react";
import { Dialog, DialogTrigger, Form, Heading, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, TextButton } from "@/components/Button";
import { SettingsLinkTile, SettingsSection, SettingsTile } from "@/components/SettingsSection";
import { TextField } from "@/components/TextField";
import { CoreError, callCore, type MailListName, type MailSettings } from "@/lib/core";
import { mailListTexts } from "./MailList";

const lists: MailListName[] = ["inbox", "address", "servers"];

const host = (url: string) => url.replace(/^(wss|https):\/\//, "");

/**
 * The email settings of this device, for the new email addresses, as in the app. Each list opens on
 * a page of its own, `covered` meanwhile, and gives the focus back to its row once back.
 */
export function MailSettingsSection({
  covered,
  onOpenList,
}: {
  covered: boolean;
  onOpenList: (list: MailListName) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [settings, setSettings] = useState<MailSettings>();
  const read = () => void callCore("mailSettings", {}).then(setSettings);
  const rows = useRef(new Map<MailListName, HTMLButtonElement>());
  const openedList = useRef<MailListName>(undefined);
  // biome-ignore lint/correctness/useExhaustiveDependencies: read again once back from a list, maybe saved there.
  useEffect(() => {
    if (covered) return;
    read();
    if (openedList.current) rows.current.get(openedList.current)?.focus();
  }, [covered]);
  if (!settings) return null;
  return (
    <SettingsSection title={t({ id: "emailSettings" })}>
      <SettingsTile
        title={t({ id: "mailBridge" })}
        description={t({ id: "mailBridgeDescription" }, { domain: settings.bridge })}
      >
        <DialogTrigger>
          <TextButton>{t({ id: "changeMailBridge" })}</TextButton>
          <MailDialog>
            {(done) => (
              <BridgeForm
                settings={settings}
                onSaved={() => {
                  read();
                  done();
                }}
              />
            )}
          </MailDialog>
        </DialogTrigger>
      </SettingsTile>
      {lists.map((list) => (
        <SettingsLinkTile
          key={list}
          ref={(row) => {
            if (row) rows.current.set(list, row);
            return () => {
              rows.current.delete(list);
            };
          }}
          title={t({ id: mailListTexts[list].title })}
          description={settings[list].urls.map(host).join(", ")}
          onPress={() => {
            openedList.current = list;
            onOpenList(list);
          }}
        />
      ))}
    </SettingsSection>
  );
}

/** Opened by a DialogTrigger, its form mounted while it is open: what is typed goes once closed. */
function MailDialog({ children }: { children: (close: () => void) => ReactNode }) {
  return (
    <ModalOverlay className="dialog-overlay" isDismissable>
      <Modal className="dialog-modal">
        <Dialog className="dialog">{({ close }) => children(close)}</Dialog>
      </Modal>
    </ModalOverlay>
  );
}

function BridgeForm({ settings, onSaved }: { settings: MailSettings; onSaved: () => void }) {
  const { formatMessage: t } = useIntl();
  const [text, setText] = useState(settings.bridge);
  const [error, setError] = useState<string>();

  async function submit(event: FormEvent) {
    event.preventDefault();
    try {
      // Left empty for the default bridge, which the field shows as its placeholder.
      await callCore("setMailBridge", { text: text.trim() ? text : settings.defaultBridge });
      onSaved();
    } catch (error) {
      if (!(error instanceof CoreError && error.code === "invalidBridge")) throw error;
      setError(t({ id: "mailBridgeInvalid" }));
    }
  }

  return (
    <Form onSubmit={(event) => void submit(event)} validationBehavior="aria">
      <Heading slot="title" className="dialog-title">
        {t({ id: "mailBridge" })}
      </Heading>
      <p className="dialog-content">{t({ id: "mailBridgeExplanation" })}</p>
      <div className="dialog-fields">
        <TextField
          name="domain"
          type="url"
          label={t({ id: "mailBridgeDomain" })}
          placeholder={settings.defaultBridge}
          floatingLabel
          error={error}
          value={text}
          onChange={setText}
          autoFocus
        />
      </div>
      <div className="dialog-actions">
        <TextButton slot="close">{t({ id: "cancel" })}</TextButton>
        <FilledButton type="submit">{t({ id: "save" })}</FilledButton>
      </div>
    </Form>
  );
}
