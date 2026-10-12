import add from "@material-design-icons/svg/round/add.svg";
import { type FormEvent, useId, useState } from "react";
import { Form } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, TextButton } from "@/components/Button";
import { ConfirmDialog } from "@/components/Dialog";
import { Icon } from "@/components/Icon";
import { Page } from "@/components/Page";
import { SelectField } from "@/components/SelectField";
import { TextField } from "@/components/TextField";
import { SwitchTile } from "@/components/ToggleTile";
import type { Cipher } from "@/lib/cipher";
import { callCore, type Item, type Vault } from "@/lib/core";
import { cardBrandLabel } from "@/lib/item-fields";
import {
  brandOptions,
  cipherOf,
  formChanged,
  formOf,
  type ItemFormValues,
  loginForPage,
  monthOptions,
} from "@/lib/item-form";
import { CustomFieldsEditor } from "./CustomFieldsEditor";
import { GenerateButton } from "./Generator";
import "./ItemForm.css";

type MessageId = FormatjsIntl.Message["ids"];

const newItemTitles: Record<number, MessageId> = {
  1: "newLogin",
  2: "newSecureNote",
  3: "newCard",
};

/**
 * Creates an item of `type` in `vault`, or another of `vaults` chosen, or edits `item`, as the app's
 * form. A new login over the web page at `pageUrl` gets its host as name and its origin as website.
 * `onClose` once cancelled, or once the changes are discarded.
 */
export function ItemForm({
  vaults,
  vault: defaultVault,
  type,
  item,
  pageUrl,
  onSaved,
  onClose,
}: {
  vaults: Vault[];
  vault: Vault;
  type: number;
  item?: Item;
  pageUrl?: string;
  onSaved: (vault: Vault, id: string, cipher: Cipher) => void;
  onClose: () => void;
}) {
  const { formatMessage: t, locale } = useIntl();
  // What Save compares with: a new login named after the page saves as it is.
  const [blank] = useState(() => formOf(item?.cipher, type));
  const [initial] = useState(() => {
    const page = !item && type === 1 && pageUrl ? loginForPage(pageUrl) : undefined;
    return page ? { ...blank, name: page.name, uris: [{ source: null, uri: page.uri }] } : blank;
  });
  const [form, setForm] = useState(initial);
  const [vaultKey, setVaultKey] = useState(defaultVault.pubkey);
  const vault = vaults.find((vault) => vault.pubkey === vaultKey) ?? defaultVault;
  const [errors, setErrors] = useState<{ name?: string; save?: string }>({});
  const [saving, setSaving] = useState(false);
  const [discarding, setDiscarding] = useState(false);
  const formId = useId();
  const set = (changes: Partial<ItemFormValues>) => setForm((form) => ({ ...form, ...changes }));
  const leave = () => (formChanged(form, initial) ? setDiscarding(true) : onClose());

  async function save(event: FormEvent) {
    event.preventDefault();
    if (saving) return;
    if (!form.name.trim()) {
      setErrors({ name: t({ id: "itemNameRequired" }) });
      return;
    }
    setErrors({});
    setSaving(true);
    const cipher = cipherOf(form, item?.cipher);
    try {
      if (item) {
        await callCore("updateItem", { vault: item.vault, base: item.base, cipher });
        onSaved(vault, item.id, cipher);
      } else {
        const { id } = await callCore("createItem", { vault: vault.pubkey, cipher });
        onSaved(vault, id, cipher);
      }
    } catch {
      setErrors({ save: t({ id: "itemSaveFailed" }) });
      setSaving(false);
    }
  }

  const monthName = new Intl.DateTimeFormat(locale, { month: "long" });
  return (
    <Page
      className="item-form"
      onBack={leave}
      cancel={t({ id: "cancel" })}
      title={t({ id: item ? "editItem" : newItemTitles[form.type] })}
      actions={
        <FilledButton type="submit" form={formId} isDisabled={saving || !formChanged(form, blank)}>
          {t({ id: "save" })}
        </FilledButton>
      }
    >
      <Form id={formId} className="page-content item-form-fields" onSubmit={save}>
        {errors.save && (
          <p className="item-form-error" role="alert">
            {errors.save}
          </p>
        )}
        {!item && vaults.length > 1 && (
          <SelectField
            label={t({ id: "vault" })}
            value={vault.pubkey}
            options={vaults.map((vault) => ({ id: vault.pubkey, label: vault.name }))}
            onChange={(pubkey) => pubkey && setVaultKey(pubkey)}
          />
        )}
        <TextField
          name="name"
          label={t({ id: "itemName" })}
          error={errors.name}
          value={form.name}
          onChange={(name) => set({ name })}
          autoFocus={!item}
          floatingLabel
        />
        {form.type === 1 && (
          <>
            <TextField
              name="username"
              label={t({ id: "username" })}
              value={form.username}
              onChange={(username) => set({ username })}
              autoComplete="off"
              floatingLabel
              buttons={<GenerateButton username onUse={(username) => set({ username })} />}
            />
            <TextField
              name="password"
              label={t({ id: "password" })}
              value={form.password}
              onChange={(password) => set({ password })}
              autoComplete="off"
              floatingLabel
              secret
              mono
              buttons={<GenerateButton onUse={(password) => set({ password })} />}
            />
            <TextField
              name="totp"
              label={t({ id: "authenticatorKey" })}
              placeholder={t({ id: "authenticatorKeyHint" })}
              value={form.totp}
              onChange={(totp) => set({ totp })}
              autoComplete="off"
              floatingLabel
              mono
            />
            <div className="item-form-websites">
              {form.uris.map((uri, index) => (
                <TextField
                  // biome-ignore lint/suspicious/noArrayIndexKey: websites are only added at the end.
                  key={index}
                  label={t({ id: "website" })}
                  placeholder="https://"
                  value={uri.uri}
                  onChange={(text) =>
                    set({
                      uris: form.uris.map((each) => (each === uri ? { ...each, uri: text } : each)),
                    })
                  }
                  autoFocus={uri.isNew}
                  inputMode="url"
                  autoComplete="off"
                  floatingLabel
                />
              ))}
              <TextButton
                onPress={() =>
                  set({ uris: [...form.uris, { source: null, uri: "", isNew: true }] })
                }
              >
                <Icon src={add} />
                {t({ id: "addWebsite" })}
              </TextButton>
            </div>
          </>
        )}
        {form.type === 3 && (
          <>
            <TextField
              label={t({ id: "cardholderName" })}
              value={form.cardholderName}
              onChange={(cardholderName) => set({ cardholderName })}
              autoComplete="off"
              floatingLabel
            />
            <TextField
              label={t({ id: "cardNumber" })}
              value={form.number}
              onChange={(number) => set({ number })}
              inputMode="numeric"
              autoComplete="off"
              floatingLabel
              secret
              mono
            />
            <SelectField
              label={t({ id: "cardBrand" })}
              notSet={t({ id: "notSet" })}
              value={form.brand}
              options={brandOptions(blank.brand).map(({ value, brand }) => ({
                id: value,
                label: brand ? cardBrandLabel(brand, t({ id: "cardBrandOther" })) : value,
              }))}
              onChange={(brand) => set({ brand })}
            />
            <SelectField
              label={t({ id: "cardExpMonth" })}
              notSet={t({ id: "notSet" })}
              value={form.expMonth}
              options={monthOptions(blank.expMonth).map(({ value, month }) => ({
                id: value,
                label:
                  month === null
                    ? value
                    : `${String(month).padStart(2, "0")} (${monthName.format(new Date(2000, month - 1))})`,
              }))}
              onChange={(expMonth) => set({ expMonth })}
            />
            <TextField
              label={t({ id: "cardExpYear" })}
              placeholder={t({ id: "cardExpYearHint" })}
              value={form.expYear}
              onChange={(expYear) => set({ expYear })}
              inputMode="numeric"
              autoComplete="off"
              floatingLabel
            />
            <TextField
              label={t({ id: "cardCode" })}
              value={form.code}
              onChange={(code) => set({ code })}
              inputMode="numeric"
              autoComplete="off"
              floatingLabel
              secret
              mono
            />
          </>
        )}
        <TextField
          label={t({ id: "notes" })}
          value={form.notes}
          onChange={(notes) => set({ notes })}
          rows={form.type === 2 ? 8 : 3}
          floatingLabel
        />
        <SwitchTile
          label={t({ id: "favorite" })}
          isSelected={form.favorite}
          onChange={(favorite) => set({ favorite })}
        />
        <CustomFieldsEditor
          type={form.type}
          fields={form.fields}
          onChange={(fields) => set({ fields })}
        />
      </Form>
      <ConfirmDialog
        title={t({ id: "discardChanges" })}
        cancel={t({ id: "keepEditing" })}
        confirm={t({ id: "discard" })}
        onConfirm={onClose}
        isOpen={discarding}
        onOpenChange={setDiscarding}
      />
    </Page>
  );
}
