import add from "@material-design-icons/svg/round/add.svg";
import remove from "@material-design-icons/svg/round/remove.svg";
import { Button, Group, Input, Label, NumberField } from "react-aria-components";
import { Icon } from "./Icon";
import "./CountField.css";

/** A row choosing a whole number from `min` to `max`, a step at a time or typed, as in the app's generator. */
export function CountField({
  label,
  value,
  min,
  max,
  isDisabled,
  onChange,
}: {
  label: string;
  value: number;
  min: number;
  max: number;
  isDisabled?: boolean;
  onChange: (value: number) => void;
}) {
  return (
    <NumberField
      className="count-field"
      value={value}
      minValue={min}
      maxValue={max}
      isDisabled={isDisabled}
      // A field emptied gives no number: the value comes back.
      onChange={(count) => {
        if (!Number.isNaN(count)) onChange(count);
      }}
    >
      <Label className="count-field-label">{label}</Label>
      <Group className="count-field-group">
        <Button slot="decrement" className="button icon-button">
          <Icon src={remove} />
        </Button>
        <Input className="count-field-input" />
        <Button slot="increment" className="button icon-button">
          <Icon src={add} />
        </Button>
      </Group>
    </NumberField>
  );
}
