import arrowDropDown from "@material-design-icons/svg/round/arrow_drop_down.svg";
import check from "@material-design-icons/svg/round/check.svg";
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

/** A row of a settings card choosing one of `options` in a menu, as in the app. */
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
  return (
    <Select
      className="settings-tile"
      value={value}
      onChange={(key) => {
        if (key !== null) onChange(key as K);
      }}
    >
      <Label className="settings-tile-title select-tile-label">{title}</Label>
      <Button className="button select-tile-button">
        <SelectValue />
        <Icon src={arrowDropDown} />
      </Button>
      <Popover className="select-tile-popover" placement="bottom end">
        <ListBox className="select-tile-list" items={options}>
          {(option) => (
            <ListBoxItem id={option.id} textValue={option.label} className="select-tile-option">
              {({ isSelected }) => (
                <>
                  {option.label}
                  {isSelected && <Icon src={check} size={20} />}
                </>
              )}
            </ListBoxItem>
          )}
        </ListBox>
      </Popover>
    </Select>
  );
}
