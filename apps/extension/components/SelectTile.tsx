import arrowDropDown from "@material-design-icons/svg/round/arrow_drop_down.svg";
import { useRef, useState } from "react";
import {
  Button,
  Label,
  ListBox,
  ListBoxItem,
  Popover,
  Select,
  SelectValue,
} from "react-aria-components";
import { Icon } from "./Icon";
import "./SelectTile.css";

/** The height of an option and the padding of the list, as in SelectTile.css. */
const optionHeight = 48;
const listPadding = 8;

/**
 * A row of a settings card choosing one of `options` in a menu, as in the app: the menu over its
 * button, the option chosen on it, moved as little as it takes to show every option.
 */
export function SelectTile<K extends string>({
  title,
  value,
  options,
  onChange,
}: {
  title: string;
  value: K;
  options: { id: K; label: string }[];
  onChange: (value: K) => void;
}) {
  const button = useRef<HTMLButtonElement>(null);
  const [buttonWidth, setButtonWidth] = useState(0);
  const chosen = Math.max(
    0,
    options.findIndex((option) => option.id === value),
  );
  const menuHeight = 2 * listPadding + options.length * optionHeight;
  return (
    <Select
      className="settings-tile"
      value={value}
      onChange={(key) => {
        if (key !== null) onChange(key as K);
      }}
      onOpenChange={(open) => {
        if (open) setButtonWidth(button.current?.offsetWidth ?? 0);
      }}
    >
      <Label className="settings-tile-title select-tile-label">{title}</Label>
      <Button ref={button} className="button select-tile-button">
        <SelectValue />
        <Icon src={arrowDropDown} />
      </Button>
      {/* Beside the button, which React Aria keeps in sight vertically, back over it by its width. */}
      <Popover
        className="select-tile-popover"
        placement="left"
        offset={-buttonWidth}
        crossOffset={menuHeight / 2 - listPadding - (chosen + 0.5) * optionHeight}
        shouldFlip={false}
      >
        {/* The menu opens on the pointer down, its option chosen under the pointer: the release that
            follows must not choose it again, and close the menu at once. */}
        <ListBox className="select-tile-list" items={options} shouldSelectOnPressUp={false}>
          {(option) => (
            <ListBoxItem id={option.id} textValue={option.label} className="select-tile-option">
              {option.label}
            </ListBoxItem>
          )}
        </ListBox>
      </Popover>
    </Select>
  );
}
