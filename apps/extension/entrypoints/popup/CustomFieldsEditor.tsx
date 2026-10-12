import editOutlined from "@material-design-icons/svg/outlined/edit.svg";
import add from "@material-design-icons/svg/round/add.svg";
import casino from "@material-design-icons/svg/round/casino.svg";
import deleteOutline from "@material-design-icons/svg/round/delete_outline.svg";
import dragIndicator from "@material-design-icons/svg/round/drag_indicator.svg";
import refresh from "@material-design-icons/svg/round/refresh.svg";
import textFields from "@material-design-icons/svg/round/text_fields.svg";
import { type FormEvent, useEffect, useId, useRef, useState } from "react";
import { Dialog, Heading, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, IconButton, TextButton } from "@/components/Button";
import { Icon } from "@/components/Icon";
import { ActionMenu } from "@/components/MoreMenu";
import { SelectField } from "@/components/SelectField";
import { TextField } from "@/components/TextField";
import { CheckboxTile } from "@/components/ToggleTile";
import type { Field } from "@/lib/cipher";
import { callCore, type MadeUpValue } from "@/lib/core";
import { linkedFieldLabel } from "@/lib/item-fields";
import { type EditedField, editedField, linkedIds } from "@/lib/item-form";
import "./CustomFieldsEditor.css";

type MessageId = FormatjsIntl.Message["ids"];

/** By Bitwarden's field type. */
const fieldTypes: [type: number, name: MessageId, help: MessageId][] = [
  [0, "fieldTypeText", "textFieldHelp"],
  [1, "fieldTypeHidden", "hiddenFieldHelp"],
  [2, "fieldTypeCheckbox", "checkboxFieldHelp"],
  [3, "fieldTypeLinked", "linkedFieldHelp"],
];

const madeUpValues: [kind: MadeUpValue, label: MessageId][] = [
  ["firstName", "firstName"],
  ["lastName", "lastName"],
  ["birthDate", "dateOfBirth"],
];

/**
 * The custom fields of an item of `type`, as Bitwarden's form edits them: added with a type and a
 * label, renamed, deleted and moved. A login can also get a made-up first name, last name or birth
 * date, as in the app. Email addresses are left to the app.
 */
export function CustomFieldsEditor({
  type,
  fields,
  onChange,
}: {
  type: number;
  fields: EditedField[];
  onChange: (fields: EditedField[]) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [dialog, setDialog] = useState<{ editing?: EditedField }>();
  const [announcement, setAnnouncement] = useState("");
  const helpId = useId();
  const rows = useRef<HTMLDivElement>(null);
  const handles = useRef(new Map<string, HTMLButtonElement>());
  // A new one at each move, the same field moved twice included.
  const [focusHandle, setFocusHandle] = useState<{ key: string }>();
  const [dragging, setDragging] = useState<string>();
  useEffect(() => {
    // Moved in the page, the handle may have lost the focus.
    if (focusHandle) handles.current.get(focusHandle.key)?.focus();
  }, [focusHandle]);

  const replace = (field: EditedField, changes: Partial<EditedField>) =>
    onChange(fields.map((each) => (each === field ? { ...each, ...changes } : each)));

  const move = (key: string, to: number) => {
    const from = fields.findIndex((field) => field.key === key);
    if (from < 0 || to < 0 || to >= fields.length || to === from) return;
    const moved = [...fields];
    const [field] = moved.splice(from, 1);
    if (!field) return;
    moved.splice(to, 0, field);
    onChange(moved);
    setFocusHandle({ key });
    setAnnouncement(
      t({ id: "fieldPosition" }, { field: field.name, position: to + 1, count: fields.length }),
    );
  };

  /** Moves the field dragged to the row under the pointer. */
  const dragOver = (key: string, y: number) => {
    const rects = [...(rows.current?.children ?? [])].map((row) => row.getBoundingClientRect());
    const below = rects.findIndex((rect) => y < rect.top + rect.height / 2);
    const from = fields.findIndex((field) => field.key === key);
    const to = below < 0 ? fields.length - 1 : below > from ? below - 1 : below;
    move(key, to);
  };
  useEffect(() => {
    if (!dragging) return;
    // On the window: moved in the page, the handle would lose a pointer capture.
    const follow = (event: PointerEvent) => dragOver(dragging, event.clientY);
    const drop = () => setDragging(undefined);
    window.addEventListener("pointermove", follow);
    window.addEventListener("pointerup", drop);
    window.addEventListener("pointercancel", drop);
    return () => {
      window.removeEventListener("pointermove", follow);
      window.removeEventListener("pointerup", drop);
      window.removeEventListener("pointercancel", drop);
    };
  });

  const addMadeUp = async (kind: MadeUpValue, label: MessageId) => {
    const value = await callCore("generateValue", { kind });
    onChange([
      ...fields,
      editedField({ name: t({ id: label }), value, type: 0, linkedId: null }, { madeUp: kind }),
    ]);
  };

  const addButton = (
    <TextButton onPress={type === 1 ? undefined : () => setDialog({})}>
      <Icon src={add} />
      {t({ id: "addField" })}
    </TextButton>
  );

  return (
    <section className="custom-fields">
      <h2 className="custom-fields-title">{t({ id: "customFields" })}</h2>
      {fields.length > 0 && (
        <div ref={rows} className="custom-fields-rows">
          {fields.map((field) => (
            <div
              key={field.key}
              className="custom-field"
              data-dragging={dragging === field.key ? true : undefined}
            >
              <div className="custom-field-input">
                <FieldInput
                  field={field}
                  type={type}
                  onChange={(changes) => replace(field, changes)}
                />
              </div>
              <IconButton
                icon={editOutlined}
                label={t({ id: "editFieldNamed" }, { field: field.name })}
                onPress={() => setDialog({ editing: field })}
              />
              {fields.length > 1 && (
                <button
                  type="button"
                  ref={(handle) => {
                    if (handle) handles.current.set(field.key, handle);
                    else handles.current.delete(field.key);
                  }}
                  className="button icon-button custom-field-handle"
                  aria-label={t({ id: "reorderField" }, { field: field.name })}
                  aria-describedby={helpId}
                  onKeyDown={(event) => {
                    const index = fields.indexOf(field);
                    if (event.key === "ArrowUp") move(field.key, index - 1);
                    else if (event.key === "ArrowDown") move(field.key, index + 1);
                    else return;
                    event.preventDefault();
                  }}
                  onPointerDown={(event) => {
                    if (event.button !== 0) return;
                    event.preventDefault();
                    setDragging(field.key);
                  }}
                >
                  <Icon src={dragIndicator} />
                </button>
              )}
            </div>
          ))}
        </div>
      )}
      {type === 1 ? (
        <ActionMenu
          trigger={addButton}
          placement="bottom start"
          actions={[
            { id: "custom", label: t({ id: "customField" }), icon: textFields },
            ...madeUpValues.map(([kind, label], index) => ({
              id: kind,
              label: t({ id: label }),
              icon: casino,
              separated: index === 0,
            })),
          ]}
          onAction={(id) => {
            if (id === "custom") setDialog({});
            else {
              const [kind, label] = madeUpValues.find(([kind]) => kind === id) ?? [];
              if (kind && label) void addMadeUp(kind, label);
            }
          }}
        />
      ) : (
        addButton
      )}
      <p id={helpId} hidden>
        {t({ id: "reorderFieldHelp" })}
      </p>
      <p className="visually-hidden" role="status">
        {announcement}
      </p>
      {dialog && (
        <FieldDialog
          type={type}
          editing={dialog.editing}
          onClose={() => setDialog(undefined)}
          onAdd={(field) => onChange([...fields, editedField(field, { isNew: true })])}
          onRename={(name) => dialog.editing && replace(dialog.editing, { name })}
          onDelete={() => onChange(fields.filter((field) => field !== dialog.editing))}
        />
      )}
    </section>
  );
}

/** The value of a custom field, as its type takes it. */
function FieldInput({
  field,
  type,
  onChange,
}: {
  field: EditedField;
  type: number;
  onChange: (changes: Partial<EditedField>) => void;
}) {
  const intl = useIntl();
  const { formatMessage: t } = intl;
  switch (field.source.type) {
    case 2:
      return (
        <CheckboxTile
          label={field.name}
          isSelected={field.checked}
          onChange={(checked) => onChange({ checked })}
        />
      );
    case 3: {
      const ids = linkedIds(type);
      const stored = field.linkedId;
      return (
        <SelectField
          label={field.name}
          value={stored}
          options={[...ids, ...(stored !== null && !ids.includes(stored) ? [stored] : [])].map(
            (id) => {
              const label = linkedFieldLabel(id, t);
              return { id, label: label === "?" ? String(id) : label };
            },
          )}
          onChange={(linkedId) => onChange({ linkedId })}
        />
      );
    }
    case 1:
      return (
        <TextField
          label={field.name}
          value={field.value}
          onChange={(value) => onChange({ value })}
          autoFocus={field.isNew}
          floatingLabel
          secret
          mono
        />
      );
    default: {
      const { madeUp } = field;
      return (
        <TextField
          label={field.name}
          value={field.value}
          onChange={(value) => onChange({ value })}
          autoFocus={field.isNew}
          floatingLabel
          buttons={
            madeUp && (
              <IconButton
                icon={refresh}
                label={t({ id: "regenerate" })}
                onPress={async () =>
                  onChange({ value: await callCore("generateValue", { kind: madeUp }) })
                }
              />
            )
          }
        />
      );
    }
  }
}

/**
 * Bitwarden's dialog adding a custom field of one of the types an item of `type` takes, or renaming
 * the field `editing`, which it also deletes.
 */
function FieldDialog({
  type,
  editing,
  onClose,
  onAdd,
  onRename,
  onDelete,
}: {
  type: number;
  editing?: EditedField;
  onClose: () => void;
  onAdd: (field: Field) => void;
  onRename: (name: string) => void;
  onDelete: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [fieldType, setFieldType] = useState(0);
  const [label, setLabel] = useState(editing?.name ?? "");
  const linkable = linkedIds(type);
  const types = fieldTypes.filter(([type]) => type !== 3 || linkable.length > 0);
  const help = types.find(([type]) => type === fieldType)?.[2];
  const submit = (event: FormEvent) => {
    event.preventDefault();
    // Out of the item form in the page, not in React's tree.
    event.stopPropagation();
    const name = label.trim();
    if (!name) return;
    if (editing) onRename(name);
    else {
      onAdd({
        name,
        value: null,
        type: fieldType,
        linkedId: fieldType === 3 ? (linkable[0] ?? null) : null,
      });
    }
    onClose();
  };
  return (
    <ModalOverlay
      className="dialog-overlay"
      isDismissable
      isOpen
      onOpenChange={(open) => !open && onClose()}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          <Heading slot="title" className="dialog-title">
            {t({ id: editing ? "editField" : "addField" })}
          </Heading>
          {/* Not a Form: it would take the props of the item form's, through React Aria's context. */}
          <form className="dialog-fields" onSubmit={submit}>
            {!editing && (
              <SelectField
                label={t({ id: "fieldType" })}
                description={help && t({ id: help })}
                value={fieldType}
                options={types.map(([id, name]) => ({ id, label: t({ id: name }) }))}
                onChange={(type) => setFieldType(type ?? 0)}
              />
            )}
            <TextField
              label={t({ id: "fieldLabel" })}
              description={
                !editing && fieldType === 3 ? t({ id: "linkedFieldLabelHelp" }) : undefined
              }
              value={label}
              onChange={setLabel}
              autoFocus
            />
            <div className="dialog-actions custom-field-dialog-actions">
              {editing && (
                <IconButton
                  icon={deleteOutline}
                  className="danger"
                  label={t({ id: "deleteFieldNamed" }, { field: editing.name })}
                  onPress={() => {
                    onDelete();
                    onClose();
                  }}
                />
              )}
              <TextButton onPress={onClose}>{t({ id: "cancel" })}</TextButton>
              <FilledButton type="submit" isDisabled={!label.trim()}>
                {t({ id: editing ? "save" : "add" })}
              </FilledButton>
            </div>
          </form>
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}
