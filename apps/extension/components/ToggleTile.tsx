import check from "@material-design-icons/svg/round/check.svg";
import { Checkbox, Switch } from "react-aria-components";
import { Icon } from "./Icon";
import "./ToggleTile.css";

/** A row that turns `label` on or off, as the app's SwitchListTile. */
export function SwitchTile({
  label,
  isSelected,
  onChange,
}: {
  label: string;
  isSelected: boolean;
  onChange: (isSelected: boolean) => void;
}) {
  return (
    <Switch className="toggle-tile" isSelected={isSelected} onChange={onChange}>
      <span className="toggle-tile-label">{label}</span>
      <span className="switch-track" aria-hidden="true">
        <span className="switch-thumb" />
      </span>
    </Switch>
  );
}

/** A row that checks `label`, its box first, as the app's CheckboxListTile. */
export function CheckboxTile({
  label,
  isSelected,
  onChange,
}: {
  label: string;
  isSelected: boolean;
  onChange: (isSelected: boolean) => void;
}) {
  return (
    <Checkbox className="toggle-tile" isSelected={isSelected} onChange={onChange}>
      <span className="checkbox-box" aria-hidden="true">
        <Icon src={check} size={16} />
      </span>
      <span className="toggle-tile-label">{label}</span>
    </Checkbox>
  );
}
