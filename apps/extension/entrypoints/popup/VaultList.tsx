import circle from "@material-design-icons/svg/outlined/circle.svg";
import checkCircle from "@material-design-icons/svg/round/check_circle_outline.svg";
import { useIntl } from "react-intl";
import { AddressList } from "@/components/AddressList";
import { Page, PageHeader } from "@/components/Page";
import { VaultAvatar } from "@/components/VaultAvatar";
import { callCore, type Vault, type VaultListName } from "@/lib/core";
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
  const addresses = lists?.[list];
  const connected = new Set(
    lists?.relays.filter((relay) => relay.connected).map((relay) => relay.url),
  );
  const urls = (isPrivate: boolean) =>
    (addresses ?? []).filter((address) => address.private === isPrivate).map(({ url }) => url);
  return (
    <Page className="vault-list" onBack={onBack}>
      <AddressList
        header={
          <>
            <PageHeader
              mark={<VaultAvatar vault={vault} size={56} />}
              title={t({ id: text.title })}
            >
              <p className="vault-list-subtitle">{vault.name}</p>
            </PageHeader>
            <p className="address-list-description">{t({ id: text.description })}</p>
          </>
        }
        list={list}
        texts={text}
        listed={addresses && { public: urls(false), private: urls(true) }}
        editable={!!lists?.editable}
        status={(url) =>
          list === "relays"
            ? connected.has(url)
              ? { text: t({ id: "relayConnected" }), icon: checkCircle }
              : { text: t({ id: "relayNotConnected" }), icon: circle }
            : undefined
        }
        problem={(url) => {
          const reason = list === "relays" ? leftOut?.[url] : undefined;
          return reason && t({ id: "relayLeftOut" }, { reason });
        }}
        save={async (lists) => {
          const args = { vault: vault.pubkey, ...lists };
          if (list === "relays") await callCore("setRelays", args);
          else await callCore("setServers", args);
        }}
      />
    </Page>
  );
}
