import addCircle from "@material-design-icons/svg/round/add_circle_outline.svg";
import close from "@material-design-icons/svg/round/close.svg";
import removeCircle from "@material-design-icons/svg/round/remove_circle_outline.svg";
import undo from "@material-design-icons/svg/round/undo.svg";
import { useEffect, useState } from "react";
import { useIntl } from "react-intl";
import {
  AddAddressRow,
  AddressListFooter,
  AddressTile,
  addressIcons,
} from "@/components/AddressList";
import { FilledButton, IconButton, TextButton } from "@/components/Button";
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

/** What the page of a list says, of relays or of servers. */
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

const sameUrls = (a: string[], b: string[]) =>
  a.length === b.length && a.every((url, i) => url === b[i]);

/**
 * The page of a list of the email settings, for the new email addresses. Keeps the changes in a
 * draft, saved on Save, as the vault's lists.
 */
export function MailListPage({ list, onBack }: { list: MailListName; onBack: () => void }) {
  const { formatMessage: t } = useIntl();
  const text = mailListTexts[list];
  const kind = list === "servers" ? "servers" : "relays";
  const [saved, setSaved] = useState<{ urls: string[]; defaults: string[] }>();
  const [removed, setRemoved] = useState<string[]>([]);
  const [added, setAdded] = useState<string[]>([]);
  useEffect(() => {
    void callCore("mailSettings", {}).then((settings) => setSaved(settings[list]));
  }, [list]);
  const listed = saved?.urls ?? [];
  const draft = [...listed.filter((url) => !removed.includes(url)), ...added];
  const changed = removed.length > 0 || added.length > 0;
  const empty = draft.length === 0;

  function discard() {
    setRemoved([]);
    setAdded([]);
  }

  function reset() {
    const defaults = saved?.defaults ?? [];
    setRemoved(listed.filter((url) => !defaults.includes(url)));
    setAdded(defaults.filter((url) => !listed.includes(url)));
  }

  async function save() {
    await callCore("setMailList", { list, urls: draft });
    setSaved({ urls: draft, defaults: saved?.defaults ?? [] });
    discard();
  }

  return (
    <Page className="mail-list" onBack={onBack}>
      <div className="page-content">
        <PageHeader title={t({ id: text.title })} />
        <p className="address-list-description">{t({ id: text.explanation })}</p>
        {saved && (
          <div className="field-card">
            {listed.map((url) =>
              removed.includes(url) ? (
                <AddressTile
                  key={url}
                  url={url}
                  icon={addressIcons[kind]}
                  status={{ text: t({ id: text.removed }), icon: removeCircle }}
                  removed
                >
                  <IconButton
                    icon={undo}
                    iconSize={20}
                    label={t({ id: text.keep })}
                    onPress={() => setRemoved(removed.filter((each) => each !== url))}
                  />
                </AddressTile>
              ) : (
                <AddressTile key={url} url={url} icon={addressIcons[kind]}>
                  <IconButton
                    icon={close}
                    iconSize={20}
                    label={t({ id: text.remove })}
                    onPress={() => setRemoved([...removed, url])}
                  />
                </AddressTile>
              ),
            )}
            {added.map((url) => (
              <AddressTile
                key={url}
                url={url}
                icon={addressIcons[kind]}
                status={{ text: t({ id: text.added }), icon: addCircle }}
              >
                <IconButton
                  icon={close}
                  iconSize={20}
                  label={t({ id: text.remove })}
                  onPress={() => setAdded(added.filter((each) => each !== url))}
                />
              </AddressTile>
            ))}
            <AddAddressRow
              list={kind}
              texts={text}
              draft={draft}
              onAdd={({ url }) =>
                // Taken back from the removed ones rather than added twice.
                listed.includes(url)
                  ? setRemoved(removed.filter((each) => each !== url))
                  : setAdded([...added, url])
              }
            />
          </div>
        )}
      </div>
      <AddressListFooter message={empty ? t({ id: text.needOne }) : undefined}>
        <TextButton isDisabled={!saved || sameUrls(draft, saved.defaults)} onPress={reset}>
          {t({ id: "resetMailRelays" })}
        </TextButton>
        <TextButton isDisabled={!changed} onPress={discard}>
          {t({ id: "cancel" })}
        </TextButton>
        <FilledButton isDisabled={!changed || empty} onPress={() => void save()}>
          {t({ id: "save" })}
        </FilledButton>
      </AddressListFooter>
    </Page>
  );
}
