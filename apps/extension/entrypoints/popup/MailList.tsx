import { useEffect, useState } from "react";
import { useIntl } from "react-intl";
import { AddressList } from "@/components/AddressList";
import { Page, PageHeader } from "@/components/Page";
import { callCore, type MailListName } from "@/lib/core";

type MessageId = FormatjsIntl.Message["ids"];

const relayTexts = {
  needOne: "mailRelaysNeedOne",
  add: "addRelay",
  address: "relayAddress",
  invalid: "relayAddressInvalid",
  alreadyListed: "relayAlreadyListed",
  remove: "removeRelay",
  keep: "keepRelay",
  added: "relayAdded",
  removed: "relayRemoved",
} as const satisfies Record<string, MessageId>;

export const mailListTexts = {
  inbox: { ...relayTexts, title: "mailInboxRelays", explanation: "mailInboxRelaysExplanation" },
  address: {
    ...relayTexts,
    title: "mailAddressRelays",
    explanation: "mailAddressRelaysExplanation",
  },
  servers: {
    title: "mailServers",
    explanation: "mailServersExplanation",
    needOne: "mailServersNeedOne",
    add: "addServer",
    address: "serverAddress",
    invalid: "serverAddressInvalid",
    alreadyListed: "serverAlreadyListed",
    remove: "removeServer",
    keep: "keepServer",
    added: "serverAdded",
    removed: "serverRemoved",
  },
} as const satisfies Record<MailListName, Record<string, MessageId>>;

/**
 * The page of a list of the email settings, for the new email addresses. Keeps the changes in a
 * draft, saved on Save, as the vault's lists.
 */
export function MailListPage({ list, onBack }: { list: MailListName; onBack: () => void }) {
  const { formatMessage: t } = useIntl();
  const text = mailListTexts[list];
  const [saved, setSaved] = useState<{ urls: string[]; defaults: string[] }>();
  useEffect(() => {
    void callCore("mailSettings", {}).then((settings) => setSaved(settings[list]));
  }, [list]);
  return (
    <Page className="mail-list" onBack={onBack}>
      <AddressList
        header={
          <>
            <PageHeader title={t({ id: text.title })} />
            <p className="address-list-description">{t({ id: text.explanation })}</p>
          </>
        }
        list={list === "servers" ? "servers" : "relays"}
        texts={text}
        listed={saved && { public: saved.urls, private: [] }}
        defaults={saved?.defaults}
        save={async ({ public: urls }) => {
          await callCore("setMailList", { list, urls });
          setSaved({ urls, defaults: saved?.defaults ?? [] });
        }}
      />
    </Page>
  );
}
