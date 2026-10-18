import add from "@material-design-icons/svg/round/add.svg";
import addCircle from "@material-design-icons/svg/round/add_circle_outline.svg";
import close from "@material-design-icons/svg/round/close.svg";
import dragIndicator from "@material-design-icons/svg/round/drag_indicator.svg";
import removeCircle from "@material-design-icons/svg/round/remove_circle_outline.svg";
import undo from "@material-design-icons/svg/round/undo.svg";
import { type FormEvent, type ReactNode, useId, useState } from "react";
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
import {
  type AddressDraft,
  addToDraft,
  draftChanged,
  draftLists,
  draftRows,
  type Listed,
  moveInDraft,
  noChanges,
  resetDraft,
  sameUrls,
} from "@/lib/address-draft";
import { callCore, type VaultAddress, type VaultListName } from "@/lib/core";
import { useReorder } from "@/lib/use-reorder";
import { FilledButton, IconButton, TextButton } from "./Button";
import { Icon } from "./Icon";
import { TextField } from "./TextField";
import { SwitchTile } from "./ToggleTile";
import "./AddressList.css";

type MessageId = FormatjsIntl.Message["ids"];

/**
 * What an {@link AddressList} says, of relays or of servers. The texts about private addresses,
 * saving and syncing are for the lists that have them.
 */
export interface AddressListTexts {
  add: MessageId;
  address: MessageId;
  invalid: MessageId;
  alreadyListed: MessageId;
  remove: MessageId;
  keep: MessageId;
  added: MessageId;
  removed: MessageId;
  needOne: MessageId;
  private?: MessageId;
  keepPrivate?: MessageId;
  keepPrivateDescription?: MessageId;
  saveFailed?: MessageId;
  waitForSync?: MessageId;
}

const hints = { relays: "wss://relay.example.com", servers: "https://blossom.example.com" };

const host = (url: string) => url.replace(/^(wss|https):\/\//, "");

/**
 * The page content of the addresses of a list, public or private, under `header`, as the app's.
 * Keeps the changes in a draft, saved as a single list. The servers, in order of preference, move.
 */
export function AddressList({
  header,
  list,
  texts,
  listed,
  defaults,
  editable = true,
  status,
  problem,
  save,
}: {
  header: ReactNode;
  list: VaultListName;
  texts: AddressListTexts;
  /** Undefined until read. */
  listed?: Listed;
  /** What Reset puts back, for a list that has defaults. */
  defaults?: string[];
  /** Whether saving cannot replace a newer list. */
  editable?: boolean;
  /** What a listed address shows while the draft keeps it, if anything. */
  status?: (url: string) => { text: string; icon: string } | undefined;
  /** What went wrong with a listed address, if anything. */
  problem?: (url: string) => string | undefined;
  save: (lists: Listed) => Promise<void>;
}) {
  const { formatMessage: t } = useIntl();
  const [draft, setDraft] = useState<AddressDraft>(noChanges);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState<string>();
  const [announcement, setAnnouncement] = useState("");
  const helpId = useId();
  const lists = listed ?? { public: [], private: [] };
  const rows = draftRows(lists, draft);
  const allRows = [...rows.public, ...rows.private];
  const saved = draftLists(lists, draft);
  const changed = draftChanged(lists, draft);
  const canEdit = editable && !saving;
  const empty = saved.public.length === 0 && saved.private.length === 0;
  const isDefault = !!defaults && saved.private.length === 0 && sameUrls(saved.public, defaults);
  const message =
    saveError ??
    (listed && !editable && texts.waitForSync
      ? t({ id: texts.waitForSync })
      : empty
        ? t({ id: texts.needOne })
        : undefined);
  const {
    rows: rowsRef,
    dragging,
    handleProps,
  } = useReorder(allRows, (url, to) => {
    const moved = moveInDraft(lists, draft, url, to);
    if (moved === draft) return false;
    setDraft(moved);
    const movedRows = draftRows(lists, moved);
    const group = movedRows.public.includes(url) ? movedRows.public : movedRows.private;
    setAnnouncement(
      t(
        { id: "fieldPosition" },
        { field: host(url), position: group.indexOf(url) + 1, count: group.length },
      ),
    );
    return true;
  });

  function discard() {
    setDraft(noChanges);
    setSaveError(undefined);
  }

  async function submit() {
    setSaving(true);
    setSaveError(undefined);
    try {
      await save(saved);
      setDraft(noChanges);
    } catch (error) {
      if (!texts.saveFailed) throw error;
      setSaveError(t({ id: texts.saveFailed }));
    } finally {
      setSaving(false);
    }
  }

  const row = (url: string, index: number) => {
    const isPrivate = index >= rows.public.length;
    const group = isPrivate ? rows.private : rows.public;
    const isListed = (isPrivate ? lists.private : lists.public).includes(url);
    const removed = isListed && draft.removed.includes(url);
    const note = isPrivate && texts.private ? t({ id: texts.private }) : undefined;
    const handle = list === "servers" && group.length > 1 && !removed && (
      <button
        type="button"
        {...handleProps(url)}
        className="button icon-button drag-handle"
        disabled={!canEdit}
        aria-label={t({ id: "moveServer" }, { server: host(url) })}
        aria-describedby={helpId}
      >
        <Icon src={dragIndicator} />
      </button>
    );
    const common = {
      url,
      note,
      dragging: dragging === url,
      handle,
    };
    if (!isListed) {
      return (
        <AddressTile
          key={url}
          {...common}
          status={{ text: t({ id: texts.added }), icon: addCircle }}
        >
          <IconButton
            icon={close}
            iconSize={20}
            label={t({ id: texts.remove })}
            isDisabled={!canEdit}
            onPress={() =>
              setDraft({ ...draft, added: draft.added.filter((address) => address.url !== url) })
            }
          />
        </AddressTile>
      );
    }
    if (removed) {
      return (
        <AddressTile
          key={url}
          {...common}
          status={{ text: t({ id: texts.removed }), icon: removeCircle }}
          removed
        >
          <IconButton
            icon={undo}
            iconSize={20}
            label={t({ id: texts.keep })}
            isDisabled={!canEdit}
            onPress={() =>
              setDraft({ ...draft, removed: draft.removed.filter((each) => each !== url) })
            }
          />
        </AddressTile>
      );
    }
    return (
      <AddressTile key={url} {...common} status={status?.(url)} problem={problem?.(url)}>
        <IconButton
          icon={close}
          iconSize={20}
          label={t({ id: texts.remove })}
          isDisabled={!canEdit}
          onPress={() => setDraft({ ...draft, removed: [...draft.removed, url] })}
        />
      </AddressTile>
    );
  };

  return (
    <>
      <div className="page-content">
        {header}
        {listed && (
          <div className="field-card">
            {allRows.length > 0 && (
              <div ref={rowsRef} className="address-list-rows">
                {allRows.map(row)}
              </div>
            )}
            <AddAddressRow
              list={list}
              texts={texts}
              draft={[...saved.public, ...saved.private]}
              isDisabled={!canEdit}
              onAdd={(address) => setDraft(addToDraft(lists, draft, address))}
            />
          </div>
        )}
        <p id={helpId} hidden>
          {t({ id: "reorderFieldHelp" })}
        </p>
        <p className="visually-hidden" role="status">
          {announcement}
        </p>
      </div>
      <footer className="address-list-footer">
        {/* Next to the buttons it explains, wherever the list scrolled. */}
        {message && (
          <p className={saveError ? "address-list-message error" : "address-list-message"}>
            {message}
          </p>
        )}
        <div className="address-list-actions">
          {defaults && (
            <TextButton
              isDisabled={!listed || isDefault || saving}
              onPress={() => setDraft(resetDraft(lists, defaults))}
            >
              {t({ id: "resetMailRelays" })}
            </TextButton>
          )}
          <TextButton isDisabled={!changed || saving} onPress={discard}>
            {t({ id: "cancel" })}
          </TextButton>
          <FilledButton
            isDisabled={!changed || !canEdit || empty}
            isPending={saving}
            onPress={() => void submit()}
          >
            {t({ id: "save" })}
          </FilledButton>
        </div>
      </footer>
    </>
  );
}

/** The draft shows in `status`, so that the row keeps its height. */
function AddressTile({
  url,
  note,
  status,
  problem,
  removed,
  dragging,
  handle,
  children,
}: {
  url: string;
  /** Under the address, that it is private. */
  note?: string;
  status?: { text: string; icon: string };
  /** Under the address and `note`. */
  problem?: string;
  removed?: boolean;
  dragging?: boolean;
  handle?: ReactNode;
  children: ReactNode;
}) {
  return (
    <div
      className="settings-tile address-tile"
      data-removed={removed || undefined}
      data-dragging={dragging || undefined}
    >
      <span className="settings-tile-text">
        <span className="address-tile-url">{host(url)}</span>
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
      {handle}
    </div>
  );
}

/** The last row of a list, opening the dialog that gives the address to add. */
function AddAddressRow({
  list,
  texts,
  draft,
  isDisabled,
  onAdd,
}: {
  list: VaultListName;
  texts: AddressListTexts;
  /** The addresses the draft lists. */
  draft: string[];
  isDisabled?: boolean;
  onAdd: (address: VaultAddress) => void;
}) {
  const { formatMessage: t } = useIntl();
  return (
    <DialogTrigger>
      <Button className="settings-tile address-list-add" isDisabled={isDisabled}>
        <Icon src={add} size={20} />
        <span className="settings-tile-title">{t({ id: texts.add })}</span>
      </Button>
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
    </DialogTrigger>
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
  texts: AddressListTexts;
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
        {texts.keepPrivate && texts.keepPrivateDescription && (
          <SwitchTile
            label={t({ id: texts.keepPrivate })}
            description={t({ id: texts.keepPrivateDescription })}
            isSelected={isPrivate}
            onChange={setPrivate}
          />
        )}
      </div>
      <div className="dialog-actions">
        <TextButton slot="close">{t({ id: "cancel" })}</TextButton>
        <FilledButton type="submit">{t({ id: "add" })}</FilledButton>
      </div>
    </Form>
  );
}
