import visibility from "@material-design-icons/svg/outlined/visibility.svg";
import visibilityOff from "@material-design-icons/svg/outlined/visibility_off.svg";
import { type ReactNode, useState } from "react";
import {
  TextField as AriaTextField,
  FieldError,
  Group,
  Input,
  Label,
  Text,
  TextArea,
  type TextFieldProps,
} from "react-aria-components";
import { useIntl } from "react-intl";
import { IconButton } from "./Button";
import "./TextField.css";

/**
 * A labelled field, as the app's: its label inside until it takes the focus or a value, then on its
 * outline, or there from the start once `floatingLabel`, as the app's item form shows it, for the
 * placeholder to show. Its help below, its error in place of the help. A secret field is hidden
 * until shown, by its own button or by `shown`; a mono one is written in the font that tells every
 * character apart. With `rows`, it takes several lines, as many at least. `buttons` go at its end.
 */
export function TextField({
  label,
  description,
  error,
  placeholder,
  secret,
  mono,
  shown: shownProp,
  onShownChange,
  floatingLabel,
  rows,
  buttons,
  ...props
}: Omit<TextFieldProps, "children" | "isInvalid"> & {
  label: string;
  description?: string;
  error?: string;
  placeholder?: string;
  secret?: boolean;
  mono?: boolean;
  /** For several secret fields shown together. */
  shown?: boolean;
  onShownChange?: (shown: boolean) => void;
  floatingLabel?: boolean;
  rows?: number;
  buttons?: ReactNode;
}) {
  const { formatMessage: t } = useIntl();
  const [ownShown, setOwnShown] = useState(false);
  const shown = shownProp ?? ownShown;
  const setShown = onShownChange ?? setOwnShown;
  return (
    <AriaTextField
      {...props}
      className={rows ? "text-field multiline" : "text-field"}
      data-filled={floatingLabel || props.value ? true : undefined}
      isInvalid={error !== undefined}
      validationBehavior="aria"
    >
      <Group className="text-field-box">
        <Label className="text-field-label">{label}</Label>
        {rows ? (
          <TextArea
            className="text-field-input"
            rows={rows}
            placeholder={placeholder}
            style={{ minHeight: `calc(${rows}lh + 28px)` }}
          />
        ) : (
          <Input
            className={mono ? "text-field-input mono" : "text-field-input"}
            type={secret && !shown ? "password" : "text"}
            placeholder={placeholder}
            spellCheck={secret || mono ? false : undefined}
            autoCorrect={secret || mono ? "off" : undefined}
          />
        )}
        {secret && (
          <IconButton
            icon={shown ? visibilityOff : visibility}
            label={t({ id: shown ? "hide" : "show" })}
            onPress={() => setShown(!shown)}
          />
        )}
        {buttons}
        {/* The label's width, cut out of the outline once the label is on it. */}
        <fieldset className="text-field-outline" aria-hidden="true">
          <legend>
            <span>{label}</span>
          </legend>
        </fieldset>
      </Group>
      {error === undefined && description && (
        <Text slot="description" className="text-field-description">
          {description}
        </Text>
      )}
      <FieldError className="text-field-error">{error}</FieldError>
    </AriaTextField>
  );
}
