import circle from "@material-design-icons/svg/outlined/circle.svg";
import addCircle from "@material-design-icons/svg/round/add_circle_outline.svg";
import checkCircle from "@material-design-icons/svg/round/check_circle_outline.svg";
import close from "@material-design-icons/svg/round/close.svg";
import removeCircle from "@material-design-icons/svg/round/remove_circle_outline.svg";
import undo from "@material-design-icons/svg/round/undo.svg";
import { useState } from "react";
import { useIntl } from "react-intl";
import {
  AddAddressRow,
  AddressListFooter,
  AddressTile,
  addressIcons,
} from "@/components/AddressList";
import { FilledButton, IconButton, TextButton } from "@/components/Button";
import { Page, PageHeader } from "@/components/Page";
import { VaultAvatar } from "@/components/VaultAvatar";
import { callCore, type Vault, type VaultAddress, type VaultListName } from "@/lib/core";
import type { Sync } from "@/lib/use-sync";
import { useVaultLists } from "@/lib/use-vault-lists";
import "./VaultList.css";

type MessageId = FormatjsIntl.Message["ids"];

/** What the page of a list says, of relays or of servers. */
const texts = {
  relays: {
    title: "relays",
    description: "relaysDescription",
    add: "addRelay",
    address: "relayAddress",
    invalid: "relayAddressInvalid",
    alreadyListed: "relayAlreadyListed",
    remove: "removeRelay",
    keep: "keepRelay",
    private: "relayPrivate",
    added: "relayAdded",
    removed: "relayRemoved",
    keepPrivate: "relayKeepPrivate",
    keepPrivateDescription: "relayKeepPrivateDescription",
    saveFailed: "relaysSaveFailed",
    waitForSync: "relaysWaitForSync",
    needOne: "relaysNeedOne",
  },
  servers: {
    title: "fileServers",
    description: "fileServersDescription",
    add: "addServer",
    address: "serverAddress",
    invalid: "serverAddressInvalid",
    alreadyListed: "serverAlreadyListed",
    remove: "removeServer",
    keep: "keepServer",
    private: "serverPrivate",
    added: "serverAdded",
    removed: "serverRemoved",
    keepPrivate: "serverKeepPrivate",
    keepPrivateDescription: "serverKeepPrivateDescription",
    saveFailed: "serversSaveFailed",
    waitForSync: "serversWaitForSync",
    needOne: "serversNeedOne",
  },
} as const satisfies Record<VaultListName, Record<string, MessageId>>;

/**
 * The page of the relays or the servers of `vault`, public or private, as in the app. Keeps the
 * changes in a draft, published as a single list on Save.
 */
export function VaultListPage({
  vault,
  list,
  sync,
  onBack,
}: {
  vault: Vault;
  list: VaultListName;
  sync: Sync;
  onBack: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const lists = useVaultLists(vault.pubkey, sync.revision);
  const leftOut = sync.states.find((state) => state.pubkey === vault.pubkey)?.leftOut;
  const text = texts[list];
  const [removed, setRemoved] = useState<string[]>([]);
  const [added, setAdded] = useState<VaultAddress[]>([]);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState<string>();
  const listed: (VaultAddress & { connected?: boolean })[] = lists?.[list] ?? [];
  const changed = removed.length > 0 || added.length > 0;
  const editable = !!lists?.editable && !saving;
  const draft = (isPrivate: boolean) => [
    ...listed
      .filter((address) => address.private === isPrivate && !removed.includes(address.url))
      .map((address) => address.url),
    ...added.filter((address) => address.private === isPrivate).map((address) => address.url),
  ];
  const publicDraft = draft(false);
  const privateDraft = draft(true);
  const empty = publicDraft.length === 0 && privateDraft.length === 0;
  const message =
    saveError ??
    (lists && !lists.editable
      ? t({ id: text.waitForSync })
      : empty
        ? t({ id: text.needOne })
        : undefined);

  function discard() {
    setRemoved([]);
    setAdded([]);
    setSaveError(undefined);
  }

  async function save() {
    setSaving(true);
    setSaveError(undefined);
    try {
      const args = { vault: vault.pubkey, public: publicDraft, private: privateDraft };
      if (list === "relays") await callCore("setRelays", args);
      else await callCore("setServers", args);
      setRemoved([]);
      setAdded([]);
    } catch {
      setSaveError(t({ id: text.saveFailed }));
    } finally {
      setSaving(false);
    }
  }

  const status = (address: VaultAddress & { connected?: boolean }) =>
    list === "relays"
      ? address.connected
        ? { text: t({ id: "relayConnected" }), icon: checkCircle }
        : { text: t({ id: "relayNotConnected" }), icon: circle }
      : undefined;
  return (
    <Page className="vault-list" onBack={onBack}>
      <div className="page-content">
        <PageHeader mark={<VaultAvatar vault={vault} size={56} />} title={t({ id: text.title })}>
          <p className="vault-list-subtitle">{vault.name}</p>
        </PageHeader>
        <p className="address-list-description">{t({ id: text.description })}</p>
        {lists && (
          <div className="field-card vault-list-card">
            {listed.map((address) => {
              const note = address.private ? t({ id: text.private }) : undefined;
              const reason = list === "relays" ? leftOut?.[address.url] : undefined;
              return removed.includes(address.url) ? (
                <AddressTile
                  key={address.url}
                  url={address.url}
                  icon={addressIcons[list]}
                  note={note}
                  status={{ text: t({ id: text.removed }), icon: removeCircle }}
                  removed
                >
                  <IconButton
                    icon={undo}
                    iconSize={20}
                    label={t({ id: text.keep })}
                    isDisabled={!editable}
                    onPress={() => setRemoved(removed.filter((url) => url !== address.url))}
                  />
                </AddressTile>
              ) : (
                <AddressTile
                  key={address.url}
                  url={address.url}
                  icon={addressIcons[list]}
                  note={note}
                  status={status(address)}
                  problem={reason && t({ id: "relayLeftOut" }, { reason })}
                >
                  <IconButton
                    icon={close}
                    iconSize={20}
                    label={t({ id: text.remove })}
                    isDisabled={!editable}
                    onPress={() => setRemoved([...removed, address.url])}
                  />
                </AddressTile>
              );
            })}
            {added.map((address) => (
              <AddressTile
                key={address.url}
                url={address.url}
                icon={addressIcons[list]}
                note={address.private ? t({ id: text.private }) : undefined}
                status={{ text: t({ id: text.added }), icon: addCircle }}
              >
                <IconButton
                  icon={close}
                  iconSize={20}
                  label={t({ id: text.remove })}
                  isDisabled={!editable}
                  onPress={() => setAdded(added.filter((each) => each.url !== address.url))}
                />
              </AddressTile>
            ))}
            <AddAddressRow
              list={list}
              texts={text}
              draft={[...publicDraft, ...privateDraft]}
              isDisabled={!editable}
              onAdd={(address) => setAdded([...added, address])}
            />
          </div>
        )}
      </div>
      <AddressListFooter message={message} isError={!!saveError}>
        <TextButton isDisabled={!changed || saving} onPress={discard}>
          {t({ id: "cancel" })}
        </TextButton>
        <FilledButton
          isDisabled={!changed || !editable || empty}
          isPending={saving}
          onPress={() => void save()}
        >
          {t({ id: "save" })}
        </FilledButton>
      </AddressListFooter>
    </Page>
  );
}
