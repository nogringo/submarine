import chatBubble from "@material-design-icons/svg/round/chat_bubble_outline.svg";
import mailOutline from "@material-design-icons/svg/round/mail_outline.svg";
import { npubEncode } from "nostr-tools/nip19";
import { useEffect, useState } from "react";
import { Button } from "react-aria-components";
import { type IntlShape, useIntl } from "react-intl";
import { Icon } from "@/components/Icon";
import { SyncArrows } from "@/components/SyncButton";
import { callCore, type MailMessage } from "@/lib/core";
import { dayFormat, timeFormat } from "@/lib/i18n";
import { MessageSheet } from "./MessageSheet";
import "./Inbox.css";

/**
 * The emails and private messages of the mailbox of an item, its key an nsec, synced while it shows,
 * as in the app. Read again each time `revision` goes up. A message opens in a sheet.
 */
export function Inbox({
  mailboxKey,
  title,
  revision,
}: {
  mailboxKey: string;
  title: string;
  revision: number;
}) {
  const intl = useIntl();
  const { formatMessage: t } = intl;
  const [messages, setMessages] = useState<MailMessage[]>([]);
  const [syncing, setSyncing] = useState(true);
  const [opened, setOpened] = useState<MailMessage>();
  const sync = () => {
    setSyncing(true);
    void callCore("syncInbox", { key: mailboxKey }).finally(() => setSyncing(false));
  };
  // biome-ignore lint/correctness/useExhaustiveDependencies: synced once per mailbox shown.
  useEffect(() => {
    sync();
    return () => void callCore("closeInbox", { key: mailboxKey });
  }, [mailboxKey]);
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(() => {
    let current = true;
    void callCore("inbox", { key: mailboxKey }).then((messages) => {
      if (current) setMessages(messages);
    });
    return () => {
      current = false;
    };
  }, [mailboxKey, revision]);
  return (
    <section className="inbox">
      <div className="inbox-header">
        <h2 className="item-detail-section-title">{title}</h2>
        <Button
          className="button icon-button"
          aria-label={t({ id: "refreshInbox" })}
          isPending={syncing}
          onPress={sync}
        >
          <SyncArrows turning={syncing} size={20} refresh />
        </Button>
      </div>
      <div className="field-card">
        {messages.length === 0 ? (
          <p className="inbox-empty">{t({ id: syncing ? "inboxFetching" : "inboxEmpty" })}</p>
        ) : (
          <ul className="inbox-messages">
            {messages.map((message) => (
              <MessageRow
                key={message.wrapId}
                message={message}
                intl={intl}
                onPress={() => setOpened(message)}
              />
            ))}
          </ul>
        )}
      </div>
      {opened && (
        <MessageSheet
          mailboxKey={mailboxKey}
          message={opened}
          onClose={() => setOpened(undefined)}
        />
      )}
    </section>
  );
}

function MessageRow({
  message,
  intl,
  onPress,
}: {
  message: MailMessage;
  intl: IntlShape;
  onPress: () => void;
}) {
  const { formatMessage: t } = intl;
  const [icon, kind, sender, summary] =
    message.kind === "email"
      ? [mailOutline, t({ id: "email" }), message.fromName ?? message.from, message.subject]
      : [
          chatBubble,
          t({ id: "privateMessage" }),
          shortNpub(message.pubkey),
          message.text.trim().split("\n")[0] ?? "",
        ];
  return (
    <li className="inbox-item">
      <Button className="inbox-message" onPress={onPress}>
        <span role="img" aria-label={kind} title={kind}>
          <Icon src={icon} />
        </span>
        <span className="inbox-message-text">
          <span className="inbox-message-top">
            <span className={message.kind === "email" ? "inbox-sender" : "inbox-sender mono"}>
              {sender}
            </span>
            <span className="inbox-date">{formatDate(message.date, intl)}</span>
          </span>
          <span className="inbox-summary">
            {message.kind === "email" && !summary ? t({ id: "noSubject" }) : summary}
          </span>
        </span>
      </Button>
    </li>
  );
}

/** Its start and its end, which tell two keys apart, as a whole npub fills the line. */
function shortNpub(pubkey: string) {
  const npub = npubEncode(pubkey);
  return `${npub.slice(0, 12)}...${npub.slice(-6)}`;
}

/** The time for today's messages, the date for older ones. */
function formatDate(date: number, intl: IntlShape) {
  const today = new Date(date).toDateString() === new Date().toDateString();
  return today ? intl.formatTime(date, timeFormat) : intl.formatDate(date, dayFormat);
}
