import arrowDropDown from "@material-design-icons/svg/round/arrow_drop_down.svg";
import {
  Button as AriaButton,
  type Key,
  Label,
  ListBox,
  ListBoxItem,
  Popover,
  Select,
  SelectValue,
  Text,
} from "react-aria-components";
import { Icon } from "./Icon";
import "./SelectTile.css";
import "./SelectField.css";
import "./TextField.css";

/** Stands for no value, which a key cannot be. */
const none = "\u0000none";

/**
 * A value to pick among `options`, in a field that looks like a TextField, its label on its
 * outline. With `notSet`, the first option, muted, picks none, as the app's dropdowns offer it.
 */
export function SelectField<K extends Key>({
  label,
  description,
  value,
  options,
  notSet,
  onChange,
}: {
  label: string;
  description?: string;
  value: K | null;
  options: { id: K; label: string }[];
  notSet?: string;
  onChange: (value: K | null) => void;
}) {
  const items: { id: Key; label: string }[] =
    notSet === undefined ? options : [{ id: none, label: notSet }, ...options];
  return (
    <Select
      className="text-field select-field"
      data-filled
      value={value ?? none}
      onChange={(key) => onChange(key === none || key === null ? null : (key as K))}
    >
      <div className="text-field-box">
        <Label className="text-field-label">{label}</Label>
        <AriaButton className="select-field-button">
          <SelectValue<{ id: Key; label: string }> className="select-field-value">
            {({ selectedItem }) =>
              selectedItem?.id === none ? (
                <span className="select-field-none">{notSet}</span>
              ) : (
                selectedItem?.label
              )
            }
          </SelectValue>
          <Icon src={arrowDropDown} />
        </AriaButton>
        <fieldset className="text-field-outline" aria-hidden="true">
          <legend>
            <span>{label}</span>
          </legend>
        </fieldset>
      </div>
      {description && (
        <Text slot="description" className="text-field-description">
          {description}
        </Text>
      )}
      <Popover className="select-tile-popover select-field-popover" placement="bottom start">
        <ListBox className="select-tile-list" items={items} shouldSelectOnPressUp={false}>
          {(option) => (
            <ListBoxItem
              id={option.id}
              textValue={option.label}
              className={
                option.id === none ? "select-tile-option select-field-none" : "select-tile-option"
              }
            >
              {option.label}
            </ListBoxItem>
          )}
        </ListBox>
      </Popover>
    </Select>
  );
}
