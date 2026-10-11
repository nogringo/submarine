import check from "@material-design-icons/svg/round/check.svg";
import { Label, Radio, RadioGroup } from "react-aria-components";
import { useIntl } from "react-intl";
import { cssColor, vaultColors } from "@/lib/vault-colors";
import { Icon } from "./Icon";
import "./ColorPicker.css";

/** The colors a vault can take, one of them chosen. */
export function ColorPicker({
  label,
  value,
  onChange,
}: {
  label: string;
  value: number;
  onChange: (color: number) => void;
}) {
  const { formatMessage: t } = useIntl();
  return (
    <RadioGroup
      className="color-picker"
      orientation="horizontal"
      value={String(value)}
      onChange={(color) => onChange(Number(color))}
    >
      <Label className="color-picker-label">{label}</Label>
      <div className="color-picker-swatches">
        {vaultColors.map((color) => (
          <Radio
            key={color.argb}
            value={String(color.argb)}
            aria-label={t({ id: color.name })}
            className="color-swatch"
          >
            {({ isSelected }) => (
              <span className="color-swatch-dot" style={{ background: cssColor(color.argb) }}>
                {isSelected && <Icon src={check} size={20} />}
              </span>
            )}
          </Radio>
        ))}
      </div>
    </RadioGroup>
  );
}
