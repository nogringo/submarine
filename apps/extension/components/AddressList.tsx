import add from "@material-design-icons/svg/round/add.svg";
import cellTower from "@material-design-icons/svg/round/cell_tower.svg";
import dns from "@material-design-icons/svg/round/dns.svg";
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
import { callCore, type VaultAddress, type VaultListName } from "@/lib/core";
import { FilledButton, TextButton } from "./Button";
import { Icon } from "./Icon";
import { TextField } from "./TextField";
import { SwitchTile } from "./ToggleTile";
import "./AddressList.css";

type MessageId = FormatjsIntl.Message["ids"];

export const addressIcons = { relays: cellTower, servers: dns };

/** What adding an address says. Without `keepPrivate`, an address cannot be private. */
export interface AddAddressTexts {
  add: MessageId;
  address: MessageId;
  invalid: MessageId;
  alreadyListed: MessageId;
  keepPrivate?: MessageId;
  keepPrivateDescription?: MessageId;
}

const hints = { relays: "wss://relay.example.com", servers: "https://blossom.example.com" };

/** The draft shows in `status`, so that the row keeps its height. */
export function AddressTile({
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

/** The last row of a list, opening the dialog that gives the address to add. */
export function AddAddressRow({
  list,
  texts,
  draft,
  isDisabled,
  onAdd,
}: {
  list: VaultListName;
  texts: AddAddressTexts;
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
  texts: AddAddressTexts;
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

/** Under a list, wherever it scrolled: `message` next to the buttons it explains. */
export function AddressListFooter({
  message,
  isError,
  children,
}: {
  message?: string;
  isError?: boolean;
  children: ReactNode;
}) {
  return (
    <footer className="address-list-footer">
      {message && (
        <p className={isError ? "address-list-message error" : "address-list-message"}>{message}</p>
      )}
      <div className="address-list-actions">{children}</div>
    </footer>
  );
}
