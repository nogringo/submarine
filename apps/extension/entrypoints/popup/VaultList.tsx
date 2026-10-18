import circle from "@material-design-icons/svg/outlined/circle.svg";
import add from "@material-design-icons/svg/round/add.svg";
import addCircle from "@material-design-icons/svg/round/add_circle_outline.svg";
import cellTower from "@material-design-icons/svg/round/cell_tower.svg";
import checkCircle from "@material-design-icons/svg/round/check_circle_outline.svg";
import close from "@material-design-icons/svg/round/close.svg";
import dns from "@material-design-icons/svg/round/dns.svg";
import removeCircle from "@material-design-icons/svg/round/remove_circle_outline.svg";
import undo from "@material-design-icons/svg/round/undo.svg";
import { type FormEvent, type ReactNode, useState } from "react";
import {
  Button,
  Dialog,
  DialogTrigger,
  Form,
  Heading,
  Modal,
  ModalOverlay,
} from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, IconButton, TextButton } from "@/components/Button";
import { Icon } from "@/components/Icon";
import { Page, PageHeader } from "@/components/Page";
import { TextField } from "@/components/TextField";
import { SwitchTile } from "@/components/ToggleTile";
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

type Texts = (typeof texts)[VaultListName];

const icons = { relays: cellTower, servers: dns };
const hints = { relays: "wss://relay.example.com", servers: "https://blossom.example.com" };

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
        <p className="vault-list-description">{t({ id: text.description })}</p>
        {lists && (
          <div className="field-card vault-list-card">
            {listed.map((address) => {
              const note = address.private ? t({ id: text.private }) : undefined;
              const reason = list === "relays" ? leftOut?.[address.url] : undefined;
              return removed.includes(address.url) ? (
                <AddressTile
                  key={address.url}
                  url={address.url}
                  icon={icons[list]}
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
                  icon={icons[list]}
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
                icon={icons[list]}
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
            <DialogTrigger>
              <Button className="settings-tile vault-list-add" isDisabled={!editable}>
                <Icon src={add} size={20} />
                <span className="settings-tile-title">{t({ id: text.add })}</span>
              </Button>
              <AddAddressDialog
                list={list}
                texts={text}
                draft={[...publicDraft, ...privateDraft]}
                onAdd={(address) => setAdded([...added, address])}
              />
            </DialogTrigger>
          </div>
        )}
      </div>
      <footer className="vault-list-footer">
        {/* Next to the buttons it explains, wherever the list scrolled. */}
        {message && (
          <p className={saveError ? "vault-list-message error" : "vault-list-message"}>{message}</p>
        )}
        <div className="vault-list-actions">
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
        </div>
      </footer>
    </Page>
  );
}

/** The draft shows in `status`, so that the row keeps its height. */
function AddressTile({
  url,
  icon,
  note,
  status,
  problem,
  removed,
  children,
}: {
  url: string;
  icon: string;
  /** Under the address, that it is private. */
  note?: string;
  status?: { text: string; icon: string };
  /** Under the address and `note`. */
  problem?: string;
  removed?: boolean;
  children: ReactNode;
}) {
  return (
    <div className="settings-tile address-tile" data-removed={removed || undefined}>
      <Icon src={icon} size={20} />
      <span className="settings-tile-text">
        <span className="address-tile-url">{url.replace(/^(wss|https):\/\//, "")}</span>
        {note && <span className="settings-tile-description">{note}</span>}
        {problem && <span className="settings-tile-description error">{problem}</span>}
      </span>
      {/* A tooltip in the popup, as in the narrow layout of the app. */}
      {status && (
        <span
          className="address-tile-status"
          role="img"
          aria-label={status.text}
          title={status.text}
        >
          <Icon src={status.icon} size={16} />
        </span>
      )}
      {children}
    </div>
  );
}

/** Gives the address to add, and whether it is private. Opened by a DialogTrigger. */
function AddAddressDialog({
  list,
  texts,
  draft,
  onAdd,
}: {
  list: VaultListName;
  texts: Texts;
  /** The addresses the draft lists. */
  draft: string[];
  onAdd: (address: VaultAddress) => void;
}) {
  return (
    <ModalOverlay className="dialog-overlay" isDismissable>
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          {({ close }) => (
            <AddAddressForm
              list={list}
              texts={texts}
              draft={draft}
              onAdd={(address) => {
                onAdd(address);
                close();
              }}
            />
          )}
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}

/** Mounted while the dialog is open: the address typed goes once it closes. */
function AddAddressForm({
  list,
  texts,
  draft,
  onAdd,
}: {
  list: VaultListName;
  texts: Texts;
  draft: string[];
  onAdd: (address: VaultAddress) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [text, setText] = useState("");
  const [isPrivate, setPrivate] = useState(false);
  const [error, setError] = useState<string>();
  const parse = async (text: string) => await callCore("parseAddress", { list, text });

  async function submit(event: FormEvent) {
    event.preventDefault();
    const url = await parse(text);
    if (!url) {
      setError(t({ id: texts.invalid }));
      return;
    }
    const listed = await Promise.all(draft.map(async (listed) => (await parse(listed)) ?? listed));
    if (listed.includes(url)) {
      setError(t({ id: texts.alreadyListed }));
      return;
    }
    onAdd({ url, private: isPrivate });
  }

  return (
    <Form onSubmit={(event) => void submit(event)} validationBehavior="aria">
      <Heading slot="title" className="dialog-title">
        {t({ id: texts.add })}
      </Heading>
      <div className="dialog-fields">
        <TextField
          name="address"
          type="url"
          label={t({ id: texts.address })}
          placeholder={hints[list]}
          floatingLabel
          error={error}
          value={text}
          onChange={setText}
          autoFocus
        />
        <SwitchTile
          label={t({ id: texts.keepPrivate })}
          description={t({ id: texts.keepPrivateDescription })}
          isSelected={isPrivate}
          onChange={setPrivate}
        />
      </div>
      <div className="dialog-actions">
        <TextButton slot="close">{t({ id: "cancel" })}</TextButton>
        <FilledButton type="submit">{t({ id: "add" })}</FilledButton>
      </div>
    </Form>
  );
}
