import deleteOutline from "@material-design-icons/svg/round/delete_outline.svg";
import download from "@material-design-icons/svg/round/download.svg";
import { npubEncode } from "nostr-tools/nip19";
import { useEffect, useState } from "react";
import { Dialog, Heading, Link, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, IconButton, TextButton } from "@/components/Button";
import { CopyButton } from "@/components/CopyButton";
import { ConfirmDialog } from "@/components/Dialog";
import { Sheet } from "@/components/Sheet";
import { callCore, type MailMessage } from "@/lib/core";
import { dayTimeFormat } from "@/lib/i18n";
import { emlFileName, textParts } from "@/lib/mail";
import { saveFile } from "@/lib/save-file";
import "./MessageSheet.css";

/**
 * A message of the mailbox of `mailboxKey` in a sheet, as the app shows it on a phone: an email
 * read in full, downloaded when too large for a gift wrap, saved as a `.eml` file or deleted.
 */
export function MessageSheet({
  mailboxKey,
  message,
  onClose,
}: {
  mailboxKey: string;
  message: MailMessage;
  onClose: () => void;
}) {
  const { formatMessage: t, formatDate } = useIntl();
  const [opened, setOpened] = useState<MailMessage | "failed">();
  const [attempt, setAttempt] = useState(0);
  const [confirmingDelete, setConfirmingDelete] = useState(false);
  const [deleting, setDeleting] = useState(false);
  // biome-ignore lint/correctness/useExhaustiveDependencies: attempt tells when to try again.
  useEffect(() => {
    let current = true;
    setOpened(undefined);
    void callCore("inboxMessage", { key: mailboxKey, wrapId: message.wrapId }).then(
      (opened) => current && setOpened(opened),
      () => current && setOpened("failed"),
    );
    return () => {
      current = false;
    };
  }, [mailboxKey, message.wrapId, attempt]);

  async function remove() {
    setDeleting(true);
    try {
      await callCore("deleteMessage", { key: mailboxKey, wrapId: message.wrapId });
      onClose();
    } finally {
      setDeleting(false);
    }
  }

  const email = message.kind === "email" ? message : undefined;
  const mime = opened !== "failed" && opened?.kind === "email" ? opened.mime : undefined;
  return (
    <Sheet
      title={email ? email.subject || t({ id: "noSubject" }) : t({ id: "privateMessage" })}
      isOpen
      onOpenChange={(isOpen) => !isOpen && onClose()}
      actions={
        <>
          {email && (
            <IconButton
              icon={download}
              label={t({ id: "saveEmail" })}
              isDisabled={mime === undefined}
              onPress={() => mime && saveFile(emlFileName(email.subject), mime, "message/rfc822")}
            />
          )}
          <IconButton
            icon={deleteOutline}
            label={t({ id: "delete" })}
            isDisabled={deleting}
            onPress={() => setConfirmingDelete(true)}
          />
          <ConfirmDialog
            title={t({ id: "deleteMessageTitle" })}
            cancel={t({ id: "cancel" })}
            confirm={t({ id: "delete" })}
            onConfirm={() => void remove()}
            isOpen={confirmingDelete}
            onOpenChange={setConfirmingDelete}
          >
            <p>{t({ id: "deleteMessageBody" })}</p>
          </ConfirmDialog>
        </>
      }
    >
      {() => (
        <div className="message">
          <p className="message-meta">
            {email
              ? email.fromName
                ? `${email.fromName} <${email.from}>`
                : email.from
              : npubEncode(message.pubkey)}
          </p>
          <p className="message-meta message-date">{formatDate(message.date, dayTimeFormat)}</p>
          <hr className="message-divider" />
          {opened === "failed" ? (
            <div className="message-failed">
              <p className="message-error">{t({ id: "emailDownloadFailed" })}</p>
              <TextButton onPress={() => setAttempt(attempt + 1)}>
                {t({ id: "tryAgain" })}
              </TextButton>
            </div>
          ) : opened ? (
            <LinkedText text={opened.kind === "email" ? (opened.text ?? "") : opened.text} />
          ) : (
            <div className="message-loading" aria-busy="true">
              <span className="message-spinner" />
            </div>
          )}
        </div>
      )}
    </Sheet>
  );
}

/** `text` with its web links, each opened once the user saw where it leads: anyone can send an email. */
function LinkedText({ text }: { text: string }) {
  const [asked, setAsked] = useState<URL>();
  return (
    <>
      <p className="message-text">
        {textParts(text).map(({ text, url }, index) =>
          url ? (
            // biome-ignore lint/suspicious/noArrayIndexKey: the parts of a text that never changes.
            <Link key={index} className="message-link" onPress={() => setAsked(url)}>
              {text}
            </Link>
          ) : (
            text
          ),
        )}
      </p>
      {asked && <OpenLinkDialog url={asked} onClose={() => setAsked(undefined)} />}
    </>
  );
}

function OpenLinkDialog({ url, onClose }: { url: URL; onClose: () => void }) {
  const { formatMessage: t } = useIntl();
  return (
    <ModalOverlay
      className="dialog-overlay"
      isDismissable
      isOpen
      onOpenChange={(isOpen) => !isOpen && onClose()}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          <Heading slot="title" className="dialog-title">
            {t({ id: "openLinkTitle" })}
          </Heading>
          <div className="dialog-content">
            <p className="open-link-host">{url.hostname}</p>
            <div className="open-link-url">
              <p>{url.href}</p>
              {/* A link from an email may sign in, as a reset link does. */}
              <CopyButton value={url.href} sensitive label={t({ id: "copyLink" })} />
            </div>
          </div>
          <div className="dialog-actions">
            <TextButton onPress={onClose}>{t({ id: "cancel" })}</TextButton>
            <FilledButton
              onPress={() => {
                onClose();
                void browser.tabs.create({ url: url.href });
              }}
            >
              {t({ id: "openLink" })}
            </FilledButton>
          </div>
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}
